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

    public static let defaultTafsirs: [TafsirInfo] = [
        TafsirInfo(
            tafsirKey: "ibn-kathir",
            displayName: "تفسير ابن كثير",
            language: "ar",
            languageName: "العربية",
            downloadUrl: "https://almahir-production-6f98.up.railway.app/api/tafsir/download/ibn-kathir",
            fileSizeBytes: 24_500_000,
            isDownloaded: false
        ),
        TafsirInfo(
            tafsirKey: "ar-tafsir-muyassar",
            displayName: "التفسير الميسر",
            language: "ar",
            languageName: "العربية",
            downloadUrl: "https://almahir-production-6f98.up.railway.app/api/tafsir/download/ar-tafsir-muyassar",
            fileSizeBytes: 12_800_000,
            isDownloaded: false
        ),
        TafsirInfo(
            tafsirKey: "saadi",
            displayName: "تفسير السعدي",
            language: "ar",
            languageName: "العربية",
            downloadUrl: "https://almahir-production-6f98.up.railway.app/api/tafsir/download/saadi",
            fileSizeBytes: 18_200_000,
            isDownloaded: false
        ),
        TafsirInfo(
            tafsirKey: "tabari",
            displayName: "تفسير الطبري",
            language: "ar",
            languageName: "العربية",
            downloadUrl: "https://almahir-production-6f98.up.railway.app/api/tafsir/download/tabari",
            fileSizeBytes: 35_100_000,
            isDownloaded: false
        )
    ]

    // MARK: 1 — Get all tafsirs

    public func getAvailableTafsirs() -> AnyPublisher<[TafsirInfo], NetworkError> {
        networkService.request(TafsirEndpoint.available)
            .map { [localStore] (dtos: [TafsirAvailableDTO]) -> [TafsirInfo] in
                if dtos.isEmpty {
                    return TafsirRepository.defaultTafsirs.map { tafsir in
                        var item = tafsir
                        item.isDownloaded = localStore.isDownloaded(item.tafsirKey)
                        return item
                    }
                }
                return dtos.map { $0.toDomain(isDownloaded: localStore.isDownloaded($0.tafsirKey)) }
            }
            .catch { [localStore] _ -> AnyPublisher<[TafsirInfo], NetworkError> in
                let items = TafsirRepository.defaultTafsirs.map { tafsir in
                    var item = tafsir
                    item.isDownloaded = localStore.isDownloaded(item.tafsirKey)
                    return item
                }
                return Just(items)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
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
                : .failure(.fileSystem("tafsir_error_delete_failed"))
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
