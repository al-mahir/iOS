//
//  SendMeetingRequestUseCase.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public protocol SendMeetingRequestUseCaseProtocol: Sendable {
    func execute(sheikhId: String) async throws -> InstantMeetingRequest
}

public final class SendMeetingRequestUseCase: SendMeetingRequestUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(sheikhId: String) async throws -> InstantMeetingRequest {
        try await repository.requestMeeting(sheikhId: sheikhId)
    }
}
