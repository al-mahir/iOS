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
class SearchViewModel: ObservableObject {
    
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
    
    @Published var selectedSurahIds: Set<Int> = []
    @Published var selectedJuzNumbers: Set<Int> = []
    @Published var selectedTafsirType: TafsirType = .summary
    
    // Speech recognition
    @Published var isListening: Bool = false
    @Published var permissionDenied: Bool = false
    
    private let repository: QuranRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private let speechService = SpeechService()
    
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
    
    var currentCategoryHistory: [SearchHistoryItem] {
        searchHistory.filter { $0.category == selectedCategory }
    }
    
    // MARK: - Initialization
    
    init(repository: QuranRepositoryProtocol = MockQuranRepository()) {
        self.repository = repository
        setupSearchDebouncer()
        setupSpeechService()
        loadInitialData()
    }
    

    private func setupSpeechService() {
        // Subscribe to speech transcript updates with debug
        speechService.$transcript
            .filter { !$0.isEmpty }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                print("📝 Speech recognized: \(text)") // Debug print
                guard let self else { return }
                self.searchQuery = text
                self.performSearch(query: text)
            }
            .store(in: &cancellables)
        
        // Subscribe to listening state with debug
        speechService.$isListening
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isListening in
                print("🎤 Listening state: \(isListening)") // Debug print
                self?.isListening = isListening
            }
            .store(in: &cancellables)
        
        // Subscribe to speech errors with debug
        speechService.$error
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                if let error = error {
                    print("❌ Speech error: \(error)") // Debug print
                    self?.errorMessage = error
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupSearchDebouncer() {
        $searchQuery
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    self.searchResults = []
                } else {
                    self.performSearch(query: query)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Speech Recognition Methods
    
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
        // Simulator fallback for testing
        print("🎤 Simulator: Using mock speech")
        isListening = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isListening = false
            let mockSearchTerms = ["Al-Fatiha", "Ayat Al-Kursi", "Al-Ikhlas", "Ar-Rahman"]
            let randomTerm = mockSearchTerms.randomElement() ?? "Al-Fatiha"
            print("📝 Mock speech result: \(randomTerm)")
            self.searchQuery = randomTerm
            self.performSearch(query: randomTerm)
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
        return SFSpeechRecognizer(locale: Locale(identifier: "en-US"))?.isAvailable ?? false
    }
    
    // MARK: - Data Loaders
    
    func loadInitialData() {
        loadSurahs()
        loadJuz()
        loadSearchHistory()
    }
    
    func loadSurahs() {
        isLoading = true
        repository.fetchAllSurahs()
            .receive(on: DispatchQueue.main)
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
        repository.fetchSearchHistory()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] history in
                    self?.searchHistory = history
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Search Logic
    
    func performSearch(query: String = "") {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedQuery.isEmpty {
            searchResults = []
            return
        }
        
        if selectedCategory == .surah {
            if !filteredSurahs.isEmpty {
                saveToHistory(query: trimmedQuery)
            }
            return
        }
        
        if selectedCategory == .juz {
            if !filteredJuz.isEmpty {
                saveToHistory(query: trimmedQuery)
            }
            return
        }
        
        isLoading = true
        repository.search(
            query: trimmedQuery,
            category: selectedCategory,
            filters: currentFilter
        )
        .receive(on: DispatchQueue.main)
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
                    self?.saveToHistory(query: trimmedQuery)
                }
            }
        )
        .store(in: &cancellables)
    }
    
    // MARK: - History Management
    
    func saveToHistory(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }
        
        let item = SearchHistoryItem(query: trimmedQuery, category: selectedCategory)
        repository.saveSearchHistory(item: item)
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
        repository.deleteSearchHistory(item: item)
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
        repository.clearSearchHistory(for: selectedCategory)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.loadSearchHistory()
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - View Actions
    
    func updateCategory(_ category: SearchCategory) {
        selectedCategory = category
        
        if category == .surah || category == .juz {
            selectedSurahIds.removeAll()
            selectedJuzNumbers.removeAll()
        }
        
        searchResults = []
        
        if !searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            performSearch(query: searchQuery)
        }
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
    
    func navigateToAyah(_ result: SearchResult) {
        selectedPageNumber = result.pageNumber
        navigateToMushaf = true
    }
}
