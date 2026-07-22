//
//  FetchWordTimingsUseCase.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

public protocol FetchWordTimingsUseCase {
    func execute(reciterId: Int, chapterNumber: Int) -> AnyPublisher<[WordTiming], NetworkError>
}

final class FetchWordTimingsUseCaseImpl: FetchWordTimingsUseCase {
    private let repository: ListeningRepository

    init(repository: ListeningRepository) {
        self.repository = repository
    }

    func execute(reciterId: Int, chapterNumber: Int) -> AnyPublisher<[WordTiming], NetworkError> {
        repository.fetchWordTimings(reciterId: reciterId, chapterNumber: chapterNumber)
    }
}
