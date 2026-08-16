import Combine
import XCTest
@testable import RealtimeKit

final class RealtimeKitTests: XCTestCase {
    func testConnectWaitsForStompHandshake() async throws {
        let transport = RealtimeTransportSpy()
        let client = RealtimeClient(transport: transport)
        let connectTask = Task<Void, Error> {
            try await client.connect(
                url: URL(string: "wss://example.com/ws")!,
                authToken: "access-token"
            )
        }

        await Task.yield()
        XCTAssertEqual(transport.connectCallCount, 1)
        XCTAssertEqual(client.currentState, .connecting)

        transport.simulateConnect()
        try await connectTask.value

        XCTAssertEqual(client.currentState, .connected)
    }

    func testSubscriptionsRegisteredBeforeHandshakeAreSentAfterConnect() async throws {
        let transport = RealtimeTransportSpy()
        let client = RealtimeClient(transport: transport)
        let subscription = client.subscribe(topic: "/topic/circle-memberships/membership-id")
            .sink { _ in }
        let connectTask = Task<Void, Error> {
            try await client.connect(
                url: URL(string: "wss://example.com/ws")!,
                authToken: "access-token"
            )
        }

        await Task.yield()
        transport.simulateConnect()
        try await connectTask.value

        XCTAssertEqual(
            transport.subscribedTopics,
            ["/topic/circle-memberships/membership-id"]
        )
        withExtendedLifetime(subscription) {}
    }

    func testConnectFailsWhenTransportReportsAuthenticationError() async {
        let transport = RealtimeTransportSpy()
        let client = RealtimeClient(transport: transport)
        let connectTask = Task<Void, Error> {
            try await client.connect(
                url: URL(string: "wss://example.com/ws")!,
                authToken: "access-token"
            )
        }

        await Task.yield()
        transport.simulateError(description: "Unauthorized", isAuthError: true)

        do {
            try await connectTask.value
            XCTFail("Expected the STOMP connection to fail")
        } catch let error as RealtimeError {
            XCTAssertEqual(error, .authenticationRejected)
            XCTAssertEqual(client.currentState, .failed(.authenticationRejected))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private final class RealtimeTransportSpy: RealtimeTransportProtocol {
    weak var delegate: RealtimeTransportDelegate?
    var autoReconnect = false
    private(set) var connectCallCount = 0
    private(set) var subscribedTopics: [String] = []

    func connect(url: URL, headers: [String: String]?) {
        connectCallCount += 1
    }

    func disconnect() {}
    func enableAutoPing(interval: TimeInterval) {}

    func subscribe(to topic: String) {
        subscribedTopics.append(topic)
    }

    func unsubscribe(from topic: String) {}

    func simulateConnect() {
        delegate?.transportDidConnect(isReconnect: false)
    }

    func simulateError(description: String, isAuthError: Bool) {
        delegate?.transportDidEncounterError(
            description: description,
            isAuthError: isAuthError
        )
    }
}
