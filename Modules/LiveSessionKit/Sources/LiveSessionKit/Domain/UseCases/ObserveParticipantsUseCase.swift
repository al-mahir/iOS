//
//  ObserveParticipantsUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine

public protocol ObserveParticipantsUseCaseProtocol: Sendable {
    func execute() -> AnyPublisher<[SessionParticipant], Never>
}

public final class ObserveParticipantsUseCase: ObserveParticipantsUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<[SessionParticipant], Never> {
        repository.participantsPublisher
    }
}
