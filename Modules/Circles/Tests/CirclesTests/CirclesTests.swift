import Combine
import XCTest
@testable import Circles

@MainActor
final class CirclesTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testPrivateEndpointsMatchConfirmedContract() {
        let list = CircleEndpoints.privateMine
        XCTAssertEqual(list.path, "circles/mine/private")
        XCTAssertEqual(list.method.rawValue, "GET")
        XCTAssertNil(list.parameters)

        let join = CircleEndpoints.joinPrivate(token: "6c7f70")
        XCTAssertEqual(join.path, "circles/join/6c7f70")
        XCTAssertEqual(join.method.rawValue, "POST")
        XCTAssertNil(join.parameters)

        let publicJoin = CircleEndpoints.join(circleId: "circle-id")
        XCTAssertEqual(publicJoin.path, "circles/circle-id/join")
        XCTAssertEqual(publicJoin.method.rawValue, "POST")
        XCTAssertNil(publicJoin.parameters)
    }

    func testCircleDTOMapsNullableInviteToken() throws {
        let data = Data("""
        {
          "circleId": "circle-id",
          "title": "Private Circle",
          "startDate": "2026-08-15T06:46:12.415",
          "endDate": "2026-08-15T07:46:12.415",
          "status": "SCHEDULED",
          "type": "PRIVATE",
          "requiresApproval": true,
          "maxParticipants": 10,
          "channelName": "circle_channel",
          "ownerId": "owner-id",
          "memberCount": 0,
          "inviteToken": null
        }
        """.utf8)

        let circle = try JSONDecoder().decode(CircleDTO.self, from: data).toDomain()

        XCTAssertEqual(circle.type, .private)
        XCTAssertNil(circle.inviteToken)
    }

    func testPasswordGeneratorProducesSixDigits() {
        let password = PrivateCirclePasswordGenerator.generate()

        XCTAssertEqual(password.count, 6)
        XCTAssertTrue(password.allSatisfy(\.isNumber))
    }

    func testCreateUseCaseSuppliesGeneratedPasswordToRepository() {
        let repository = CircleRepositorySpy()
        let useCase = CreateCircleUseCase(
            repository: repository,
            passwordGenerator: { "654321" }
        )

        useCase.execute(createParams)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        XCTAssertEqual(repository.createdPassword, "654321")
    }

    func testPrivateCirclesViewModelValidatesEmptyToken() {
        let repository = CircleRepositorySpy()
        let viewModel = makePrivateCirclesViewModel(repository: repository)

        viewModel.joinWithToken()

        XCTAssertEqual(viewModel.privateTokenError, "Please enter an invite token.")
        XCTAssertFalse(viewModel.isJoiningWithToken)
    }

    func testPrivateCirclesViewModelFetchesAndFiltersPrivateCircles() async {
        let repository = CircleRepositorySpy()
        repository.privateCirclesResult = .success(
            CirclePage(
                items: [circle(name: "Tajweed"), circle(name: "Quran Study")],
                totalElements: 2,
                totalPages: 1,
                currentPage: 0,
                isFirst: true,
                isLast: true
            )
        )
        let viewModel = makePrivateCirclesViewModel(repository: repository)
        let loaded = expectation(description: "private circles loaded")

        viewModel.$circles
            .dropFirst()
            .sink { circles in
                if circles.count == 2 { loaded.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.fetchCircles()
        await fulfillment(of: [loaded], timeout: 1)

        viewModel.searchQuery = "taj"
        XCTAssertEqual(viewModel.circles.map(\.name), ["Tajweed"])
    }

    func testPrivateJoinUsesTokenAndPresentsApprovalFlow() async {
        let repository = CircleRepositorySpy()
        repository.privateJoinResult = .success(pendingMembership)
        repository.circleResult = .success(circle())
        let viewModel = makePrivateCirclesViewModel(repository: repository)
        let joined = expectation(description: "private join result")

        viewModel.$pendingPrivateJoin
            .compactMap { $0 }
            .sink { _ in joined.fulfill() }
            .store(in: &cancellables)

        viewModel.privateToken = "6c7f70"
        viewModel.joinWithToken()
        await fulfillment(of: [joined], timeout: 1)

        XCTAssertEqual(repository.joinedPrivateToken, "6c7f70")
        XCTAssertEqual(viewModel.pendingPrivateJoin?.membership.status, .pending)
    }

    func testActiveMembershipPreparesLiveSessionWithServerToken() async {
        let repository = CircleRepositorySpy()
        repository.agoraTokenResult = .success(
            AgoraToken(token: "agora-token", uid: 42, channelName: "circle_channel")
        )
        let tokenUseCase = GetAgoraTokenUseCase(repository: repository)
        let viewModel = JoinCircleViewModel(
            circle: circle(),
            joinCircleUseCase: JoinCircleUseCase(repository: repository),
            leaveCircleUseCase: LeaveCircleUseCase(repository: repository),
            getAgoraTokenUseCase: tokenUseCase,
            repository: repository,
            accessTokenProvider: { "access-token" },
            tokenRefreshProvider: CircleAgoraTokenRefreshProvider(
                circleId: "circle-id",
                getAgoraTokenUseCase: tokenUseCase
            )
        )
        let prepared = expectation(description: "live session prepared")

        viewModel.$liveSessionDestination
            .compactMap { $0 }
            .sink { _ in prepared.fulfill() }
            .store(in: &cancellables)

        viewModel.startPendingWithMembership(activeMembership)
        await fulfillment(of: [prepared], timeout: 1)

        XCTAssertEqual(viewModel.liveSessionDestination?.agoraToken.uid, 42)
        XCTAssertEqual(repository.agoraTokenCircleID, "circle-id")
    }

    func testApprovalEventPreparesLiveSessionForPendingPrivateJoin() async {
        let repository = CircleRepositorySpy()
        repository.agoraTokenResult = .success(
            AgoraToken(token: "agora-token", uid: 42, channelName: "circle_channel")
        )
        let tokenUseCase = GetAgoraTokenUseCase(repository: repository)
        let viewModel = JoinCircleViewModel(
            circle: circle(),
            joinCircleUseCase: JoinCircleUseCase(repository: repository),
            leaveCircleUseCase: LeaveCircleUseCase(repository: repository),
            getAgoraTokenUseCase: tokenUseCase,
            repository: repository,
            accessTokenProvider: { "access-token" },
            tokenRefreshProvider: CircleAgoraTokenRefreshProvider(
                circleId: "circle-id",
                getAgoraTokenUseCase: tokenUseCase
            )
        )
        let prepared = expectation(description: "meeting is prepared after approval")

        viewModel.$liveSessionDestination
            .compactMap { $0 }
            .sink { _ in prepared.fulfill() }
            .store(in: &cancellables)

        viewModel.startPendingWithMembership(pendingMembership)
        repository.membershipEvents.send(
            .requestApproved(
                CircleMember(
                    id: "user-id",
                    username: "User",
                    status: .active,
                    joinedAt: Date()
                )
            )
        )
        await fulfillment(of: [prepared], timeout: 1)

        XCTAssertEqual(viewModel.liveSessionDestination?.agoraToken.token, "agora-token")
    }

    private var createParams: CreateCircleParams {
        CreateCircleParams(
            name: "Private Circle",
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            requiresApproval: true,
            maxParticipants: 10
        )
    }

    private var pendingMembership: CircleMembership {
        CircleMembership(
            membershipId: "membership-id",
            circleId: "circle-id",
            userId: "user-id",
            status: .pending,
            requestedAt: Date()
        )
    }

    private var activeMembership: CircleMembership {
        CircleMembership(
            membershipId: "membership-id",
            circleId: "circle-id",
            userId: "user-id",
            status: .active,
            requestedAt: Date()
        )
    }

    private func makePrivateCirclesViewModel(
        repository: CircleRepositorySpy
    ) -> PrivateCirclesViewModel {
        PrivateCirclesViewModel(
            getPrivateCirclesUseCase: GetPrivateCirclesUseCase(repository: repository),
            joinPrivateCircleUseCase: JoinPrivateCircleUseCase(repository: repository),
            getCircleUseCase: GetCircleUseCase(repository: repository)
        )
    }

    private func circle(name: String = "Private Circle") -> CircleModel {
        CircleModel(
            id: "circle-id",
            name: name,
            startDate: Date(),
            endDate: Date().addingTimeInterval(3600),
            status: .scheduled,
            type: .private,
            requiresApproval: true,
            maxParticipants: 10,
            channelName: "circle_channel",
            ownerId: "owner-id",
            memberCount: 0,
            inviteToken: "6c7f70"
        )
    }
}

private final class CircleRepositorySpy: CircleRepositoryProtocol, @unchecked Sendable {
    var privateCirclesResult: Result<CirclePage<CircleModel>, CircleError> = .success(
        CirclePage(items: [], totalElements: 0, totalPages: 0, currentPage: 0, isFirst: true, isLast: true)
    )
    var privateJoinResult: Result<CircleMembership, CircleError> = .failure(.unknown("Not configured"))
    var circleResult: Result<CircleModel, CircleError> = .failure(.unknown("Not configured"))
    var agoraTokenResult: Result<AgoraToken, CircleError> = .failure(.unknown("Not configured"))
    var createdPassword: String?
    var joinedPrivateToken: String?
    var agoraTokenCircleID: String?
    let membershipEvents = PassthroughSubject<CircleSocketEvent, Never>()

    var socketConnectionState: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func connectSocket(authToken: String) async throws {}
    func disconnectSocket() async {}
    func observeOwnerRequests(circleId: String) -> AnyPublisher<CircleSocketEvent, Never> { Empty().eraseToAnyPublisher() }
    func observeMembershipStatus(membershipId: String) -> AnyPublisher<CircleSocketEvent, Never> {
        membershipEvents.eraseToAnyPublisher()
    }
    func observeCircleEvents(circleId: String) -> AnyPublisher<CircleSocketEvent, Never> { Empty().eraseToAnyPublisher() }

    func listCircles(params: ListCirclesParams, page: CirclePageRequest) -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        resultPublisher(.success(emptyCirclePage))
    }

    func createCircle(_ params: CreateCircleParams, password: String) -> AnyPublisher<CircleModel, CircleError> {
        createdPassword = password
        return resultPublisher(.success(testCircle))
    }

    func getCircle(circleId: String) -> AnyPublisher<CircleModel, CircleError> { resultPublisher(circleResult) }
    func updateCircle(circleId: String, params: UpdateCircleParams) -> AnyPublisher<CircleModel, CircleError> { resultPublisher(.success(testCircle)) }
    func cancelCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func startCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func endCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func joinCircle(circleId: String) -> AnyPublisher<CircleMembership, CircleError> { resultPublisher(.failure(.unknown("Not configured"))) }

    func joinPrivateCircle(token: String) -> AnyPublisher<CircleMembership, CircleError> {
        joinedPrivateToken = token
        return resultPublisher(privateJoinResult)
    }

    func leaveCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func approveJoinRequest(circleId: String, userId: String) -> AnyPublisher<CircleMember, CircleError> { resultPublisher(.success(testMember)) }
    func rejectJoinRequest(circleId: String, userId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func removeMember(circleId: String, userId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func getMembers(circleId: String, page: CirclePageRequest) -> AnyPublisher<CirclePage<CircleMember>, CircleError> { resultPublisher(.success(emptyMemberPage)) }
    func getPendingRequests(circleId: String, page: CirclePageRequest) -> AnyPublisher<CirclePage<PendingJoinRequest>, CircleError> { resultPublisher(.success(emptyPendingPage)) }
    func getMyCircles(page: CirclePageRequest) -> AnyPublisher<CirclePage<CircleModel>, CircleError> { resultPublisher(.success(emptyCirclePage)) }
    func getPrivateCircles() -> AnyPublisher<CirclePage<CircleModel>, CircleError> { resultPublisher(privateCirclesResult) }

    func getAgoraToken(circleId: String) -> AnyPublisher<AgoraToken, CircleError> {
        agoraTokenCircleID = circleId
        return resultPublisher(agoraTokenResult)
    }

    private var testCircle: CircleModel {
        CircleModel(
            id: "circle-id", name: "Private Circle", startDate: Date(),
            endDate: Date().addingTimeInterval(3600), status: .scheduled,
            type: .private, requiresApproval: true, maxParticipants: 10,
            channelName: "circle_channel", ownerId: "owner-id", memberCount: 0,
            inviteToken: "6c7f70"
        )
    }

    var testMember: CircleMember {
        CircleMember(id: "user-id", username: "User", status: .active, joinedAt: Date())
    }

    private var emptyCirclePage: CirclePage<CircleModel> {
        CirclePage(items: [], totalElements: 0, totalPages: 0, currentPage: 0, isFirst: true, isLast: true)
    }

    private var emptyMemberPage: CirclePage<CircleMember> {
        CirclePage(items: [], totalElements: 0, totalPages: 0, currentPage: 0, isFirst: true, isLast: true)
    }

    private var emptyPendingPage: CirclePage<PendingJoinRequest> {
        CirclePage(items: [], totalElements: 0, totalPages: 0, currentPage: 0, isFirst: true, isLast: true)
    }
}

private func resultPublisher<T>(
    _ result: Result<T, CircleError>
) -> AnyPublisher<T, CircleError> {
    result.publisher.eraseToAnyPublisher()
}
