//
//  TafsirManagementViewModel.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/07/2026.
//


import SwiftUI
import Combine

@MainActor
final class TafsirManagementViewModel: ObservableObject {

    @Published var tafsirs: [TafsirInfo] = []
    @Published var downloadProgress: [String: Double] = [:]
    @Published var primaryTafsirKey: String
    @Published var isLoading = false
    @Published var errorMessage: String?

    let useCases: TafsirUseCases
    private var cancellables = Set<AnyCancellable>()

    init(useCases: TafsirUseCases = TafsirUseCases(repository: TafsirRepository())) {
        self.useCases = useCases
        self.primaryTafsirKey = TafsirLocalStore.shared.primaryTafsirKey
    }

    func load() {
        isLoading = true
        errorMessage = nil
        useCases.getAvailableTafsirs.execute()
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] tafsirs in
                self?.tafsirs = tafsirs
            }
            .store(in: &cancellables)
    }

    func download(_ tafsir: TafsirInfo) {
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

    func delete(_ tafsir: TafsirInfo) {
        errorMessage = nil
        switch useCases.deleteTafsir.execute(tafsir.tafsirKey) {
        case .success:
            refreshDownloadedFlag(for: tafsir.tafsirKey)
            // If the removed tafsir was primary, fall back to another
            // downloaded one so the switcher never points at nothing.
            if primaryTafsirKey == tafsir.tafsirKey,
               let fallback = tafsirs.first(where: { $0.isDownloaded && $0.tafsirKey != tafsir.tafsirKey }) {
                setPrimary(fallback.tafsirKey)
            }
        case .failure(let error):
            errorMessage = error.errorDescription
        }
    }

    func setPrimary(_ tafsirKey: String) {
        primaryTafsirKey = tafsirKey
        TafsirLocalStore.shared.primaryTafsirKey = tafsirKey
    }

    private func refreshDownloadedFlag(for tafsirKey: String) {
        guard let index = tafsirs.firstIndex(where: { $0.tafsirKey == tafsirKey }) else { return }
        tafsirs[index].isDownloaded = useCases.repository.isTafsirDownloaded(tafsirKey)
    }
}