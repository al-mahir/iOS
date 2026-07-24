//
//  TafsirRemoteDataSource.swift
//  Search
//

import Foundation
import Combine
import NetworkKit

// MARK: - Protocol

protocol TafsirRemoteDataSource {
    func fetchTafsir(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirSource: String
    ) -> AnyPublisher<TafsirData, NetworkError>
}

// MARK: - Implementation

final class TafsirRemoteDataSourceImpl: TafsirRemoteDataSource {
    private let networkService: NetworkServiceProtocol

    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }

    func fetchTafsir(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirSource: String
    ) -> AnyPublisher<TafsirData, NetworkError> {
        let endpoint = TafsirEndpoint.tafsir(
            surah: surah,
            ayah: ayah,
            lang: lang,
            tafsirSource: tafsirSource
        )
        // Decode into TafsirDTO, then map to the clean domain model
        let publisher: AnyPublisher<TafsirDTO, NetworkError> = networkService.request(endpoint)
        return publisher
            .map { $0.toEntity() }
            .eraseToAnyPublisher()
    }
}

