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
    @Published var pageNumber: Int
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    @Published var isTajweedEnabled = true

    let totalPages = 604

    private let getPage: GetMushafPageUseCase

    init(getPage: GetMushafPageUseCase, startPage: Int = 1) {
        self.getPage = getPage
        self.pageNumber = startPage
        loadPage(startPage)
    }

    func loadPage(_ number: Int) {
        guard number >= 1, number <= totalPages else { return }
        pageNumber = number
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            currentPage = try getPage.execute(pageNumber: number)
        } catch {
            errorMessage = "Failed to load page \(number): \(error.localizedDescription)"
        }
    }

    func nextPage() { loadPage(pageNumber + 1) }
    func previousPage() { loadPage(pageNumber - 1) }
}
