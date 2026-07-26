//
//  TafsirUseCases.swift
//  Tafsir / Domain
//

import Foundation
import Combine
import NetworkKit
/// 1 — Get all tafsirs available for download.
public struct GetAvailableTafsirsUseCase {
    private let repository: TafsirRepositoryProtocol

    public init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
    }

    public func execute() -> AnyPublisher<[TafsirInfo], NetworkError> {
        repository.getAvailableTafsirs()
    }
}

/// 2 — Download one tafsir.
public struct DownloadTafsirUseCase {
    private let repository: TafsirRepositoryProtocol

    public init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(_ tafsir: TafsirInfo) -> AnyPublisher<Double, TafsirDownloadError> {
        repository.downloadTafsir(tafsir)
    }
}

/// 3 — Un-download (remove) one tafsir.
public struct DeleteTafsirUseCase {
    private let repository: TafsirRepositoryProtocol

    public init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
    }

    @discardableResult
    public func execute(_ tafsirKey: String) -> Result<Void, TafsirDownloadError> {
        repository.deleteDownloadedTafsir(tafsirKey)
    }
}

/// 4 — Get the tafsir text for an ayah, from a chosen (available) tafsir source.
public struct GetAyahTafsirUseCase {
    private let repository: TafsirRepositoryProtocol

    public init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(
        surah: Int,
        ayah: Int,
        lang: String = "ar",
        tafsirKey: String = "ibn-kathir"
    ) -> AnyPublisher<AyahTafsir, NetworkError> {
        repository.getTafsirForAyah(surah: surah, ayah: ayah, lang: lang, tafsirKey: tafsirKey)
    }
}

/// Small composition root so a single repository instance is shared
/// across all four use cases (matters for the local downloaded-state cache).
public struct TafsirUseCases {
    public let repository: TafsirRepositoryProtocol

    public let getAvailableTafsirs: GetAvailableTafsirsUseCase
    public let downloadTafsir: DownloadTafsirUseCase
    public let deleteTafsir: DeleteTafsirUseCase
    public let getAyahTafsir: GetAyahTafsirUseCase

    public init(repository: TafsirRepositoryProtocol) {
        self.repository = repository
        self.getAvailableTafsirs = GetAvailableTafsirsUseCase(repository: repository)
        self.downloadTafsir = DownloadTafsirUseCase(repository: repository)
        self.deleteTafsir = DeleteTafsirUseCase(repository: repository)
        self.getAyahTafsir = GetAyahTafsirUseCase(repository: repository)
    }
}
