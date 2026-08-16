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

    func testLeaveEndpointDoesNotDuplicateAPIVersion() {
        XCTAssertEqual(
            LiveSessionEndpoints.leave(circleId: "circle-id").path,
            "circles/circle-id/leave"
        )
    }

    func testAgoraJoinLeaveAndRejoinUpdateParticipants() async throws {
        let agora = AgoraSessionSpy()
        let repository = LiveSessionRepositoryImpl(
            agoraManager: agora,
            socketDataSource: LiveSessionSocketDataSourceSpy(),
            remoteDataSource: LiveSessionRemoteDataSourceSpy()
        )

        try await repository.joinSession(
            circleId: "circle-id",
            channelName: "circle_channel",
            agoraToken: "token",
            uid: 42
        )

        let joined = expectation(description: "Remote participant joined")
        let joinedObservation = repository.participantsPublisher
            .filter { $0.contains { $0.uid == 84 } }
            .prefix(1)
            .sink { _ in joined.fulfill() }

        agora.send(.joined(user: AgoraRemoteUser(uid: 84)))
        await fulfillment(of: [joined], timeout: 1)
        joinedObservation.cancel()

        let left = expectation(description: "Remote participant left")
        let leftObservation = repository.participantsPublisher
            .filter { !$0.contains { $0.uid == 84 } }
            .prefix(1)
            .sink { _ in left.fulfill() }

        agora.send(.left(uid: 84, reason: "User quit channel"))
        await fulfillment(of: [left], timeout: 1)
        leftObservation.cancel()

        let rejoined = expectation(description: "Remote participant rejoined")
        let rejoinedObservation = repository.participantsPublisher
            .filter { $0.contains { $0.uid == 84 } }
            .prefix(1)
            .sink { _ in rejoined.fulfill() }

        agora.send(.joined(user: AgoraRemoteUser(uid: 84)))
        await fulfillment(of: [rejoined], timeout: 1)
        rejoinedObservation.cancel()
    }

    func testSocketLeaveRemovesParticipantAndDuplicateLeaveIsHarmless() async throws {
        let socket = LiveSessionSocketDataSourceSpy()
        let repository = LiveSessionRepositoryImpl(
            agoraManager: AgoraSessionSpy(),
            socketDataSource: socket,
            remoteDataSource: LiveSessionRemoteDataSourceSpy()
        )

        try await repository.joinSession(
            circleId: "circle-id",
            channelName: "circle_channel",
            agoraToken: "token",
            uid: 42
        )

        let joined = expectation(description: "Socket participant joined")
        let joinedObservation = repository.participantsPublisher
            .filter { $0.contains { $0.uid == 84 } }
            .prefix(1)
            .sink { _ in joined.fulfill() }

        socket.send(try participantEnvelope(eventType: "PARTICIPANT_JOINED", uid: 84))
        await fulfillment(of: [joined], timeout: 1)
        joinedObservation.cancel()

        let left = expectation(description: "Socket participant left")
        let leftObservation = repository.participantsPublisher
            .filter { !$0.contains { $0.uid == 84 } }
            .prefix(1)
            .sink { _ in left.fulfill() }

        let leaveEnvelope = try participantEnvelope(eventType: "PARTICIPANT_LEFT", uid: 84)
        socket.send(leaveEnvelope)
        await fulfillment(of: [left], timeout: 1)
        leftObservation.cancel()

        let duplicateLeft = expectation(description: "Duplicate leave stayed removed")
        let duplicateLeftObservation = repository.participantsPublisher
            .dropFirst()
            .prefix(1)
            .sink { participants in
                XCTAssertFalse(participants.contains { $0.uid == 84 })
                duplicateLeft.fulfill()
            }

        socket.send(leaveEnvelope)
        await fulfillment(of: [duplicateLeft], timeout: 1)
        duplicateLeftObservation.cancel()
    }

    private func participantEnvelope(eventType: String, uid: Int) throws -> RealtimeEventEnvelope {
        RealtimeEventEnvelope(
            eventType: eventType,
            payload: try JSONEncoder().encode(ParticipantSocketEventDTO(uid: uid))
        )
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

    func send(_ event: AgoraRemoteUserEvent) {
        remoteEvents.send(event)
    }
}

private final class LiveSessionSocketDataSourceSpy: LiveSessionSocketDataSourceProtocol, @unchecked Sendable {
    private let events = PassthroughSubject<RealtimeEventEnvelope, Never>()

    var didReconnectPublisher: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    func subscribeToCircleTopic(circleId: String) -> AnyPublisher<RealtimeEventEnvelope, Never> {
        events.eraseToAnyPublisher()
    }

    func unsubscribeFromCircleTopic(circleId: String) {}

    func send(_ envelope: RealtimeEventEnvelope) {
        events.send(envelope)
    }
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
