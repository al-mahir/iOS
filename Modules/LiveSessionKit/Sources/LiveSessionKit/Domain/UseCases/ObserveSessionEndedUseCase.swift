//
//  ObserveSessionEndedUseCase.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine

public protocol ObserveSessionEndedUseCaseProtocol: Sendable {
    func execute() -> AnyPublisher<Void, Never>
}

public final class ObserveSessionEndedUseCase: ObserveSessionEndedUseCaseProtocol, Sendable {
    private let repository: LiveSessionRepositoryProtocol

    public init(repository: LiveSessionRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<Void, Never> {
        repository.sessionEndedPublisher
    }
}
