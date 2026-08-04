//
//  CircleRepositoryProtocol.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation

public protocol CircleRepositoryProtocol: Sendable {

    // MARK: - Socket Connection
    func connectSocket(authToken: String) async throws

    func disconnectSocket() async

    var socketConnectionState: AnyPublisher<Bool, Never> { get }

    // MARK: - Socket Observations

    // Topic 1 — owner-only live pending-requests feed.
    func observeOwnerRequests(circleId: String) -> AnyPublisher<CircleSocketEvent, Never>

    // Topic 2 — the requesting member's own request-status updates.
    func observeMembershipStatus(membershipId: String) -> AnyPublisher<CircleSocketEvent, Never>

    // Topic 3 — circle-wide roster and lifecycle events.
    func observeCircleEvents(circleId: String) -> AnyPublisher<CircleSocketEvent, Never>

    // MARK: - REST — Circle CRUD

    func listCircles(
        params: ListCirclesParams,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<CircleModel>, CircleError>

    func createCircle(_ params: CreateCircleParams) -> AnyPublisher<CircleModel, CircleError>

    func getCircle(circleId: String) -> AnyPublisher<CircleModel, CircleError>

    func updateCircle(circleId: String, params: UpdateCircleParams)
        -> AnyPublisher<CircleModel, CircleError>

    func cancelCircle(circleId: String) -> AnyPublisher<Void, CircleError>

    // MARK: - REST — Lifecycle

    func startCircle(circleId: String) -> AnyPublisher<Void, CircleError>

    func endCircle(circleId: String) -> AnyPublisher<Void, CircleError>

    // MARK: - REST — Membership

    func joinCircle(circleId: String, password: String?) -> AnyPublisher<CircleMembership, CircleError>

    func leaveCircle(circleId: String) -> AnyPublisher<Void, CircleError>

    func approveJoinRequest(circleId: String, userId: String) -> AnyPublisher<CircleMember, CircleError>

    func rejectJoinRequest(circleId: String, userId: String) -> AnyPublisher<Void, CircleError>

    func removeMember(circleId: String, userId: String) -> AnyPublisher<Void, CircleError>

    // MARK: - REST — Lists

    func getMembers(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<CircleMember>, CircleError>

    func getPendingRequests(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<PendingJoinRequest>, CircleError>

    func getMyCircles(page: CirclePageRequest) -> AnyPublisher<CirclePage<CircleModel>, CircleError>

    // MARK: - REST — Agora

    func getAgoraToken(circleId: String) -> AnyPublisher<AgoraToken, CircleError>
}


// MARK: - Pagination Request

public struct CirclePageRequest: Sendable {
    public let page: Int
    public let size: Int

    public init(page: Int = 0, size: Int = 20) {
        self.page = page
        self.size = size
    }
}

// MARK: - Paginated Result

public struct CirclePage<T: Sendable>: Sendable {
    public let items: [T]
    public let totalElements: Int
    public let totalPages: Int
    public let currentPage: Int
    public let isFirst: Bool
    public let isLast: Bool

    public init(
        items: [T],
        totalElements: Int,
        totalPages: Int,
        currentPage: Int,
        isFirst: Bool,
        isLast: Bool
    ) {
        self.items = items
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.currentPage = currentPage
        self.isFirst = isFirst
        self.isLast = isLast
    }
}

// MARK: - Create / Update Requests

public struct CreateCircleParams: Sendable {
    public let name: String
    public let startDate: Date
    public let endDate: Date
    public let type: CircleType
    public let requiresApproval: Bool
    public let maxParticipants: Int
    public let password: String?

    public init(
        name: String,
        startDate: Date,
        endDate: Date,
        type: CircleType = .private,
        requiresApproval: Bool,
        maxParticipants: Int,
        password: String? = nil
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.type = type
        self.requiresApproval = requiresApproval
        self.maxParticipants = maxParticipants
        self.password = password
    }
}

public struct UpdateCircleParams: Sendable {
    public let name: String?
    public let startDate: Date?
    public let endDate: Date?

    public init(
        name: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
    }
}

public struct ListCirclesParams: Sendable {
    public let status: CircleStatus?
    public let sort: String

    public init(status: CircleStatus? = nil, sort: String = "startDate,ASC") {
        self.status = status
        self.sort = sort
    }
}
