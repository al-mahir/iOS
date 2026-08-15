//
//  CircleRemoteDataSource.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Combine
import Foundation
import NetworkKit

public final class CircleRemoteDataSource: @unchecked Sendable {

    private let networkService: any NetworkServiceProtocol

    public init(
        networkService: any NetworkServiceProtocol = NetworkService.shared
    ) {
        self.networkService = networkService
    }

    func listCircles(
        params: ListCirclesParams,
        page: CirclePageRequest
    ) -> AnyPublisher<PageDTO<CircleDTO>, NetworkError> {
        networkService.request(
            CircleEndpoints.makeList(params: params, page: page)
        )
    }

    func createCircle(
        _ params: CreateCircleParams,
        password: String
    ) -> AnyPublisher<
        CircleDTO, NetworkError
    > {
        networkService.request(CircleEndpoints.makeCreate(params, password: password))
    }

    func getCircle(circleId: String) -> AnyPublisher<CircleDTO, NetworkError> {
        networkService.request(CircleEndpoints.detail(circleId: circleId))
    }

    func updateCircle(
        circleId: String,
        params: UpdateCircleParams
    ) -> AnyPublisher<CircleDTO, NetworkError> {
        networkService.request(
            CircleEndpoints.makeUpdate(circleId: circleId, params: params)
        )
    }

    func cancelCircle(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.cancel(circleId: circleId)
        )
    }

    // MARK: - Lifecycle

    func startCircle(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.start(circleId: circleId)
        )
    }

    func endCircle(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.end(circleId: circleId)
        )
    }

    // MARK: - Membership

    func joinCircle(circleId: String) -> AnyPublisher<CircleJoinResponseDTO, NetworkError> {
        networkService.request(CircleEndpoints.join(circleId: circleId))
    }

    func joinPrivateCircle(token: String) -> AnyPublisher<CircleJoinResponseDTO, NetworkError> {
        networkService.request(CircleEndpoints.joinPrivate(token: token))
    }

    func leaveCircle(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.leave(circleId: circleId)
        )
    }

    func approveJoinRequest(
        circleId: String,
        userId: String
    ) -> AnyPublisher<CircleMemberDTO, NetworkError> {
        networkService.request(
            CircleEndpoints.approve(circleId: circleId, userId: userId)
        )
    }

    func rejectJoinRequest(
        circleId: String,
        userId: String
    ) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.reject(circleId: circleId, userId: userId)
        )
    }

    func removeMember(
        circleId: String,
        userId: String
    ) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(
            CircleEndpoints.removeMember(circleId: circleId, userId: userId)
        )
    }

    // MARK: - Lists

    func getMembers(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<PageDTO<CircleMemberDTO>, NetworkError> {
        networkService.request(
            CircleEndpoints.members(
                circleId: circleId,
                page: page.page,
                size: page.size
            )
        )
    }

    func getPendingRequests(
        circleId: String,
        page: CirclePageRequest
    ) -> AnyPublisher<PageDTO<PendingJoinRequestDTO>, NetworkError> {
        networkService.request(
            CircleEndpoints.pendingRequests(
                circleId: circleId,
                page: page.page,
                size: page.size
            )
        )
    }

    func getMyCircles(page: CirclePageRequest) -> AnyPublisher<
        PageDTO<CircleDTO>, NetworkError
    > {
        networkService.request(
            CircleEndpoints.mine(page: page.page, size: page.size)
        )
    }

    func getPrivateCircles() -> AnyPublisher<PageDTO<CircleDTO>, NetworkError> {
        networkService.request(CircleEndpoints.privateMine)
    }

    // MARK: - Agora

    func getAgoraToken(circleId: String) -> AnyPublisher<
        AgoraTokenDTO, NetworkError
    > {
        networkService.request(CircleEndpoints.agoraToken(circleId: circleId))
    }
}
