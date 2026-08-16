import XCTest
import Combine
import RealtimeKit
@testable import Sheikh

final class SheikhTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testGetSheikhsUseCaseReturnsSheikhs() throws {
        let repo = SheikhRepositoryImpl()
        let useCase = GetSheikhsUseCase(repository: repo)
        let expectation = XCTestExpectation(description: "Fetch sheikhs")

        useCase.execute()
            .sink { completion in
                if case .failure(let err) = completion {
                    XCTFail("Failed with error: \(err)")
                }
            } receiveValue: { sheikhs in
                XCTAssertFalse(sheikhs.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    func testGetSheikhDetailUseCaseReturnsDetailedSheikh() throws {
        let repo = SheikhRepositoryImpl()
        let useCase = GetSheikhDetailUseCase(repository: repo)
        let expectation = XCTestExpectation(description: "Fetch sheikh detail")

        useCase.execute(id: "00000000-0000-0000-0000-000000000000")
            .sink { completion in
                if case .failure(let err) = completion {
                    XCTFail("Failed with error: \(err)")
                }
            } receiveValue: { sheikh in
                XCTAssertEqual(sheikh.firstName, "Sheikh Ahmed")
                XCTAssertEqual(sheikh.lastName, "Karimi")
                XCTAssertTrue(sheikh.hasVerifiedIjazah)
                XCTAssertFalse(sheikh.packages.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 3.0)
    }

    @MainActor
    func testSheikhDetailViewModelTabsAndFavorite() throws {
        let repo = SheikhRepositoryImpl()
        let getDetailUseCase = GetSheikhDetailUseCase(repository: repo)
        let toggleFavUseCase = ToggleFavoriteSheikhUseCase(repository: repo)

        let vm = SheikhDetailViewModel(
            sheikhID: "00000000-0000-0000-0000-000000000000",
            prefetched: nil,
            getSheikhDetailUseCase: getDetailUseCase,
            toggleFavoriteUseCase: toggleFavUseCase
        )

        XCTAssertEqual(vm.selectedTab, .about)
        vm.selectedTab = .reviews
        XCTAssertEqual(vm.selectedTab, .reviews)

        let initialFav = vm.sheikh?.isFavorite ?? false
        vm.toggleFavorite()
        XCTAssertNotEqual(vm.sheikh?.isFavorite, initialFav)
    }

    @MainActor
    func testSheikhListViewModelToggleFavorite() throws {
        let repo = SheikhRepositoryImpl()
        let getSheikhsUseCase = GetSheikhsUseCase(repository: repo)
        let toggleFavUseCase = ToggleFavoriteSheikhUseCase(repository: repo)

        let vm = SheikhListViewModel(
            getSheikhsUseCase: getSheikhsUseCase,
            toggleFavoriteUseCase: toggleFavUseCase
        )

        let sheikh = Sheikh.dummyTestSheikh
        vm.allSheikhs = [sheikh]
        let initialFav = sheikh.isFavorite

        vm.toggleFavorite(sheikh: sheikh)
        XCTAssertNotEqual(vm.displayedSheikhs.first?.isFavorite, initialFav)
    }

    func testMeetingRequestSubscriptionConnectsBeforeReceivingApproval() async {
        let realtimeClient = RealtimeClientSpy()
        let socketURL = try! XCTUnwrap(URL(string: "wss://example.com/ws/websocket"))
        let dataSource = InstantMeetingsRealtimeDataSource(
            realtimeClient: realtimeClient,
            accessTokenProvider: { "access-token" },
            socketURL: socketURL
        )
        let connected = expectation(description: "socket connected")
        let accepted = expectation(description: "accepted event received")
        realtimeClient.onConnect = { connected.fulfill() }

        dataSource.subscribeToRequestTopic(requestId: "request-id")
            .sink { event in
                guard case .accepted(let response) = event else { return }
                XCTAssertEqual(response.requestId, "request-id")
                accepted.fulfill()
            }
            .store(in: &cancellables)

        await fulfillment(of: [connected], timeout: 1)
        XCTAssertEqual(realtimeClient.subscribedTopics, ["/topic/meeting-requests/request-id"])
        XCTAssertEqual(realtimeClient.connectedURL, socketURL)
        XCTAssertEqual(realtimeClient.connectedToken, "access-token")

        let response = AcceptResponseDTO(
            status: "ACCEPTED",
            requestId: "request-id",
            channelName: "meeting-channel",
            agoraToken: "student-token",
            userAccount: "student-account"
        )
        realtimeClient.events.send(
            RealtimeEventEnvelope(
                eventType: "REQUEST_ACCEPTED",
                payload: try! JSONEncoder().encode(response)
            )
        )

        await fulfillment(of: [accepted], timeout: 1)
    }

    @MainActor
    func testAcceptedMeetingRequestRetainsRequestIDForLiveSession() async {
        let requestID = "request-id"
        let observer = ObserveMeetingRequestUseCaseSpy()
        let viewModel = PrivateSessionViewModel(
            sheikhID: "sheikh-id",
            getAvailabilityUseCase: GetAvailabilityUseCaseSpy(),
            sendRequestUseCase: SendMeetingRequestUseCaseSpy(requestID: requestID),
            cancelRequestUseCase: CancelMeetingRequestUseCaseSpy(),
            observeRequestUseCase: observer
        )
        let waiting = expectation(description: "request subscription started")
        let approved = expectation(description: "session approved")

        viewModel.$sessionState
            .dropFirst()
            .sink { state in
                if case .waitingForApproval(let waitingRequestID) = state {
                    XCTAssertEqual(waitingRequestID, requestID)
                    waiting.fulfill()
                    return
                }

                guard case .approved(let approvedRequestID, let channel, let token, let account) = state else {
                    return
                }
                XCTAssertEqual(approvedRequestID, requestID)
                XCTAssertEqual(channel, "meeting-channel")
                XCTAssertEqual(token, "student-token")
                XCTAssertEqual(account, "student-account")
                approved.fulfill()
            }
            .store(in: &cancellables)

        viewModel.requestSession()
        await fulfillment(of: [waiting], timeout: 1)
        observer.statuses.send(
            .accepted(
                channelName: "meeting-channel",
                agoraToken: "student-token",
                userAccount: "student-account"
            )
        )

        await fulfillment(of: [approved], timeout: 1)
    }
}

private final class RealtimeClientSpy: RealtimeConnecting, @unchecked Sendable {
    let states = CurrentValueSubject<RealtimeConnectionState, Never>(.disconnected)
    let events = PassthroughSubject<RealtimeEventEnvelope, Never>()
    var subscribedTopics: [String] = []
    var connectedURL: URL?
    var connectedToken: String?
    var onConnect: (() -> Void)?

    var connectionStatePublisher: AnyPublisher<RealtimeConnectionState, Never> {
        states.eraseToAnyPublisher()
    }

    var currentState: RealtimeConnectionState { states.value }

    var didReconnectPublisher: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    func connect(url: URL, authToken: String) async throws {
        connectedURL = url
        connectedToken = authToken
        states.send(.connected)
        onConnect?()
    }

    func disconnect() async {
        states.send(.disconnected)
    }

    func subscribe(topic: String) -> AnyPublisher<RealtimeEventEnvelope, Never> {
        subscribedTopics.append(topic)
        return events.eraseToAnyPublisher()
    }

    func stream(for topic: String) -> AsyncStream<RealtimeEventEnvelope> {
        AsyncStream { $0.finish() }
    }

    func unsubscribe(topic: String) {}
}

private final class GetAvailabilityUseCaseSpy: GetSheikhAvailabilityUseCaseProtocol, @unchecked Sendable {
    func execute(sheikhId: String) async throws -> SheikhAvailability {
        SheikhAvailability(sheikhId: sheikhId, status: .available)
    }
}

private final class SendMeetingRequestUseCaseSpy: SendMeetingRequestUseCaseProtocol, @unchecked Sendable {
    private let requestID: String

    init(requestID: String) {
        self.requestID = requestID
    }

    func execute(sheikhId: String) async throws -> InstantMeetingRequest {
        InstantMeetingRequest(requestId: requestID, status: .pending)
    }
}

private final class CancelMeetingRequestUseCaseSpy: CancelMeetingRequestUseCaseProtocol, @unchecked Sendable {
    func execute(requestId: String) async throws {}
}

private final class ObserveMeetingRequestUseCaseSpy: ObserveMeetingRequestUseCaseProtocol, @unchecked Sendable {
    let statuses = PassthroughSubject<InstantMeetingStatus, Never>()

    func execute(requestId: String) -> AnyPublisher<InstantMeetingStatus, Never> {
        statuses.eraseToAnyPublisher()
    }
}
