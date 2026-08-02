//
//  ObserveMeetingRequestUseCase.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation
import Combine

public protocol ObserveMeetingRequestUseCaseProtocol: Sendable {
    func execute(requestId: String) -> AnyPublisher<InstantMeetingStatus, Never>
}

public final class ObserveMeetingRequestUseCase: ObserveMeetingRequestUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(requestId: String) -> AnyPublisher<InstantMeetingStatus, Never> {
        repository.observeRequestUpdates(requestId: requestId)
    }
}
