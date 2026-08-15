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

    // MARK: - Init

    private let listCirclesUseCase: ListCirclesUseCase

    public init(
        listCirclesUseCase: ListCirclesUseCase
    ) {
        self.listCirclesUseCase = listCirclesUseCase
    }

    // MARK: - Published State — Circle List

    @Published public var circles: [CircleModel] = []
    @Published public var searchQuery: String = "" {
        didSet { applyLocalFilter() }
    }
    @Published public var selectedStatus: CircleStatus? = nil {
        didSet { resetAndFetch() }
    }
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var hasMore: Bool = false

    // MARK: - Filter chips shown in the UI

    public let filterOptions: [(CircleStatus?, String)] = [
        (nil, "All"),
        (.scheduled, "Scheduled"),
        (.ongoing, "Live"),
        (.completed, "Completed"),
    ]

    // MARK: - Dependencies & Pagination

    private var allCircles: [CircleModel] = []
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Actions — Circle List

    public func fetchCircles() {
        currentPage = 0
        allCircles = []
        circles = []
        loadPage()
    }

    public func loadMore() {
        guard hasMore, !isLoading else { return }
        currentPage += 1
        loadPage()
    }

    public func clearError() { errorMessage = nil }

    // MARK: - Private Helpers

    private func resetAndFetch() {
        fetchCircles()
    }

    private func loadPage() {
        isLoading = true
        errorMessage = nil

        let params = ListCirclesParams(status: selectedStatus)
        let pageReq = CirclePageRequest(page: currentPage, size: pageSize)

        listCirclesUseCase
            .execute(params: params, page: pageReq)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.allCircles.append(contentsOf: page.items)
                self.hasMore = !page.isLast
                self.applyLocalFilter()
            }
            .store(in: &cancellables)
    }

    private func applyLocalFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if query.isEmpty {
            circles = allCircles
        } else {
            circles = allCircles.filter {
                $0.name.lowercased().contains(query)
            }
        }
    }
}
