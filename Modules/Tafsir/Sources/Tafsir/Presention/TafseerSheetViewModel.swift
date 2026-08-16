//
//  TafseerSheetViewModel.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/07/2026.
//



import SwiftUI
import Combine

@MainActor
public final class TafseerSheetViewModel: ObservableObject {

    @Published var downloadedTafsirs: [TafsirInfo] = []
    @Published var selectedTafsirKey: String
    @Published var tafsirText: String = ""
    @Published var isLoadingList = false
    @Published var isLoadingText = false
    @Published var errorMessage: String?

    let surah: Int
    let ayah: Int
    private let useCases: TafsirUseCases
    private var cancellables = Set<AnyCancellable>()
    private var textFetchCancellable: AnyCancellable?

    public init(surah: Int, ayah: Int, useCases: TafsirUseCases) {
        self.surah = surah
        self.ayah = ayah
        self.useCases = useCases
        self.selectedTafsirKey = TafsirLocalStore.shared.primaryTafsirKey
    }

    func load() {
        loadDownloadedTafsirs()
        fetchTafsirText()
    }

    func loadDownloadedTafsirs() {
        isLoadingList = true
        useCases.getAvailableTafsirs.execute()
            .sink { [weak self] completion in
                self?.isLoadingList = false
                if case .failure(let error) = completion {
                    if self?.tafsirText.isEmpty == true {
                        self?.errorMessage = error.errorDescription
                    }
                }
            } receiveValue: { [weak self] tafsirs in
                guard let self else { return }
                let downloaded = tafsirs.filter(\.isDownloaded)
                self.downloadedTafsirs = downloaded
                // If primary tafsir is not downloaded and we have downloaded items,
                // fallback to downloaded items if selectedTafsirKey is not "ibn-kathir"
                if !downloaded.isEmpty && !downloaded.contains(where: { $0.tafsirKey == self.selectedTafsirKey }) && self.selectedTafsirKey != "ibn-kathir" {
                    if let first = downloaded.first {
                        self.selectedTafsirKey = first.tafsirKey
                        self.fetchTafsirText()
                    }
                }
            }
            .store(in: &cancellables)
    }

    /// Switching here only changes this sheet's content — never the global primary setting.
    func select(_ tafsirKey: String) {
        guard tafsirKey != selectedTafsirKey else { return }
        selectedTafsirKey = tafsirKey
        fetchTafsirText()
    }

    func fetchTafsirText() {
        textFetchCancellable?.cancel()
        
        guard !selectedTafsirKey.isEmpty else { return }
        isLoadingText = true
        errorMessage = nil
        
        useCases.getAyahTafsir.execute(surah: surah, ayah: ayah, lang: "ar", tafsirKey: selectedTafsirKey)
            .receive(on: DispatchQueue.main) 
            .sink { [weak self] completion in
                self?.isLoadingText = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.errorDescription
                }
            } receiveValue: { [weak self] tafsir in
                self?.tafsirText = tafsir.text
            }
            .store(in: &cancellables)
    }
    func cancelAllRequests() {
        cancellables.removeAll()
    }
}
