//
//  SearchViewModel.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation
import Combine
import Speech

@MainActor
final class SearchViewModel: ObservableObject {
 

    @Published var searchQuery: String = ""
    @Published var selectedCategory: SearchCategory = .word


    @Published private(set) var searchResults: [SearchResult] = []


    @Published private(set) var wordMatchedSurahs: [Surah] = []


    @Published private(set) var wordMatchedAyahs: [SearchResult] = []

    @Published private(set) var allSurahs: [Surah] = []
    @Published private(set) var allJuz: [Juz] = []
    @Published private(set) var searchHistory: [SearchHistoryItem] = []

    @Published private(set) var isSearching: Bool = false
    @Published var errorMessage: String?

    @Published var selectedPageNumber: Int?
    @Published var selectedAyahNumber: Int?
    @Published var navigateToMushaf: Bool = false
    @Published var selectedSurahIds: Set<Int> = []
    @Published var selectedJuzNumbers: Set<Int> = []
    @Published var selectedTafsirType: TafsirType = .summary

  
    @Published private(set) var isListening: Bool = false
    @Published var permissionDenied: Bool = false


    private let searchUseCase: SearchAyahsUseCase
    private let quranRepository: QuranRepositoryProtocol
    private let speechService = SpeechService()
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?

    var filteredWordSurahs: [Surah] {
        guard !searchQuery.isEmpty else { return [] }
        let q = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        return allSurahs.filter { surah in
            let matchesQuery = surah.name.localizedCaseInsensitiveContains(q) ||
                surah.englishName.localizedCaseInsensitiveContains(q) ||
                surah.arabicName.localizedCaseInsensitiveContains(q)
            let matchesFilter = selectedSurahIds.isEmpty || selectedSurahIds.contains(surah.id)
            return matchesQuery && matchesFilter
        }
    }

    var isCurrentCategoryEmpty: Bool {
        switch selectedCategory {
        case .word:
            return filteredWordSurahs.isEmpty && wordMatchedAyahs.isEmpty
        case .semantic:
            return searchResults.isEmpty
        case .tafsir:
            return false // tafsir always shows its placeholder UI
        }
    }

    var hasActiveFilters: Bool {
        !selectedSurahIds.isEmpty || !selectedJuzNumbers.isEmpty
    }

    var currentFilter: SearchFilter {
        SearchFilter(
            surahIds: selectedSurahIds,
            juzNumbers: selectedJuzNumbers,
            tafsirType: selectedTafsirType
        )
    }

    var currentCategoryHistory: [SearchHistoryItem] {
        searchHistory.filter { $0.category == selectedCategory }
    }

    // MARK: - Initialization

    init(
        searchUseCase: SearchAyahsUseCase,
        quranRepository: QuranRepositoryProtocol
    ) {
        self.searchUseCase = searchUseCase
        self.quranRepository = quranRepository

        setupSearchDebouncer()
        setupSpeechService()
        loadInitialData()
    }

    // MARK: - Search Pipeline

    private func setupSearchDebouncer() {
        $searchQuery
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }

    func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

        // Cancel any in-flight task
        searchTask?.cancel()

        guard !trimmedQuery.isEmpty else {
            searchResults = []
            wordMatchedAyahs = []
            isSearching = false
            errorMessage = nil
            return
        }

        switch selectedCategory {
        case .word:
            performWordSearch(query: trimmedQuery)
        case .semantic:
            performSemanticSearch(query: trimmedQuery)
        case .tafsir:
            // No logic yet — placeholder UI is shown
            break
        }
    }

    // MARK: - Word Search (surah name match + ayah text search)

    private func performWordSearch(query: String) {
        if !filteredWordSurahs.isEmpty {
            saveToHistory(query: query)
        }

        isSearching = true
        errorMessage = nil
        wordMatchedAyahs = []

        let useCase = self.searchUseCase
        let surahIds = self.selectedSurahIds
        let juzNumbers = self.selectedJuzNumbers
        let hasFilters = self.hasActiveFilters

        searchTask = Task.detached(priority: .userInitiated) { [weak self] in
            if Task.isCancelled { return }

            do {
                let results = try useCase.execute(query: query)
                if Task.isCancelled { return }

                let filtered: [SearchResult]
                if hasFilters {
                    filtered = results.filter { result in
                        let matchesSurah = surahIds.isEmpty || surahIds.contains(result.surah.id)
                        let matchesJuz = juzNumbers.isEmpty ||
                            (result.surah.juzStart...result.surah.juzEnd)
                            .contains { juzNumbers.contains($0) }
                        return matchesSurah && matchesJuz
                    }
                } else {
                    filtered = results
                }

                if Task.isCancelled { return }

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.wordMatchedAyahs = filtered
                    self.isSearching = false
                    if !filtered.isEmpty { self.saveToHistory(query: query) }
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                    self.wordMatchedAyahs = []
                    self.isSearching = false
                }
            }
        }
    }

    // MARK: - Semantic Search

    private func performSemanticSearch(query: String) {
        isSearching = true
        errorMessage = nil

        let useCase = self.searchUseCase
        let surahIds = self.selectedSurahIds
        let juzNumbers = self.selectedJuzNumbers
        let hasFilters = self.hasActiveFilters

        searchTask = Task.detached(priority: .userInitiated) { [weak self] in
            if Task.isCancelled { return }

            do {
                let results = try useCase.execute(query: query)
                if Task.isCancelled { return }

                let filteredResults: [SearchResult]
                if hasFilters {
                    filteredResults = results.filter { result in
                        let matchesSurah = surahIds.isEmpty || surahIds.contains(result.surah.id)
                        let matchesJuz = juzNumbers.isEmpty ||
                            (result.surah.juzStart...result.surah.juzEnd)
                            .contains { juzNumbers.contains($0) }
                        return matchesSurah && matchesJuz
                    }
                } else {
                    filteredResults = results
                }

                if Task.isCancelled { return }

                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.searchResults = filteredResults
                    self.isSearching = false
                    if !filteredResults.isEmpty { self.saveToHistory(query: query) }
                }
            } catch {
                if Task.isCancelled { return }
                await MainActor.run { [weak self] in
                    guard let self else { return }
                    self.errorMessage = "Search failed: \(error.localizedDescription)"
                    self.searchResults = []
                    self.isSearching = false
                }
            }
        }
    }

    private func applyLocalFilters(results: [SearchResult]) -> [SearchResult] {
        guard hasActiveFilters else { return results }

        return results.filter { result in
            let matchesSurah = selectedSurahIds.isEmpty || selectedSurahIds.contains(result.surah.id)
            let matchesJuz = selectedJuzNumbers.isEmpty ||
                (result.surah.juzStart...result.surah.juzEnd)
                .contains { selectedJuzNumbers.contains($0) }
            return matchesSurah && matchesJuz
        }
    }

    // MARK: - Data Loaders

    private func loadInitialData() {
        loadSurahs()
        loadJuz()
        loadSearchHistory()
    }

    func loadSurahs() {
        quranRepository.fetchAllSurahs()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] surahs in
                    self?.allSurahs = surahs
                }
            )
            .store(in: &cancellables)
    }

    func loadJuz() {
        quranRepository.fetchAllJuz()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] juz in
                    self?.allJuz = juz
                }
            )
            .store(in: &cancellables)
    }

    func loadSearchHistory() {
        quranRepository.fetchSearchHistory()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] history in
                    self?.searchHistory = history
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - Speech Recognition

    private func setupSpeechService() {
        speechService.$transcript
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.searchQuery = text
            }
            .store(in: &cancellables)

        speechService.$isListening
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isListening in
                self?.isListening = isListening
            }
            .store(in: &cancellables)

        speechService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    self?.errorMessage = error
                }
            }
            .store(in: &cancellables)
    }

    func toggleVoiceRecording() {
        if isListening {
            #if targetEnvironment(simulator)
            isListening = false
            #else
            speechService.stopListening()
            #endif
            return
        }

        #if targetEnvironment(simulator)
        isListening = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isListening = false
            self?.searchQuery = "الفاتحة"
        }
        #else
        Task {
            let granted = await speechService.requestPermissions()
            guard granted else {
                permissionDenied = true
                errorMessage = "Microphone or speech recognition permission denied."
                return
            }
            await speechService.startListening()
        }
        #endif
    }

    func isSpeechAvailable() -> Bool {
        SFSpeechRecognizer(locale: Locale(identifier: "ar-SA"))?.isAvailable ?? false
    }

    // MARK: - History Management

    func saveToHistory(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        let item = SearchHistoryItem(query: trimmedQuery, category: selectedCategory)
        quranRepository.saveSearchHistory(item: item)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }

    func deleteFromHistory(_ item: SearchHistoryItem) {
        quranRepository.deleteSearchHistory(item: item)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }

    func clearSearchHistory() {
        quranRepository.clearSearchHistory(for: selectedCategory)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - UI Actions

    func updateCategory(_ category: SearchCategory) {
        selectedCategory = category
        clearSearch()
        clearFilters()
    }

    func applyFilters(surahIds: Set<Int>? = nil, juzNumbers: Set<Int>? = nil, tafsirType: TafsirType? = nil) {
        if let surahIds = surahIds { selectedSurahIds = surahIds }
        if let juzNumbers = juzNumbers { selectedJuzNumbers = juzNumbers }
        if let tafsirType = tafsirType { selectedTafsirType = tafsirType }

        if !searchQuery.isEmpty {
            performSearch(query: searchQuery)
        }
    }

    func clearFilters() {
        selectedSurahIds.removeAll()
        selectedJuzNumbers.removeAll()
        selectedTafsirType = .summary

        if !searchQuery.isEmpty {
            performSearch(query: searchQuery)
        }
    }

    // MARK: - Navigation Helpers

    /// Navigate to the first page of a surah (no ayah highlight)
    func navigateToSurah(_ surah: Surah) {
        selectedPageNumber = surah.pageStart
        selectedAyahNumber = nil
        navigateToMushaf = true
    }

    /// Navigate to the exact page of an ayah result with highlight
    func navigateToAyah(_ result: SearchResult) {
        selectedPageNumber = result.pageNumber
        selectedAyahNumber = result.ayah.number
        navigateToMushaf = true
    }

    func clearSearch() {
        searchQuery = ""
        searchResults = []
        wordMatchedAyahs = []
        errorMessage = nil
        isSearching = false
    }
}

