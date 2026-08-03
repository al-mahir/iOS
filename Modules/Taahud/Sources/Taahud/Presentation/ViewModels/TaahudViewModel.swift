//
//  TaahudViewModel.swift
//  Reading
//
//  Presentation layer. SwiftUI + Swift Concurrency. Depends only on Domain
//  use case protocols — never on RecitationWebSocketClient, AVAudioEngine,
//  or sqlite3 directly.
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
    @Published public private(set) var wordHighlights: [Int: WordHighlightStatus] = [:]
    @Published public private(set) var wordErrors: [Int: [TajweedError]] = [:]
    @Published public private(set) var hardErrorCount: Int = 0
    @Published public var selectedRules: [TajweedRule] = [.aaredMadd, .ghonna]
    @Published public var strictness: RecitationStrictness = .normal

    // MARK: Dependencies

    private let startRecitationUseCase: StartRecitationUseCaseProtocol
    private let processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol
    private let fetchMushafPageUseCase: FetchMushafPageUseCaseProtocol
    private let seekRecitationUseCase: SeekRecitationUseCaseProtocol
    private let stopRecitationUseCase: StopRecitationUseCaseProtocol
    private let recitationRepository: RecitationRepository
    private let mushafRepository: MushafRepository

    private var feedbackTask: Task<Void, Never>?
    private var session: RecitationSession?

    public init(
        startRecitationUseCase: StartRecitationUseCaseProtocol,
        processAudioStreamUseCase: ProcessAudioStreamUseCaseProtocol,
        fetchMushafPageUseCase: FetchMushafPageUseCaseProtocol,
        seekRecitationUseCase: SeekRecitationUseCaseProtocol,
        stopRecitationUseCase: StopRecitationUseCaseProtocol,
        recitationRepository: RecitationRepository,
        mushafRepository: MushafRepository
    ) {
        self.startRecitationUseCase = startRecitationUseCase
        self.processAudioStreamUseCase = processAudioStreamUseCase
        self.fetchMushafPageUseCase = fetchMushafPageUseCase
        self.seekRecitationUseCase = seekRecitationUseCase
        self.stopRecitationUseCase = stopRecitationUseCase
        self.recitationRepository = recitationRepository
        self.mushafRepository = mushafRepository
    }

    // MARK: - Page loading

    public func loadPage(_ pageNumber: Int) async {
        do {
            currentPage = try await fetchMushafPageUseCase.execute(pageNumber: pageNumber)
        } catch {
            print("❌ [Taahud/VM] failed to load page \(pageNumber): \(error.localizedDescription)")
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Mic tap

    public func onMicTapped() {
        switch state {
        case .idle, .error:
            startSession()
        case .recording, .feedbackReceived, .connecting:
            stopSession()
        }
    }

    private func startSession() {
        guard let page = currentPage, let firstWord = page.words.first(where: { !$0.isVerseMarker }) else {
            state = .error("No page loaded to recite from.")
            return
        }

        state = .connecting
        wordHighlights.removeAll()
        wordErrors.removeAll()
        hardErrorCount = 0

        let config = RecitationStartConfig(
            sura: firstWord.sura,
            aya: firstWord.aya,
            wordIdx: firstWord.wordPosition,
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

    // MARK: - Seeking (page turn / tapped ayah)

    public func seek(sura: Int, aya: Int, wordIdx: Int) {
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
        cursor = event.cursor

        for word in event.words {
            wordHighlights[word.wordIdx] = Self.highlightStatus(for: word)
            wordErrors[word.wordIdx] = word.errors
        }

        // Strict rule: `.almost` never counts toward the hard error total,
        // and neither does `.trimmed` (it's a boundary artifact, not a mistake).
        hardErrorCount = wordHighlights.values.filter { $0 == .error }.count

        state = .feedbackReceived
        followCursorIfNeeded()
    }

    /// Advances the displayed page if the live cursor has moved past it,
    /// so the Mushaf view tracks live recitation across a page boundary
    /// without the user having to turn the page by hand.
    private func followCursorIfNeeded() {
        guard let cursor, let currentPage else { return }
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
