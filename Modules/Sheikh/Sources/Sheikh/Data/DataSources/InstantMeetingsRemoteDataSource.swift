//
//  InstantMeetingsRemoteDataSource.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation
import Combine
import NetworkKit

public protocol InstantMeetingsRemoteDataSourceProtocol: Sendable {
    func createRequest(sheikhId: String) -> AnyPublisher<MeetingRequestResponseDTO, NetworkError>
    func cancelRequest(requestId: String) -> AnyPublisher<EmptyDataDTO, NetworkError>
    func getAvailability(sheikhId: String) -> AnyPublisher<SheikhAvailabilityResponseDTO, NetworkError>
    func getStudentHistory(page: Int, size: Int) -> AnyPublisher<PageResponseDTO<StudentMeetingHistoryResponseDTO>, NetworkError>
    func getToken(requestId: String) -> AnyPublisher<AgoraTokenResponseDTO, NetworkError>
}

public struct EmptyDataDTO: Codable, Sendable {}

public final class InstantMeetingsRemoteDataSource: InstantMeetingsRemoteDataSourceProtocol, Sendable {
    private let networkService: NetworkServiceProtocol

    public init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    public func createRequest(sheikhId: String) -> AnyPublisher<MeetingRequestResponseDTO, NetworkError> {
        networkService.request(InstantMeetingsEndpoints.createRequest(sheikhId: sheikhId))
    }

    public func cancelRequest(requestId: String) -> AnyPublisher<EmptyDataDTO, NetworkError> {
        networkService.request(InstantMeetingsEndpoints.cancelRequest(requestId: requestId))
    }

    public func getAvailability(sheikhId: String) -> AnyPublisher<SheikhAvailabilityResponseDTO, NetworkError> {
        networkService.request(InstantMeetingsEndpoints.getAvailability(sheikhId: sheikhId))
    }

    public func getStudentHistory(page: Int, size: Int) -> AnyPublisher<PageResponseDTO<StudentMeetingHistoryResponseDTO>, NetworkError> {
        networkService.request(InstantMeetingsEndpoints.getStudentHistory(page: page, size: size))
    }

    public func getToken(requestId: String) -> AnyPublisher<AgoraTokenResponseDTO, NetworkError> {
        networkService.request(InstantMeetingsEndpoints.getToken(requestId: requestId))
    }
}
