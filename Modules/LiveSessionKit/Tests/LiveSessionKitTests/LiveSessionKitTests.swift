import Combine
import UIKit
import XCTest
import AgoraKit
import NetworkKit
import RealtimeKit
@testable import LiveSessionKit

final class LiveSessionKitTests: XCTestCase {
    func testExpiringAgoraTokenIsRefreshedWithInjectedProvider() async throws {
        let renewalExpectation = expectation(description: "Agora token renewed")
        let agora = AgoraSessionSpy()
        agora.onRenewToken = { token in
            XCTAssertEqual(token, "fresh-token")
            renewalExpectation.fulfill()
        }

        let repository = LiveSessionRepositoryImpl(
            agoraManager: agora,
            socketDataSource: LiveSessionSocketDataSourceSpy(),
            remoteDataSource: LiveSessionRemoteDataSourceSpy(),
            tokenRefreshProvider: FixedAgoraTokenRefreshProvider(token: "fresh-token")
        )

        try await repository.joinSession(
            circleId: "circle-id",
            channelName: "circle_channel",
            agoraToken: "expiring-token",
            uid: 42
        )

        agora.onTokenPrivilegeWillExpire?("expiring-token")
        await fulfillment(of: [renewalExpectation], timeout: 1)
    }

    func testAccountBoundAgoraTokenJoinsWithItsIssuedUserAccount() async throws {
        let agora = AgoraSessionSpy()
        let repository = LiveSessionRepositoryImpl(
            agoraManager: agora,
            socketDataSource: LiveSessionSocketDataSourceSpy(),
            remoteDataSource: LiveSessionRemoteDataSourceSpy()
        )

        try await repository.joinSession(
            circleId: "circle-id",
            channelName: "circle_channel",
            agoraToken: "account-token",
            uid: 0,
            userAccount: "host-account"
        )

        XCTAssertEqual(agora.joinedUserAccount, "host-account")
    }
}

private struct FixedAgoraTokenRefreshProvider: AgoraTokenRefreshProvider {
    let token: String

    func refreshToken() async throws -> String { token }
}

private final class AgoraSessionSpy: AgoraSessionManaging, @unchecked Sendable {
    private let connectionState = CurrentValueSubject<AgoraConnectionState, Never>(.disconnected)
    private let remoteEvents = PassthroughSubject<AgoraRemoteUserEvent, Never>()

    var connectionStatePublisher: AnyPublisher<AgoraConnectionState, Never> {
        connectionState.eraseToAnyPublisher()
    }
    var remoteUserEventsPublisher: AnyPublisher<AgoraRemoteUserEvent, Never> {
        remoteEvents.eraseToAnyPublisher()
    }
    var onTokenPrivilegeWillExpire: ((String) -> Void)?
    var currentConnectionState: AgoraConnectionState { .disconnected }
    var onRenewToken: ((String) -> Void)?
    private(set) var joinedUserAccount: String?

    func requestMediaPermissions(includeVideo: Bool) async -> AgoraMediaPermissionResult {
        AgoraMediaPermissionResult(microphoneStatus: .authorized)
    }
    func join(channelName: String, token: String, uid: Int) async throws {}
    func join(channelName: String, token: String, userAccount: String) async throws {
        joinedUserAccount = userAccount
    }
    func leave() async throws {}
    func renewToken(_ token: String) { onRenewToken?(token) }
    func muteLocalAudio(_ muted: Bool) {}
    func enableLocalVideo(_ enabled: Bool) {}
    func setupLocalVideoCanvas(_ view: UIView) -> Bool { true }
    func setupRemoteVideoCanvas(_ view: UIView, forUid uid: Int) -> Bool { true }
}

private final class LiveSessionSocketDataSourceSpy: LiveSessionSocketDataSourceProtocol, @unchecked Sendable {
    var didReconnectPublisher: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    func subscribeToCircleTopic(circleId: String) -> AnyPublisher<RealtimeEventEnvelope, Never> {
        Empty().eraseToAnyPublisher()
    }

    func unsubscribeFromCircleTopic(circleId: String) {}
}

private final class LiveSessionRemoteDataSourceSpy: LiveSessionRemoteDataSourceProtocol, @unchecked Sendable {
    func leaveSession(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func endSession(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func getParticipants(circleId: String) -> AnyPublisher<[ParticipantDTO], NetworkError> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }

    func getCircleDetail(circleId: String) -> AnyPublisher<CircleDetailDTO, NetworkError> {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
