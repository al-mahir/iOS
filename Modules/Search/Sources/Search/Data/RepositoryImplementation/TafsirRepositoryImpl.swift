//
//  TafsirRepositoryImpl.swift
//  Search
//

import Foundation
import Combine
import NetworkKit

final class TafsirRepositoryImpl: TafsirRepositoryProtocol {
    private let remoteDataSource: TafsirRemoteDataSource

    init(remoteDataSource: TafsirRemoteDataSource) {
        self.remoteDataSource = remoteDataSource
    }

    func fetchTafsir(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirSource: String
    ) -> AnyPublisher<TafsirData, NetworkError> {
        remoteDataSource.fetchTafsir(
            surah: surah,
            ayah: ayah,
            lang: lang,
            tafsirSource: tafsirSource
        )
    }
}

