//
//  SheikhListViewModel.swift
//  Sheikh
//

import Foundation
import Combine
import Swinject
import Common

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
            source = searchResults.compactMap { res in
                allSheikhs.first(where: { $0.id == res.id }) ?? res.toSheikh()
            }
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

    private let getSheikhsUseCase: any GetSheikhsUseCaseProtocol
    private let toggleFavoriteUseCase: any ToggleFavoriteSheikhUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(
        getSheikhsUseCase: (any GetSheikhsUseCaseProtocol)? = nil,
        toggleFavoriteUseCase: (any ToggleFavoriteSheikhUseCaseProtocol)? = nil
    ) {
        self.getSheikhsUseCase = getSheikhsUseCase ?? SheikhDIContainer.shared.container.resolve((any GetSheikhsUseCaseProtocol).self)!
        self.toggleFavoriteUseCase = toggleFavoriteUseCase ?? SheikhDIContainer.shared.container.resolve((any ToggleFavoriteSheikhUseCaseProtocol).self)!
        observeSearchText()
    }

    public func toggleFavorite(sheikh: Sheikh) {
        if let index = allSheikhs.firstIndex(where: { $0.id == sheikh.id }) {
            allSheikhs[index].isFavorite.toggle()
        }
        toggleFavoriteUseCase.execute(id: sheikh.id)
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { [weak self] isFav in
                if let index = self?.allSheikhs.firstIndex(where: { $0.id == sheikh.id }) {
                    self?.allSheikhs[index].isFavorite = isFav
                }
            }
            .store(in: &cancellables)
    }

    public func loadSheikhs() {
        if allSheikhs.isEmpty {
            fetchAllSheikhs()
        }
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

        getSheikhsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = localizedSheikhString("Something went wrong")
                }
            } receiveValue: { [weak self] sheikhs in
                self?.allSheikhs = sheikhs
            }
            .store(in: &cancellables)
    }

    private func observeSearchText() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self else { return }
                let query = text.trimmingCharacters(in: .whitespaces).lowercased()
                if query.isEmpty {
                    self.searchResults = []
                } else {
                    let matches = self.allSheikhs.filter {
                        $0.fullName.lowercased().contains(query) ||
                        $0.username.lowercased().contains(query)
                    }
                    self.searchResults = matches.map { sheikh in
                        SheikhSearchResult(
                            id: sheikh.id,
                            firstName: sheikh.firstName,
                            lastName: sheikh.lastName,
                            rate: sheikh.rate
                        )
                    }
                }
            }
            .store(in: &cancellables)
    }
}
