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

    func testUpdateEndpointMatchesConfirmedContract() throws {
        let startDate = Date(timeIntervalSince1970: 1_755_271_576)
        let endDate = startDate.addingTimeInterval(3600)
        let endpoint = CircleEndpoints.makeUpdate(
            circleId: "circle-id",
            params: UpdateCircleParams(
                name: "Updated Circle",
                startDate: startDate,
                endDate: endDate
            )
        )

        XCTAssertEqual(endpoint.path, "circles/circle-id")
        XCTAssertEqual(endpoint.method.rawValue, "PATCH")

        let parameters = try XCTUnwrap(endpoint.parameters)
        XCTAssertEqual(parameters["name"], "Updated Circle")
        XCTAssertNotNil(parameters["startDate"] as? String)
        XCTAssertNotNil(parameters["endDate"] as? String)
    }

    func testUpdateResponseMapsTitleWithoutInviteToken() throws {
        let data = Data("""
        {
          "circleId": "circle-id",
          "title": "Updated Circle",
          "startDate": "2026-08-15T15:26:16.511Z",
          "endDate": "2026-08-15T16:26:16.511Z",
          "status": "SCHEDULED",
          "type": "PRIVATE",
          "requiresApproval": true,
          "maxParticipants": 10,
          "channelName": "circle_channel",
          "ownerId": "owner-id",
          "memberCount": 0
        }
        """.utf8)

        let circle = try JSONDecoder().decode(CircleDTO.self, from: data).toDomain()

        XCTAssertEqual(circle.name, "Updated Circle")
        XCTAssertNil(circle.inviteToken)
    }

    func testAgoraTokenResponseMapsAccountBoundIdentityWithoutUID() throws {
        let data = Data("""
        {
          "token": "agora-token",
          "channelName": "circle_channel",
          "userAccount": "host-account"
        }
        """.utf8)

        let token = try JSONDecoder().decode(AgoraTokenDTO.self, from: data).toDomain()

        XCTAssertEqual(token.token, "agora-token")
        XCTAssertEqual(token.channelName, "circle_channel")
        XCTAssertEqual(token.userAccount, "host-account")
        XCTAssertEqual(token.uid, 0)
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
                items: [
                    circle(name: "Tajweed"),
                    circle(name: "Quran Study"),
                    circle(name: "Joined Circle", ownerID: "another-owner")
                ],
                totalElements: 3,
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

    func testPrivateCirclesViewModelStartsSelectedCircleAndPreparesHostSession() async {
        let repository = CircleRepositorySpy()
        repository.agoraTokenResult = .success(
            AgoraToken(token: "agora-token", uid: 42, channelName: "circle_channel")
        )
        let viewModel = makePrivateCirclesViewModel(repository: repository)
        let prepared = expectation(description: "host session prepared")

        viewModel.$liveSessionDestination
            .compactMap { $0 }
            .sink { _ in prepared.fulfill() }
            .store(in: &cancellables)

        viewModel.start(circle: circle())
        await fulfillment(of: [prepared], timeout: 1)

        XCTAssertEqual(repository.startedCircleIDs, ["circle-id"])
        XCTAssertEqual(viewModel.liveSessionDestination?.agoraToken.token, "agora-token")
    }

    func testPrivateCirclesViewModelDeletesSelectedScheduledCircle() async {
        let repository = CircleRepositorySpy()
        repository.privateCirclesResult = .success(
            CirclePage(
                items: [circle()], totalElements: 1, totalPages: 1,
                currentPage: 0, isFirst: true, isLast: true
            )
        )
        let viewModel = makePrivateCirclesViewModel(repository: repository)
        let loaded = expectation(description: "private circle loaded")

        viewModel.$circles
            .dropFirst()
            .sink { circles in
                if circles.count == 1 { loaded.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.fetchCircles()
        await fulfillment(of: [loaded], timeout: 1)
        viewModel.delete(circle: circle())

        XCTAssertEqual(repository.cancelledCircleIDs, ["circle-id"])
        XCTAssertTrue(viewModel.circles.isEmpty)
    }

    func testEditCircleViewModelReplacesOnlyUpdatedCircleFields() async {
        let repository = CircleRepositorySpy()
        repository.updatedCircleResult = .success(
            circle(name: "Updated Circle").replacing(inviteToken: nil)
        )
        let viewModel = EditCircleViewModel(
            circle: circle(),
            updateCircleUseCase: UpdateCircleUseCase(repository: repository)
        )
        let updated = expectation(description: "circle updated")

        viewModel.name = "Updated Circle"
        viewModel.save { result in
            XCTAssertEqual(result.name, "Updated Circle")
            updated.fulfill()
        }

        await fulfillment(of: [updated], timeout: 1)
    }

    func testReplacingEditedCirclePreservesExistingInviteToken() async {
        let repository = CircleRepositorySpy()
        repository.privateCirclesResult = .success(
            CirclePage(
                items: [circle()], totalElements: 1, totalPages: 1,
                currentPage: 0, isFirst: true, isLast: true
            )
        )
        let viewModel = makePrivateCirclesViewModel(repository: repository)
        let loaded = expectation(description: "private circle loaded")

        viewModel.$circles
            .dropFirst()
            .sink { circles in
                if circles.count == 1 { loaded.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.fetchCircles()
        await fulfillment(of: [loaded], timeout: 1)

        viewModel.replaceCircle(
            circle(name: "Updated Circle").replacing(inviteToken: nil)
        )

        XCTAssertEqual(viewModel.circles.first?.name, "Updated Circle")
        XCTAssertEqual(viewModel.circles.first?.inviteToken, "6c7f70")
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

    func testHostJoinRequestsLoadsPendingRequestsAndApprovesOne() async {
        let repository = CircleRepositorySpy()
        let request = PendingJoinRequest(
            userId: "requesting-user",
            username: "Requesting User",
            requestedAt: Date()
        )
        repository.pendingRequestsResult = .success(
            CirclePage(
                items: [request], totalElements: 1, totalPages: 1,
                currentPage: 0, isFirst: true, isLast: true
            )
        )
        let viewModel = makeHostJoinRequestsViewModel(repository: repository)
        let loaded = expectation(description: "pending request loaded")

        viewModel.$requests
            .dropFirst()
            .filter { $0 == [request] }
            .sink { _ in loaded.fulfill() }
            .store(in: &cancellables)

        viewModel.start()
        await viewModel.refreshRequests()
        await fulfillment(of: [loaded], timeout: 1)

        let removed = expectation(description: "approved request removed")
        viewModel.$requests
            .filter(\.isEmpty)
            .dropFirst()
            .sink { _ in removed.fulfill() }
            .store(in: &cancellables)

        viewModel.approve(request)
        await fulfillment(of: [removed], timeout: 1)

        XCTAssertEqual(repository.approvedRequests.count, 1)
        XCTAssertEqual(repository.approvedRequests.first?.0, "circle-id")
        XCTAssertEqual(repository.approvedRequests.first?.1, "requesting-user")
    }

    func testHostJoinRequestsRefreshRecoversRequestMissedBySocket() async {
        let repository = CircleRepositorySpy()
        let request = PendingJoinRequest(
            userId: "requesting-user",
            username: "Requesting User",
            requestedAt: Date()
        )
        let viewModel = makeHostJoinRequestsViewModel(repository: repository)

        viewModel.start()
        await viewModel.refreshRequests()
        XCTAssertTrue(viewModel.requests.isEmpty)

        repository.pendingRequestsResult = .success(
            CirclePage(
                items: [request], totalElements: 1, totalPages: 1,
                currentPage: 0, isFirst: true, isLast: true
            )
        )
        await viewModel.refreshRequests()

        XCTAssertEqual(viewModel.requests, [request])
    }

    func testHostJoinRequestsRefreshPreservesExistingRequestsOnFailure() async {
        let repository = CircleRepositorySpy()
        let request = PendingJoinRequest(
            userId: "requesting-user",
            username: "Requesting User",
            requestedAt: Date()
        )
        repository.pendingRequestsResult = .success(
            CirclePage(
                items: [request], totalElements: 1, totalPages: 1,
                currentPage: 0, isFirst: true, isLast: true
            )
        )
        let viewModel = makeHostJoinRequestsViewModel(repository: repository)

        viewModel.start()
        await viewModel.refreshRequests()
        repository.pendingRequestsResult = .failure(.unknown("Offline"))
        await viewModel.refreshRequests()

        XCTAssertEqual(viewModel.requests, [request])
        XCTAssertNotNil(viewModel.errorMessage)
    }

    func testHostJoinRequestsAddsRealtimeRequestToInbox() async {
        let repository = CircleRepositorySpy()
        let request = PendingJoinRequest(
            userId: "requesting-user",
            username: "Requesting User",
            requestedAt: Date()
        )
        let viewModel = makeHostJoinRequestsViewModel(repository: repository)
        let received = expectation(description: "realtime request received")

        viewModel.$requests
            .dropFirst()
            .filter { $0 == [request] }
            .sink { _ in received.fulfill() }
            .store(in: &cancellables)

        viewModel.start()
        repository.ownerRequestEvents.send(.joinRequestReceived(request))
        await fulfillment(of: [received], timeout: 1)

        XCTAssertEqual(viewModel.pendingCount, 1)
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
            getCircleUseCase: GetCircleUseCase(repository: repository),
            startCircleUseCase: StartCircleUseCase(repository: repository),
            getAgoraTokenUseCase: GetAgoraTokenUseCase(repository: repository),
            cancelCircleUseCase: CancelCircleUseCase(repository: repository),
            currentUserIDProvider: { "owner-id" }
        )
    }

    private func makeHostJoinRequestsViewModel(
        repository: CircleRepositorySpy
    ) -> HostJoinRequestsViewModel {
        HostJoinRequestsViewModel(
            circleID: "circle-id",
            getPendingRequestsUseCase: GetPendingRequestsUseCase(repository: repository),
            approveJoinRequestUseCase: ApproveJoinRequestUseCase(repository: repository),
            rejectJoinRequestUseCase: RejectJoinRequestUseCase(repository: repository),
            repository: repository,
            accessTokenProvider: { "access-token" }
        )
    }

    private func circle(
        name: String = "Private Circle",
        ownerID: String = "owner-id"
    ) -> CircleModel {
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
            ownerId: ownerID,
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
    var pendingRequestsResult: Result<CirclePage<PendingJoinRequest>, CircleError> = .success(
        CirclePage(items: [], totalElements: 0, totalPages: 0, currentPage: 0, isFirst: true, isLast: true)
    )
    var updatedCircleResult: Result<CircleModel, CircleError> = .success(testCircle)
    var cancelCircleResult: Result<Void, CircleError> = .success(())
    var startCircleResult: Result<Void, CircleError> = .success(())
    var createdPassword: String?
    var joinedPrivateToken: String?
    var agoraTokenCircleID: String?
    var startedCircleIDs: [String] = []
    var cancelledCircleIDs: [String] = []
    var approvedRequests: [(String, String)] = []
    var rejectedRequests: [(String, String)] = []
    let membershipEvents = PassthroughSubject<CircleSocketEvent, Never>()
    let ownerRequestEvents = PassthroughSubject<CircleSocketEvent, Never>()
    let socketConnectionStates = CurrentValueSubject<Bool, Never>(false)

    var socketConnectionState: AnyPublisher<Bool, Never> {
        socketConnectionStates.eraseToAnyPublisher()
    }

    func connectSocket(authToken: String) async throws {}
    func disconnectSocket() async {}
    func observeOwnerRequests(circleId: String) -> AnyPublisher<CircleSocketEvent, Never> {
        ownerRequestEvents.eraseToAnyPublisher()
    }
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
    func updateCircle(circleId: String, params: UpdateCircleParams) -> AnyPublisher<CircleModel, CircleError> { resultPublisher(updatedCircleResult) }
    func cancelCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        cancelledCircleIDs.append(circleId)
        return resultPublisher(cancelCircleResult)
    }
    func startCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        startedCircleIDs.append(circleId)
        return resultPublisher(startCircleResult)
    }
    func endCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func joinCircle(circleId: String) -> AnyPublisher<CircleMembership, CircleError> { resultPublisher(.failure(.unknown("Not configured"))) }

    func joinPrivateCircle(token: String) -> AnyPublisher<CircleMembership, CircleError> {
        joinedPrivateToken = token
        return resultPublisher(privateJoinResult)
    }

    func leaveCircle(circleId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func approveJoinRequest(circleId: String, userId: String) -> AnyPublisher<CircleMember, CircleError> {
        approvedRequests.append((circleId, userId))
        return resultPublisher(.success(testMember))
    }
    func rejectJoinRequest(circleId: String, userId: String) -> AnyPublisher<Void, CircleError> {
        rejectedRequests.append((circleId, userId))
        return resultPublisher(.success(()))
    }
    func removeMember(circleId: String, userId: String) -> AnyPublisher<Void, CircleError> { resultPublisher(.success(())) }
    func getMembers(circleId: String, page: CirclePageRequest) -> AnyPublisher<CirclePage<CircleMember>, CircleError> { resultPublisher(.success(emptyMemberPage)) }
    func getPendingRequests(circleId: String, page: CirclePageRequest) -> AnyPublisher<CirclePage<PendingJoinRequest>, CircleError> {
        resultPublisher(pendingRequestsResult)
    }
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
