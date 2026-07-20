//
//  MushafViewModel.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import Foundation

@MainActor
final class MushafViewModel: ObservableObject {
    @Published private(set) var pages: [Int: MushafPage] = [:]

    @Published var pageNumber: Int = 1
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?
    @Published var isTajweedEnabled = true

    let totalPages = 604

    private let getPage: GetMushafPageUseCase

    private var loadingTasks: [Int: Task<Void, Never>] = [:]

    nonisolated init(getPage: GetMushafPageUseCase, startPage: Int = 1) {
        self.getPage = getPage

        Task { @MainActor in
            self.pageNumber = startPage
            self.loadPageIfNeeded(startPage)
        }
    }

    var currentPage: MushafPage? {
        pages[pageNumber]
    }


    func loadPage(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        pageNumber = number
        loadPageIfNeeded(number)
        loadPageIfNeeded(min(number + 1, totalPages))
        loadPageIfNeeded(max(number - 1, 1))
    }

    func loadPageIfNeeded(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        guard pages[number] == nil, loadingTasks[number] == nil else { return }

        if number == pageNumber {
            isLoading = true
            errorMessage = nil
        }

        loadingTasks[number] = Task {
            defer { loadingTasks[number] = nil }

            do {
                await Task.yield()
                let loadedPage = try getPage.execute(pageNumber: number)

                if !Task.isCancelled {
                    pages[number] = loadedPage
                    if number == pageNumber {
                        isLoading = false
                    }
                }
            } catch {
                if !Task.isCancelled, number == pageNumber {
                    errorMessage = "Failed to load page \(number): \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }

    func nextPage() { loadPage(pageNumber + 1) }
    func previousPage() { loadPage(pageNumber - 1) }
}
