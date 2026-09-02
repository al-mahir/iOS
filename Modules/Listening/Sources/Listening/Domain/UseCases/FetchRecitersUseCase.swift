//
//  FetchRecitersUseCase.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

public protocol FetchRecitersUseCase {
    func execute() -> AnyPublisher<[Reciter], NetworkError>
}

final class FetchRecitersUseCaseImpl: FetchRecitersUseCase {
    private let repository: ListeningRepository

    init(repository: ListeningRepository) {
        self.repository = repository
    }

    func execute() -> AnyPublisher<[Reciter], NetworkError> {
        repository.fetchReciters()
    }
}
