//
//  FetchTafsirUseCase.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


//
//  FetchTafsirUseCase.swift
//  Search
//

import Foundation
import Combine
import NetworkKit

final class FetchTafsirUseCase {
    private let repository: TafsirRepositoryProtocol

    init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        surah: Int,
        ayah: Int,
        lang: String = "en",
        tafsirSource: String = "ibn-kathir"
    ) -> AnyPublisher<TafsirData, NetworkError> {
        repository.fetchTafsir(
            surah: surah,
            ayah: ayah,
            lang: lang,
            tafsirSource: tafsirSource
        )
    }
}
