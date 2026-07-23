//
//  SheikhListViewModel.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import Combine

public enum SheikhFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case available = "Available Only"
    case inSession = "In Session"

    public var id: String { rawValue }
}

@MainActor
public final class SheikhListViewModel: ObservableObject {

    @Published public var allSheikhs: [Sheikh] = []
    @Published public var searchResults: [SheikhSearchResult] = []
    @Published public var searchText: String = ""
    @Published public var selectedFilter: SheikhFilter = .all
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    public var displayedSheikhs: [Sheikh] {
        let source: [Sheikh]

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            source = allSheikhs
        } else {
            source = searchResults.map { $0.toSheikh() }
        }

        switch selectedFilter {
        case .all:
            return source
        case .available:
            return source.filter { $0.sheikhStatus == .available }
        case .inSession:
            return source.filter { $0.sheikhStatus == .notAvailable }
        }
    }

    private let repository: any SheikhRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    public init() {
        self.repository = SheikhEnvironment.makeRepository()
        observeSearchText()
    }

    init(repository: any SheikhRepositoryProtocol) {
        self.repository = repository
        observeSearchText()
    }

    public func loadSheikhs() {
        guard allSheikhs.isEmpty else { return }
        fetchAllSheikhs()
    }

    public func refresh() {
        fetchAllSheikhs()
    }

    public func clearError() {
        errorMessage = nil
    }

    private func fetchAllSheikhs() {
        isLoading = true
        errorMessage = nil

        repository.getAllSheikhs()
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] sheikhs in
                self?.allSheikhs = sheikhs
            }
            .store(in: &cancellables)
    }

    private func observeSearchText() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                let trimmed = text.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    self.searchResults = []
                } else {
                    self.performSearch(name: trimmed)
                }
            }
            .store(in: &cancellables)
    }

    private func performSearch(name: String) {
        repository.searchSheikhs(name: name)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }
}
