//
//  SheikhRepositoryProtocol.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit

public protocol SheikhRepositoryProtocol: Sendable {

    func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError>

    func getSheikhByID(_ id: String) -> AnyPublisher<Sheikh, NetworkError>

    func searchSheikhs(name: String?) -> AnyPublisher<[SheikhSearchResult], NetworkError>

    func toggleFavorite(sheikhID: String) -> AnyPublisher<Bool, NetworkError>
    
    func getSheikhAvailability(sheikhId: String) async throws -> SheikhAvailability
    
    func requestMeeting(sheikhId: String) async throws -> InstantMeetingRequest
    
    func cancelMeeting(requestId: String) async throws
    
    func getStudentHistory(page: Int, size: Int) async throws -> PageResult<StudentMeetingHistoryItem>
    
    func getFreshAgoraToken(requestId: String) async throws -> (token: String, channelName: String, userAccount: String?)
    
    func observeRequestUpdates(requestId: String) -> AnyPublisher<InstantMeetingStatus, Never>

}
