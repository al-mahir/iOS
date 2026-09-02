//
//  TafsirManagementViewModel.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/07/2026.
//

import SwiftUI
import Combine
import Common

@MainActor
public final class TafsirManagementViewModel: ObservableObject {

    @Published public var tafsirs: [TafsirInfo] = []
    @Published public var downloadProgress: [String: Double] = [:]
    @Published public var primaryTafsirKey: String
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    public let useCases: TafsirUseCases
    private var cancellables = Set<AnyCancellable>()

    public init(useCases: TafsirUseCases = TafsirUseCases(repository: TafsirRepository())) {
        self.useCases = useCases
        self.primaryTafsirKey = TafsirLocalStore.shared.primaryTafsirKey
        
        // Observe app language changes to automatically refresh content
        LanguageManager.shared.$currentLanguage
            .dropFirst()
            .sink { [weak self] _ in
                self?.load()
            }
            .store(in: &cancellables)
    }

    public func load() {
        isLoading = true
        errorMessage = nil
        
        // Fetch language code based on current AppLanguage configuration
        let langCode = currentLanguageCode()
        
        useCases.getAvailableTafsirs.execute()
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.errorDescription
                    if self.tafsirs.isEmpty {
                        self.loadDefaultTafsirs()
                    }
                }
            } receiveValue: { [weak self] tafsirs in
                guard let self else { return }
                // Filter or prioritize based on the language if needed, or assign directly
                let filtered = tafsirs.filter { langCode == "system" || $0.language == langCode }
                if filtered.isEmpty {
                    self.tafsirs = tafsirs.isEmpty ? self.defaultTafsirs() : tafsirs
                } else {
                    self.tafsirs = filtered
                }
            }
            .store(in: &cancellables)
    }

    public func download(_ tafsir: TafsirInfo) {
        errorMessage = nil
        downloadProgress[tafsir.tafsirKey] = 0
        useCases.downloadTafsir.execute(tafsir)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
                self?.downloadProgress[tafsir.tafsirKey] = nil
                self?.refreshDownloadedFlag(for: tafsir.tafsirKey)
            } receiveValue: { [weak self] progress in
                self?.downloadProgress[tafsir.tafsirKey] = progress
            }
            .store(in: &cancellables)
    }

    public func delete(_ tafsir: TafsirInfo) {
        errorMessage = nil
        switch useCases.deleteTafsir.execute(tafsir.tafsirKey) {
        case .success:
            refreshDownloadedFlag(for: tafsir.tafsirKey)
            if primaryTafsirKey == tafsir.tafsirKey,
               let fallback = tafsirs.first(where: { $0.isDownloaded && $0.tafsirKey != tafsir.tafsirKey }) {
                setPrimary(fallback.tafsirKey)
            }
        case .failure(let error):
            errorMessage = error.errorDescription
        }
    }

    public func setPrimary(_ tafsirKey: String) {
        primaryTafsirKey = tafsirKey
        TafsirLocalStore.shared.primaryTafsirKey = tafsirKey
    }

    private func refreshDownloadedFlag(for tafsirKey: String) {
        guard let index = tafsirs.firstIndex(where: { $0.tafsirKey == tafsirKey }) else { return }
        tafsirs[index].isDownloaded = useCases.repository.isTafsirDownloaded(tafsirKey)
    }

    private func currentLanguageCode() -> String {
        let currentLang = LanguageManager.shared.currentLanguage
        switch currentLang {
        case .arabic: return "ar"
        case .english: return "en"
        case .system: return Locale.current.language.languageCode?.identifier ?? "ar"
        }
    }

    private func loadDefaultTafsirs() {
        self.tafsirs = defaultTafsirs()
    }

    private func defaultTafsirs() -> [TafsirInfo] {
        return [
            TafsirInfo(
                tafsirKey: "ibn-kathir",
                displayName: "تفسير ابن كثير",
                language: "ar",
                languageName: "العربية",
                downloadUrl: "",
                fileSizeBytes: 15 * 1024 * 1024,
                isDownloaded: true
            )
        ]
    }
}
