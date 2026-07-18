//
//  MushafViewModel.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation

@MainActor
final class MushafViewModel: ObservableObject {
    @Published private(set) var currentPage: MushafPage?
    @Published var pageNumber: Int = 1
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published var isTajweedEnabled = true

    let totalPages = 604
    private let getPage: GetMushafPageUseCase
    private var activeLoadingTask: Task<Void, Never>?

    nonisolated init(getPage: GetMushafPageUseCase, startPage: Int = 1) {
        self.getPage = getPage
        
        Task { @MainActor in
            self.pageNumber = startPage
            self.loadPageData(number: startPage)
        }
    }

    func loadPage(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        pageNumber = number
        loadPageData(number: number)
    }
    

    private func loadPageData(number: Int) {
        activeLoadingTask?.cancel()
        
        isLoading = true
        errorMessage = nil
        
        activeLoadingTask = Task {
            do {
                await Task.yield()
                
                let loadedPage = try getPage.execute(pageNumber: number)
                
                if !Task.isCancelled {
                    self.currentPage = loadedPage
                    self.isLoading = false
                }
            } catch {
                if !Task.isCancelled {
                    self.errorMessage = "Failed to load page \(number): \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    func nextPage() { loadPage(pageNumber + 1) }
    func previousPage() { loadPage(pageNumber - 1) }
}
