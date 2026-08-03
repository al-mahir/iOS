//
//  CallScreenViewModel.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine
import SwiftUI
import AgoraKit

@MainActor
public final class CallScreenViewModel: ObservableObject {
    @Published public var participants: [SessionParticipant] = []
    @Published public var connectionState: AgoraConnectionState = .disconnected
    @Published public var isMuted: Bool = false
    @Published public var isVideoEnabled: Bool = false
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var sessionEndedNotice: String?

    public let circleId: String
    public let channelName: String
    public let agoraToken: String
    public let uid: Int
    public let isHost: Bool

    private let joinUseCase: JoinLiveSessionUseCaseProtocol
    private let leaveUseCase: LeaveLiveSessionUseCaseProtocol
    private let endUseCase: EndLiveSessionUseCaseProtocol
    private let observeParticipantsUseCase: ObserveParticipantsUseCaseProtocol
    private let observeSessionEndedUseCase: ObserveSessionEndedUseCaseProtocol
    private let handleTokenRenewalUseCase: HandleTokenRenewalUseCaseProtocol
    private let repository: LiveSessionRepositoryProtocol

    private let onLeft: () -> Void
    private let onSessionEnded: () -> Void

    private var cancellables = Set<AnyCancellable>()

    public init(
        circleId: String,
        channelName: String,
        agoraToken: String,
        uid: Int,
        isHost: Bool,
        joinUseCase: JoinLiveSessionUseCaseProtocol,
        leaveUseCase: LeaveLiveSessionUseCaseProtocol,
        endUseCase: EndLiveSessionUseCaseProtocol,
        observeParticipantsUseCase: ObserveParticipantsUseCaseProtocol,
        observeSessionEndedUseCase: ObserveSessionEndedUseCaseProtocol,
        handleTokenRenewalUseCase: HandleTokenRenewalUseCaseProtocol,
        repository: LiveSessionRepositoryProtocol,
        onLeft: @escaping () -> Void,
        onSessionEnded: @escaping () -> Void
    ) {
        self.circleId = circleId
        self.channelName = channelName
        self.agoraToken = agoraToken
        self.uid = uid
        self.isHost = isHost
        self.joinUseCase = joinUseCase
        self.leaveUseCase = leaveUseCase
        self.endUseCase = endUseCase
        self.observeParticipantsUseCase = observeParticipantsUseCase
        self.observeSessionEndedUseCase = observeSessionEndedUseCase
        self.handleTokenRenewalUseCase = handleTokenRenewalUseCase
        self.repository = repository
        self.onLeft = onLeft
        self.onSessionEnded = onSessionEnded
    }

    public func joinSession() {
        isLoading = true
        errorMessage = nil

        subscribeToState()

        Task {
            do {
                try await joinUseCase.execute(
                    circleId: circleId,
                    channelName: channelName,
                    agoraToken: agoraToken,
                    uid: uid
                )
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    public func leaveSession() {
        isLoading = true
        Task {
            do {
                try await leaveUseCase.execute(circleId: circleId)
                self.isLoading = false
                self.onLeft()
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                // Still invoke callback if connection was torn down
                self.onLeft()
            }
        }
    }

    public func endSession() {
        guard isHost else {
            errorMessage = LiveSessionError.notHost.localizedDescription
            return
        }

        isLoading = true
        Task {
            do {
                try await endUseCase.execute(circleId: circleId, isHost: isHost)
                self.isLoading = false
                self.onSessionEnded()
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.onSessionEnded()
            }
        }
    }

    public func toggleMute() {
        isMuted.toggle()
        repository.muteLocalAudio(isMuted)
    }

    public func toggleVideo() {
        isVideoEnabled.toggle()
        repository.enableLocalVideo(isVideoEnabled)
    }

    private func subscribeToState() {
        observeParticipantsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .assign(to: &$participants)

        repository.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)

        observeSessionEndedUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.sessionEndedNotice = "This session has been ended by the host."
                Task {
                    try? await self.leaveUseCase.execute(circleId: self.circleId)
                    self.onSessionEnded()
                }
            }
            .store(in: &cancellables)
    }
}
