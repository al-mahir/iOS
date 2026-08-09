//
//  TaahudViewModel.swift
//  Reading
//
//  Presentation layer. SwiftUI + Swift Concurrency. Depends only on Domain
//  use case protocols — never on RecitationWebSocketClient, AVAudioEngine,
//  or sqlite3 directly.
//
//  Two ways to drive this ViewModel:
//   1. Standalone: `loadPage(_:)` fetches from Taahud's own Mushaf DB, and
//      `onMicTapped()` derives the start cursor from that loaded page.
//      Used by `TaahudContainerView`.
//   2. Embedded: a host app that already owns its own Mushaf page data
//      (e.g. an existing Mushaf reader's "AI correction" mode) calls
//      `startSession(sura:aya:wordIdx:)` directly with a cursor it already
//      knows, and reads `wordHighlights`/`wordErrors` keyed by
//      `RecitationWordKey` to paint its own word views. `mushafRepository`,
//      `fetchMushafPageUseCase`, and `seekRecitationUseCase` are optional
//      specifically so an embedded host isn't forced to also wire up
//      Taahud's own local databases.
//

import Foundation
import Combine

public enum TaahudState: Equatable {
    case idle
    case connecting
    case recording
    case feedbackReceived
    case error(String)
}

/// Per-word UI status the view layer renders. Deliberately narrower than
/// `WordFeedbackStatus` — this is the type `WordHighlightOverlay` consumes.
public enum WordHighlightStatus: Equatable {
    case none
    case correct
    case error
    case hint      // maps from .almost — soft hint only, never a hard error
    case neutral   // maps from .trimmed — no success/error indication
}

@MainActor
public final class TaahudViewModel: ObservableObject {

    // MARK: Published UI state

    @Published public private(set) var state: TaahudState = .idle
    @Published public private(set) var currentPage: MushafPageData?
    @Published public private(set) var cursor: RecitationCursor?
    @Published public private(set) var wordHighlights: [RecitationWordKey: WordHighlightStatus] = [:]
    @Published public private(set) var wordErrors: [RecitationWordKey: [TajweedError]] = [:]
    @Published public private(set) var hardErrorCount: Int = 0
    @Published public var selectedRules: [TajweedRule] = [.aaredMadd, .ghonna]
    @Published public var strictness: RecitationStrictness = .normal

    /// Fires whenever the live cursor moves onto a page other than the one
    /// currently loaded. A host that owns its own page data (embedded mode)
    /// observes this instead of relying on Taahud's internal `loadPage`.
    public var onCursorLeftPage: ((RecitationCursor) -> Void)?

    // MARK: Dependencies

    private let startRecitationUseCase: StartRecitationUseCaseProtocol
    private let processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol
    private let stopRecitationUseCase: StopRecitationUseCaseProtocol
    private let recitationRepository: RecitationRepository

    /// Only needed for standalone usage (`loadPage`, `seek`, cursor
    /// auto-follow against Taahud's own DB). Nil in embedded mode.
    private let fetchMushafPageUseCase: FetchMushafPageUseCaseProtocol?
    private let seekRecitationUseCase: SeekRecitationUseCaseProtocol?
    private let mushafRepository: MushafRepository?

    private var feedbackTask: Task<Void, Never>?
    private var session: RecitationSession?

    public init(
        startRecitationUseCase: StartRecitationUseCaseProtocol,
        processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol,
        stopRecitationUseCase: StopRecitationUseCaseProtocol,
        recitationRepository: RecitationRepository,
        fetchMushafPageUseCase: FetchMushafPageUseCaseProtocol? = nil,
        seekRecitationUseCase: SeekRecitationUseCaseProtocol? = nil,
        mushafRepository: MushafRepository? = nil
    ) {
        self.startRecitationUseCase = startRecitationUseCase
        self.processAudioStreamUseCase = processAudioStreamUseCase
        self.stopRecitationUseCase = stopRecitationUseCase
        self.recitationRepository = recitationRepository
        self.fetchMushafPageUseCase = fetchMushafPageUseCase
        self.seekRecitationUseCase = seekRecitationUseCase
        self.mushafRepository = mushafRepository
    }

    // MARK: - Page loading (standalone mode only)

    public func loadPage(_ pageNumber: Int) async {
        guard let fetchMushafPageUseCase else {
            assertionFailure("loadPage(_:) requires fetchMushafPageUseCase — use startSession(sura:aya:wordIdx:) in embedded mode instead.")
            return
        }
        do {
            currentPage = try await fetchMushafPageUseCase.execute(pageNumber: pageNumber)
        } catch {
            print("❌ [Taahud/VM] failed to load page \(pageNumber): \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Mic tap (standalone mode — derives cursor from currentPage)

    public func onMicTapped() {
        switch state {
        case .idle, .error:
            guard let page = currentPage, let firstWord = page.words.first(where: { !$0.isVerseMarker }) else {
                state = .error("No page loaded to recite from.")
                return
            }
            startSession(sura: firstWord.sura, aya: firstWord.aya, wordIdx: firstWord.wordPosition)
        case .recording, .feedbackReceived, .connecting:
            stopSession()
        }
    }

    // MARK: - Explicit start/stop (embedded mode — host supplies the cursor)

    /// Starts a live session from an explicit (sura, aya, wordIdx) cursor.
    /// Safe to call directly when a host app already knows the position to
    /// recite from and doesn't need Taahud's own page-loading machinery.
    public func startSession(sura: Int, aya: Int, wordIdx: Int) {
        guard state == .idle || isError else { return }

        state = .connecting
        wordHighlights.removeAll()
        wordErrors.removeAll()
        hardErrorCount = 0

        let config = RecitationStartConfig(
            sura: sura,
            aya: aya,
            wordIdx: wordIdx,
            strictness: strictness,
            engine: .real,
            rules: selectedRules
        )

        Task {
            do {
                let session = try await startRecitationUseCase.execute(config: config)
                self.session = session
                cursor = session.cursor
                listenForFeedback()

                try await processAudioStreamUseCase.start { [weak self] error in
                    Task { @MainActor in
                        self?.handleFatalError(error)
                    }
                }
                state = .recording
                print("🕌 [Taahud/VM] session \(session.sessionId) started, engine=\(session.engine.rawValue)")
            } catch {
                handleFatalError(error)
            }
        }
    }

    public func stop() {
        stopSession()
    }
    
    public func clearErrors() {
        wordHighlights.removeAll()
        wordErrors.removeAll()
        hardErrorCount = 0
    }

    private var isError: Bool {
        if case .error = state { return true }
        return false
    }

    private func stopSession() {
        feedbackTask?.cancel()
        feedbackTask = nil
        Task {
            await stopRecitationUseCase.execute()
            session = nil
            state = .idle
            print("🕌 [Taahud/VM] session stopped")
        }
    }

    // MARK: - Seeking (standalone mode; page turn / tapped ayah)

    public func seek(sura: Int, aya: Int, wordIdx: Int) {
        guard let seekRecitationUseCase else {
            assertionFailure("seek(sura:aya:wordIdx:) requires seekRecitationUseCase — not available in embedded mode.")
            return
        }
        Task {
            do {
                let pageNumber = try await seekRecitationUseCase.execute(sura: sura, aya: aya, wordIdx: wordIdx)
                if currentPage?.pageNumber != pageNumber {
                    await loadPage(pageNumber)
                }
                cursor = RecitationCursor(sura: sura, aya: aya, wordIdx: wordIdx)
                wordHighlights.removeAll()
                wordErrors.removeAll()
            } catch {
                print("❌ [Taahud/VM] seek failed: \(error.localizedDescription)")
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Feedback stream

    private func listenForFeedback() {
        feedbackTask?.cancel()
        feedbackTask = Task { [weak self] in
            guard let self else { return }
            do {
                for try await event in self.recitationRepository.feedbackEvents() {
                    try Task.checkCancellation()
                    self.apply(event)
                }
            } catch is CancellationError {
                // Expected on stop().
            } catch {
                self.handleFatalError(error)
            }
        }
    }

    private func apply(_ event: RecitationFeedbackEvent) {
        // `cursor` is nil when the engine declined to assert a position
        // (ambiguous/no_match chunk) — keep the last known cursor rather than
        // clobbering it with nothing.
        if let newCursor = event.cursor {
            cursor = newCursor
        }

        for word in event.words {
            wordHighlights[word.key] = Self.highlightStatus(for: word)
            wordErrors[word.key] = word.errors
        }

        // Strict rule: `.almost` never counts toward the hard error total,
        // and neither does `.trimmed` (it's a boundary artifact, not a mistake).
        hardErrorCount = wordHighlights.values.filter { $0 == .error }.count

        state = .feedbackReceived
        followCursorIfNeeded()
    }

    /// In standalone mode, advances the displayed page if the live cursor has
    /// moved past it, using Taahud's own MushafRepository. In embedded mode
    /// (no mushafRepository), notifies the host via `onCursorLeftPage`
    /// instead so the host's own page-navigation code can react.
    private func followCursorIfNeeded() {
        guard let cursor else { return }

        guard let mushafRepository, let currentPage else {
            onCursorLeftPage?(cursor)
            return
        }

        let onCurrentPage = currentPage.words.contains { $0.sura == cursor.sura && $0.aya == cursor.aya }
        guard !onCurrentPage else { return }

        Task {
            guard let pageNumber = try? await mushafRepository.pageNumber(forSura: cursor.sura, aya: cursor.aya, wordIdx: cursor.wordIdx) else {
                return
            }
            await loadPage(pageNumber)
        }
    }

    private func handleFatalError(_ error: Error) {
        print("❌ [Taahud/VM] fatal error: \(error.localizedDescription)")
        state = .error(error.localizedDescription)
        Task {
            await stopRecitationUseCase.execute()
            session = nil
        }
    }

    // MARK: - Mapping

    private static func highlightStatus(for feedback: WordFeedback) -> WordHighlightStatus {
        if feedback.trimmed {
            return .neutral
        }
        switch feedback.status {
        case .correct: return .correct
        case .error: return .error
        case .almost: return .hint
        case .trimmed: return .neutral
        case .unknown: return .none
        }
    }
}
