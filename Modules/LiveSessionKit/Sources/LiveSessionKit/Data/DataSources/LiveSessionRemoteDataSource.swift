//
//  LiveSessionRemoteDataSource.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine
import NetworkKit

public protocol LiveSessionRemoteDataSourceProtocol: Sendable {
    func leaveSession(circleId: String) -> AnyPublisher<Bool, NetworkError>
    func endSession(circleId: String) -> AnyPublisher<Bool, NetworkError>
    func getParticipants(circleId: String) -> AnyPublisher<[ParticipantDTO], NetworkError>
    func getCircleDetail(circleId: String) -> AnyPublisher<CircleDetailDTO, NetworkError>
}

public final class LiveSessionRemoteDataSource: LiveSessionRemoteDataSourceProtocol, @unchecked Sendable {
    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    public func leaveSession(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(LiveSessionEndpoints.leave(circleId: circleId))
    }

    public func endSession(circleId: String) -> AnyPublisher<Bool, NetworkError> {
        networkService.requestWithoutData(LiveSessionEndpoints.end(circleId: circleId))
    }

    public func getParticipants(circleId: String) -> AnyPublisher<[ParticipantDTO], NetworkError> {
        networkService.request(LiveSessionEndpoints.getParticipants(circleId: circleId))
    }

    public func getCircleDetail(circleId: String) -> AnyPublisher<CircleDetailDTO, NetworkError> {
        networkService.request(LiveSessionEndpoints.getCircleDetail(circleId: circleId))
    }
}
