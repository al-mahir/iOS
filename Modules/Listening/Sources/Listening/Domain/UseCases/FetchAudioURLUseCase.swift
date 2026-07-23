//
//  FetchAudioURLUseCase.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

public protocol FetchAudioURLUseCase {
    func execute(reciterId: Int, chapterNumber: Int) -> AnyPublisher<URL, NetworkError>
}

final class FetchAudioURLUseCaseImpl: FetchAudioURLUseCase {
    private let repository: ListeningRepository

    init(repository: ListeningRepository) {
        self.repository = repository
    }

    func execute(reciterId: Int, chapterNumber: Int) -> AnyPublisher<URL, NetworkError> {
        repository.fetchAudioURL(reciterId: reciterId, chapterNumber: chapterNumber)
    }
}
