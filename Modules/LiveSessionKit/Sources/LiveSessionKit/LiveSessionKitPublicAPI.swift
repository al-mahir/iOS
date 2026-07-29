//
//  LiveSessionKitPublicAPI.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import AgoraKit
import RealtimeKit
import NetworkKit

/// Public entry point for `LiveSessionKit`.
/// - Parameters:
///   - circleId: Unique identifier for the live circle session.
///   - channelName: Agora channel name.
///   - agoraToken: Valid Agora RTC token.
///   - uid: Numeric user ID of the local participant.
///   - isHost: `true` if the local user is the session host.
///   - onLeft: Callback invoked after voluntary leave cleanup completes.
///   - onSessionEnded: Callback invoked after session end (by host or backend) cleanup completes.
/// - Returns: Self-contained SwiftUI `CallScreenView`.
@MainActor public func startLiveSession(
    circleId: String,
    channelName: String,
    agoraToken: String,
    uid: Int,
    isHost: Bool,
    agoraManager: AgoraSessionManaging? = nil,
    realtimeClient: RealtimeConnecting? = nil,
    networkService: NetworkServiceProtocol? = nil,
    onLeft: @escaping () -> Void,
    onSessionEnded: @escaping () -> Void
) -> some View {
    let agora = agoraManager ?? AgoraSession(appId: "DYNAMIC_APP_ID")
    let network = networkService ?? NetworkService.shared
    
    let remoteDataSource = LiveSessionRemoteDataSource(networkService: network)
    
    // If a RealtimeConnecting implementation is supplied or created
    let socketClient = realtimeClient ?? DummyRealtimeClient()
    let socketDataSource = LiveSessionSocketDataSource(realtimeClient: socketClient)

    let repository = LiveSessionRepositoryImpl(
        agoraManager: agora,
        socketDataSource: socketDataSource,
        remoteDataSource: remoteDataSource
    )

    let joinUseCase = JoinLiveSessionUseCase(repository: repository)
    let leaveUseCase = LeaveLiveSessionUseCase(repository: repository)
    let endUseCase = EndLiveSessionUseCase(repository: repository)
    let observeParticipantsUseCase = ObserveParticipantsUseCase(repository: repository)
    let observeSessionEndedUseCase = ObserveSessionEndedUseCase(repository: repository)
    let handleTokenRenewalUseCase = HandleTokenRenewalUseCase(repository: repository)

    let viewModel = CallScreenViewModel(
        circleId: circleId,
        channelName: channelName,
        agoraToken: agoraToken,
        uid: uid,
        isHost: isHost,
        joinUseCase: joinUseCase,
        leaveUseCase: leaveUseCase,
        endUseCase: endUseCase,
        observeParticipantsUseCase: observeParticipantsUseCase,
        observeSessionEndedUseCase: observeSessionEndedUseCase,
        handleTokenRenewalUseCase: handleTokenRenewalUseCase,
        repository: repository,
        onLeft: onLeft,
        onSessionEnded: onSessionEnded
    )

    return CallScreenView(viewModel: viewModel)
}

// Fallback dummy for RealtimeClient when none provided
private final class DummyRealtimeClient: RealtimeConnecting, @unchecked Sendable {
    var connectionStatePublisher: AnyPublisher<RealtimeConnectionState, Never> {
        Just(.disconnected).eraseToAnyPublisher()
    }
    var currentState: RealtimeConnectionState { .disconnected }
    var didReconnectPublisher: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }
    func connect(url: URL, authToken: String) async throws {}
    func disconnect() async {}
    func subscribe(topic: String) -> AnyPublisher<RealtimeEventEnvelope, Never> {
        Empty().eraseToAnyPublisher()
    }
    func stream(for topic: String) -> AsyncStream<RealtimeEventEnvelope> {
        AsyncStream { $0.finish() }
    }
    func unsubscribe(topic: String) {}
}
