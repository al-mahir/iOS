//
//  PrivateSessionViewModel.swift
//  Sheikh
//

import Foundation
import Combine

// MARK: - Session State Machine

public enum PrivateSessionState: Equatable {
    case idle
    case requesting
    case waitingForApproval(requestId: String)
    case approved(
        requestId: String,
        channelName: String,
        agoraToken: String,
        userAccount: String?
    )
    case declined(reason: String?)
    case cancelled
    case expired
}

// MARK: - ViewModel

@MainActor
public final class PrivateSessionViewModel: ObservableObject {

    // MARK: Published State

    @Published public var availability: SheikhAvailability? = nil
    @Published public var sessionState: PrivateSessionState = .idle
    @Published public var isLoadingAvailability: Bool = false
    @Published public var errorMessage: String? = nil

    // MARK: Dependencies

    private let sheikhID: String
    private let getAvailabilityUseCase: any GetSheikhAvailabilityUseCaseProtocol
    private let sendRequestUseCase: any SendMeetingRequestUseCaseProtocol
    private let cancelRequestUseCase: any CancelMeetingRequestUseCaseProtocol
    private let observeRequestUseCase: any ObserveMeetingRequestUseCaseProtocol
    private let getFreshAgoraTokenUseCase: any GetFreshAgoraTokenUseCaseProtocol

    private var cancellables = Set<AnyCancellable>()

    // MARK: Init

    public init(
        sheikhID: String,
        initialStatus: SheikhAvailabilityStatus = .notAvailable,
        getAvailabilityUseCase: any GetSheikhAvailabilityUseCaseProtocol,
        sendRequestUseCase: any SendMeetingRequestUseCaseProtocol,
        cancelRequestUseCase: any CancelMeetingRequestUseCaseProtocol,
        observeRequestUseCase: any ObserveMeetingRequestUseCaseProtocol,
        getFreshAgoraTokenUseCase: any GetFreshAgoraTokenUseCaseProtocol
    ) {
        self.sheikhID = sheikhID
        self.getAvailabilityUseCase = getAvailabilityUseCase
        self.sendRequestUseCase = sendRequestUseCase
        self.cancelRequestUseCase = cancelRequestUseCase
        self.observeRequestUseCase = observeRequestUseCase
        self.getFreshAgoraTokenUseCase = getFreshAgoraTokenUseCase
        self.availability = SheikhAvailability(sheikhId: sheikhID, status: initialStatus)
    }

    // MARK: - Actions

    /// Fetch the Sheikh's current availability from the backend.
    public func loadAvailability() {
        isLoadingAvailability = true
        errorMessage = nil

        Task {
            do {
                let result = try await getAvailabilityUseCase.execute(sheikhId: sheikhID)
                self.availability = result
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoadingAvailability = false
        }
    }

    /// Send a meeting request to the Sheikh and start observing for status updates.
    public func requestSession() {
        guard sessionState == .idle else { return }
        sessionState = .requesting
        errorMessage = nil

        Task {
            do {
                let request = try await sendRequestUseCase.execute(sheikhId: sheikhID)
                self.sessionState = .waitingForApproval(requestId: request.requestId)
                self.observeUpdates(requestId: request.requestId)
            } catch {
                self.sessionState = .idle
                self.errorMessage = error.localizedDescription
            }
        }
    }

    /// Cancel an in-flight meeting request.
    public func cancelRequest() {
        guard case .waitingForApproval(let requestId) = sessionState else { return }
        cancellables.removeAll()

        Task {
            do {
                try await cancelRequestUseCase.execute(requestId: requestId)
            } catch {
                // Best-effort cancel; local state still transitions to cancelled.
            }
            self.sessionState = .cancelled

            // Auto-reset to idle after a brief feedback moment.
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if self.sessionState == .cancelled {
                self.sessionState = .idle
            }
        }
    }

    /// Clear any terminal state (declined / expired / approved) and return to idle.
    public func resetToIdle() {
        cancellables.removeAll()
        sessionState = .idle
        errorMessage = nil
    }

    // MARK: - Private Helpers

    private func observeUpdates(requestId: String) {
        cancellables.removeAll()

        observeRequestUseCase.execute(requestId: requestId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                self?.handle(status: status, requestId: requestId)
            }
            .store(in: &cancellables)
    }

    private func handle(status: InstantMeetingStatus, requestId: String) {
        switch status {
        case .pending:
            // Still waiting — keep state as-is.
            break

        case .accepted:
            cancellables.removeAll()
            fetchFreshCredentials(requestId: requestId)

        case .declined(let reason):
            cancellables.removeAll()
            sessionState = .declined(reason: reason)
            scheduleIdleReset()

        case .cancelled:
            cancellables.removeAll()
            sessionState = .cancelled
            scheduleIdleReset()

        case .expired:
            cancellables.removeAll()
            sessionState = .expired
            scheduleIdleReset()

        case .ended:
            cancellables.removeAll()
            sessionState = .idle
        }
    }

    private func fetchFreshCredentials(requestId: String) {
        Task { [weak self] in
            guard let self else { return }

            do {
                let credentials = try await getFreshAgoraTokenUseCase.execute(requestId: requestId)
                guard self.isWaitingForApproval(requestId: requestId) else { return }
                self.sessionState = .approved(
                    requestId: requestId,
                    channelName: credentials.channelName,
                    agoraToken: credentials.token,
                    userAccount: credentials.userAccount
                )
            } catch {
                guard self.isWaitingForApproval(requestId: requestId) else { return }
                self.sessionState = .idle
                self.errorMessage = error.localizedDescription
            }
        }
    }

    private func isWaitingForApproval(requestId: String) -> Bool {
        guard case .waitingForApproval(let pendingRequestId) = sessionState else {
            return false
        }
        return pendingRequestId == requestId
    }

    /// After a terminal non-approved state, reset back to idle after 3 seconds.
    private func scheduleIdleReset() {
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if case .waitingForApproval = self.sessionState { return } // guard re-request
            switch self.sessionState {
            case .declined, .cancelled, .expired:
                self.sessionState = .idle
            default:
                break
            }
        }
    }
}
