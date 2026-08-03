//
//  GetSheikhAvailabilityUseCase.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public protocol GetSheikhAvailabilityUseCaseProtocol: Sendable {
    func execute(sheikhId: String) async throws -> SheikhAvailability
}

public final class GetSheikhAvailabilityUseCase: GetSheikhAvailabilityUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(sheikhId: String) async throws -> SheikhAvailability {
        try await repository.getSheikhAvailability(sheikhId: sheikhId)
    }
}
