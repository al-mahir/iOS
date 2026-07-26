//
//  TafsirRepositoryProtocol.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import Foundation
import Combine
import NetworkKit

public protocol TafsirRepositoryProtocol {

    func getAvailableTafsirs() -> AnyPublisher<[TafsirInfo], NetworkError>

    func downloadTafsir(_ tafsir: TafsirInfo) -> AnyPublisher<Double, TafsirDownloadError>

    @discardableResult
    func deleteDownloadedTafsir(_ tafsirKey: String) -> Result<Void, TafsirDownloadError>

    func isTafsirDownloaded(_ tafsirKey: String) -> Bool

    func getTafsirForAyah(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirKey: String
    ) -> AnyPublisher<AyahTafsir, NetworkError>
}
