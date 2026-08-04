//
//  CircleRepository.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation
import Combine
import NetworkKit

public final class CircleRepository: CircleRepositoryProtocol, @unchecked Sendable {

    private let remote: CircleRemoteDataSource
    private let socket: CircleSocketDataSource

    public init(
        remote: CircleRemoteDataSource = CircleRemoteDataSource(),
        socket: CircleSocketDataSource = CircleSocketDataSource()
    ) {
        self.remote = remote
        self.socket = socket
    }

    // MARK: - Socket Connection

    public func connectSocket(authToken: String) async throws {
        try await socket.connect(authToken: authToken)
    }

    public func disconnectSocket() async {
        await socket.disconnect()
    }

    public var socketConnectionState: AnyPublisher<Bool, Never> {
        socket.isConnected
    }

    // MARK: - Socket Observations

    public func observeCircleEvents(circleId: String) -> AnyPublisher<CircleSocketEvent, Never> {
        socket.observeCircleEvents(circleId: circleId)
    }

    public func observeOwnerRequests(circleId: String) -> AnyPublisher<CircleSocketEvent, Never> {
        socket.observeOwnerRequests(circleId: circleId)
    }

    public func observeMembershipStatus(membershipId: String) -> AnyPublisher<CircleSocketEvent, Never> {
        socket.observeMembershipStatus(membershipId: membershipId)
    }

    // MARK: - REST: Circle CRUD

    public func listCircles(
        params: ListCirclesParams,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        remote.listCircles(params: params, page: page)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func createCircle(_ params: CreateCircleParams) -> AnyPublisher<CircleModel, CircleError> {
        remote.createCircle(params)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func getCircle(circleId: String) -> AnyPublisher<CircleModel, CircleError> {
        remote.getCircle(circleId: circleId)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func updateCircle(
        circleId: String,
        params: UpdateCircleParams
    ) -> AnyPublisher<CircleModel, CircleError> {
        remote.updateCircle(circleId: circleId, params: params)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func cancelCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        remote.cancelCircle(circleId: circleId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - REST: Lifecycle

    public func startCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        remote.startCircle(circleId: circleId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func endCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        remote.endCircle(circleId: circleId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - REST: Membership

    public func joinCircle(
        circleId: String,
        password: String?
    ) -> AnyPublisher<CircleMembership, CircleError> {
        remote.joinCircle(circleId: circleId, password: password)
            .map { $0.toDomain() }
            .mapError { Self.mapJoinError($0) }
            .eraseToAnyPublisher()
    }

    public func leaveCircle(circleId: String) -> AnyPublisher<Void, CircleError> {
        remote.leaveCircle(circleId: circleId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func approveJoinRequest(
        circleId: String,
        userId: String
    ) -> AnyPublisher<CircleMember, CircleError> {
        remote.approveJoinRequest(circleId: circleId, userId: userId)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func rejectJoinRequest(
        circleId: String,
        userId: String
    ) -> AnyPublisher<Void, CircleError> {
        remote.rejectJoinRequest(circleId: circleId, userId: userId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func removeMember(
        circleId: String,
        userId: String
    ) -> AnyPublisher<Void, CircleError> {
        remote.removeMember(circleId: circleId, userId: userId)
            .map { _ in () }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - REST: Lists

    public func getMembers(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<CircleMember>, CircleError> {
        remote.getMembers(circleId: circleId, page: page)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func getPendingRequests(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<PendingJoinRequest>, CircleError> {
        remote.getPendingRequests(circleId: circleId, page: page)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    public func getMyCircles(
        page: CirclePageRequest
    ) -> AnyPublisher<CirclePage<CircleModel>, CircleError> {
        remote.getMyCircles(page: page)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - REST: Agora

    public func getAgoraToken(circleId: String) -> AnyPublisher<AgoraToken, CircleError> {
        remote.getAgoraToken(circleId: circleId)
            .map { $0.toDomain() }
            .mapError { Self.mapError($0) }
            .eraseToAnyPublisher()
    }

    // MARK: - Private: Error Mapping

    private static func mapError(_ error: NetworkError) -> CircleError {
        switch error {
        case .unauthorized:
            return .unauthorized
        case .notFound:
            return .notFound
        case .serverError(let statusCode, let message):
            // HTTP 403 — the user is not the owner
            if statusCode == 403 {
                return .notOwner
            }
            // HTTP 409 — could be time-overlap or circle-full
            if statusCode == 409 {
                let lower = message.lowercased()
                if lower.contains("full") || lower.contains("capacity") {
                    return .circleFull
                }
                return .timeOverlap
            }
            return .network(error)
        case .validationFailed(let message, _):
            let lower = message.lowercased()
            if lower.contains("password") {
                return .invalidPassword
            }
            return .network(error)
        default:
            return .network(error)
        }
    }

    private static func mapJoinError(_ error: NetworkError) -> CircleError {
        switch error {
        case .serverError(let statusCode, let message) where statusCode == 400:
            if message.lowercased().contains("password") {
                return .invalidPassword
            }
            return .network(error)
        default:
            return mapError(error)
        }
    }
}
