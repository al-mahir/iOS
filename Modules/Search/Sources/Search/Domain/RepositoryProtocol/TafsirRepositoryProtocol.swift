//
//  TafsirRepositoryProtocol.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


//
//  TafsirRepositoryProtocol.swift
//  Search
//

import Foundation
import Combine
import NetworkKit

protocol TafsirRepositoryProtocol {
    func fetchTafsir(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirSource: String
    ) -> AnyPublisher<TafsirData, NetworkError>
}
