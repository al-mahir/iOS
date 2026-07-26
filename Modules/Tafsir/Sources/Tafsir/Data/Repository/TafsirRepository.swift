//
//  TafsirRepository.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//
//

import Foundation
import Combine
import Alamofire
import NetworkKit

public final class TafsirRepository: TafsirRepositoryProtocol, @unchecked Sendable {

    private let networkService: NetworkServiceProtocol
    private let localStore: TafsirLocalStore
    private let downloadSession: Session

    public init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        localStore: TafsirLocalStore = .shared,
        downloadSession: Session = .default
    ) {
        self.networkService = networkService
        self.localStore = localStore
        self.downloadSession = downloadSession
    }

    // MARK: 1 — Get all tafsirs

    public func getAvailableTafsirs() -> AnyPublisher<[TafsirInfo], NetworkError> {
        networkService.request(TafsirEndpoint.available)
            .map { [localStore] (dtos: [TafsirAvailableDTO]) in
                dtos.map { $0.toDomain(isDownloaded: localStore.isDownloaded($0.tafsirKey)) }
            }
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }

    // MARK: 2 — Download one

    public func downloadTafsir(_ tafsir: TafsirInfo) -> AnyPublisher<Double, TafsirDownloadError> {
        guard let url = URL(string: tafsir.downloadUrl) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        let localStore = self.localStore
        let destination: DownloadRequest.Destination = { _, _ in
            (localStore.fileURL(for: tafsir.tafsirKey), [.removePreviousFile, .createIntermediateDirectories])
        }

        let subject = PassthroughSubject<Double, TafsirDownloadError>()

        let request = downloadSession
            .download(url, to: destination)
            .downloadProgress { progress in
                subject.send(progress.fractionCompleted)
            }
            .response { response in
                switch response.result {
                case .success:
                    localStore.markDownloaded(tafsir.tafsirKey)
                    subject.send(1.0)
                    subject.send(completion: .finished)
                case .failure(let error):
                    subject.send(completion: .failure(.network(.unknown(message: error.localizedDescription))))
                }
            }

        return subject
            .handleEvents(receiveCancel: { request.cancel() })
            .eraseToAnyPublisher()
    }

    // MARK: 3 — Un-download one

    @discardableResult
    public func deleteDownloadedTafsir(_ tafsirKey: String) -> Result<Void, TafsirDownloadError> {
        localStore.deleteFile(for: tafsirKey)
            ? .success(())
            : .failure(.fileSystem("Failed to delete tafsir file for \(tafsirKey)."))
    }

    public func isTafsirDownloaded(_ tafsirKey: String) -> Bool {
        localStore.isDownloaded(tafsirKey)
    }

    // MARK: 4 — Get tafsir for an ayah

    public func getTafsirForAyah(
        surah: Int,
        ayah: Int,
        lang: String,
        tafsirKey: String
    ) -> AnyPublisher<AyahTafsir, NetworkError> {
        networkService
            .request(TafsirEndpoint.ayah(surah: surah, ayah: ayah, lang: lang, tafsirKey: tafsirKey))
            .map { (dto: AyahTafsirDTO) in dto.toDomain() }
            .subscribe(on: DispatchQueue.global(qos: .userInitiated))
            .eraseToAnyPublisher()
    }
}
