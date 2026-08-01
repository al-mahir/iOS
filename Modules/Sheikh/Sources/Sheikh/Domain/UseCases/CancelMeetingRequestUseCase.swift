//
//  CancelMeetingRequestUseCase.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public protocol CancelMeetingRequestUseCaseProtocol: Sendable {
    func execute(requestId: String) async throws
}

public final class CancelMeetingRequestUseCase: CancelMeetingRequestUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(requestId: String) async throws {
        try await repository.cancelMeeting(requestId: requestId)
    }
}
