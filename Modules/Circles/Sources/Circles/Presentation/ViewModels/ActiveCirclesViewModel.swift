//
//  ActiveCirclesViewModel.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Combine
import Common
import Foundation

@MainActor
public final class ActiveCirclesViewModel: ObservableObject {
    @Published public var circles: [CircleModel] = []
    @Published public var searchQuery: String = "" {
        didSet {
            performSearch()
        }
    }
    @Published public var selectedCategory: String = "All" {
        didSet {
            performSearch()
        }
    }
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    public let categories: [String] = [
        "All", "Juz Amma", "Surah Al-Baqarah", "Surah Al-Kahf",
    ]

    private let repository: CirclesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(repository: CirclesRepositoryProtocol = CirclesRepositoryImpl())
    {
        self.repository = repository
        fetchCircles()
    }

    public func fetchCircles() {
        isLoading = true
        errorMessage = nil

        repository.fetchActiveCircles()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] circles in
                self?.circles = circles
            }
            .store(in: &cancellables)
    }

    public func performSearch() {
        isLoading = true

        let catFilter = selectedCategory == "All" ? nil : selectedCategory

        repository.searchCircles(query: searchQuery, category: catFilter)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] circles in
                self?.circles = circles
            }
            .store(in: &cancellables)
    }
}
