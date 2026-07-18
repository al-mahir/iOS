//
//  SearchViewModel.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchQuery: String = ""
    @Published var selectedCategory: SearchCategory = .surah
    @Published var searchResults: [SearchResult] = []
    @Published var allSurahs: [Surah] = []
    @Published var allJuz: [Juz] = []
    @Published var searchHistory: [SearchHistoryItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedPageNumber: Int?
    @Published var navigateToMushaf: Bool = false
    
    // Filter Properties
    @Published var selectedSurahIds: Set<Int> = []
    @Published var selectedJuzNumbers: Set<Int> = []
    @Published var selectedTafsirType: TafsirType = .summary
    
    // MARK: - Dependencies
    private let repository: QuranRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchDebouncer: AnyCancellable?
    
    // MARK: - Computed Properties
    var filteredSurahs: [Surah] {
        if searchQuery.isEmpty {
            return allSurahs
        }
        return allSurahs.filter { surah in
            surah.name.localizedCaseInsensitiveContains(searchQuery) ||
            surah.englishName.localizedCaseInsensitiveContains(searchQuery) ||
            surah.arabicName.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    var filteredJuz: [Juz] {
        if searchQuery.isEmpty {
            return allJuz
        }
        return allJuz.filter { "\($0.number)".contains(searchQuery) }
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
    
    // MARK: - Initialization
    init(repository: QuranRepositoryProtocol = MockQuranRepository()) {
        self.repository = repository
        setupSearchDebouncer()
        loadInitialData()
    }
    
    // MARK: - Setup
    private func setupSearchDebouncer() {
        searchDebouncer = $searchQuery
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
    }
    
    // MARK: - Public Methods
    func loadInitialData() {
        loadSurahs()
        loadJuz()
        loadSearchHistory()
    }
    
    func loadSurahs() {
        isLoading = true
        repository.fetchAllSurahs()
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
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
        repository.fetchAllJuz()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] juz in
                    self?.allJuz = juz
                }
            )
            .store(in: &cancellables)
    }
    
    func loadSearchHistory() {
        repository.fetchSearchHistory()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] history in
                    self?.searchHistory = history
                }
            )
            .store(in: &cancellables)
    }
    
    func performSearch(query: String = "") {
        // For Surah and Juz, we show filtered lists even when query is empty
        if selectedCategory == .surah || selectedCategory == .juz {
            if query.isEmpty {
                searchResults = []
                return
            }
        }
        
        // For Ayah and Semantic, only search if there's a query
        if (selectedCategory == .ayah || selectedCategory == .semantic) && query.isEmpty {
            searchResults = []
            return
        }
        
        isLoading = true
        repository.search(
            query: query,
            category: selectedCategory,
            filters: currentFilter
        )
        .sink(
            receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            },
            receiveValue: { [weak self] results in
                self?.searchResults = results
                if !results.isEmpty {
                    self?.saveToHistory(query: query)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    func saveToHistory(query: String) {
        let item = SearchHistoryItem(query: query, category: selectedCategory)
        repository.saveSearchHistory(item: item)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }
    
    func deleteFromHistory(_ item: SearchHistoryItem) {
        repository.deleteSearchHistory(item: item)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }
    
    func clearSearchHistory() {
        repository.clearSearchHistory()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.searchHistory = []
                }
            )
            .store(in: &cancellables)
    }
    
    func updateCategory(_ category: SearchCategory) {
        selectedCategory = category
        // Reset filters when changing category
        if category == .surah || category == .juz {
            selectedSurahIds.removeAll()
            selectedJuzNumbers.removeAll()
        }
        // Clear results when switching categories
        searchResults = []
        // Re-run search with new category
        if !searchQuery.isEmpty {
            performSearch(query: searchQuery)
        }
    }
    
    func applyFilters(surahIds: Set<Int>? = nil, juzNumbers: Set<Int>? = nil, tafsirType: TafsirType? = nil) {
        if let surahIds = surahIds {
            selectedSurahIds = surahIds
        }
        if let juzNumbers = juzNumbers {
            selectedJuzNumbers = juzNumbers
        }
        if let tafsirType = tafsirType {
            selectedTafsirType = tafsirType
        }
        
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
    
    func navigateToAyah(_ result: SearchResult) {
        selectedPageNumber = result.pageNumber
        navigateToMushaf = true
    }
}
