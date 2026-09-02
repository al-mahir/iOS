//
//  ListeningRepositoryImpl.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

final class ListeningRepositoryImpl: ListeningRepository {

    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    // MARK: - Reciters

    func fetchReciters() -> AnyPublisher<[Reciter], NetworkError> {
        // Quran.com returns a raw envelope: { "recitations": [...] }
        // We use requestExternal which decodes T directly (no APISuccessResponse wrapper)
        let publisher: AnyPublisher<RecitersResponseDTO, NetworkError> =
            networkService.requestExternal(QuranEndpoint.reciters)

        return publisher
            .map { ReciterMapper.toDomainList($0.recitations) }
            .eraseToAnyPublisher()
    }

    // MARK: - Audio URL

    func fetchAudioURL(reciterId: Int, chapterNumber: Int) -> AnyPublisher<URL, NetworkError> {
        let publisher: AnyPublisher<ChapterAudioResponseDTO, NetworkError> =
            networkService.requestExternal(
                QuranEndpoint.chapterAudio(reciterId: reciterId, chapterNumber: chapterNumber)
            )

        return publisher
            .tryMap { response -> URL in
                guard
                    let audioFile = response.audioFile,
                    let url = URL(string: audioFile.audioURL)
                else {
                    throw NetworkError.unknown(message: "Invalid audio URL from server")
                }
                return url
            }
            .mapError { error in
                (error as? NetworkError) ?? .unknown(message: error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Word Timings

    func fetchWordTimings(reciterId: Int, chapterNumber: Int) -> AnyPublisher<[WordTiming], NetworkError> {
        let publisher: AnyPublisher<ChapterAudioResponseDTO, NetworkError> =
            networkService.requestExternal(
                QuranEndpoint.chapterAudio(reciterId: reciterId, chapterNumber: chapterNumber)
            )

        return publisher
            .map { TimestampMapper.toDomainList($0.audioFile?.timestamps ?? []) }
            .eraseToAnyPublisher()
    }
}
