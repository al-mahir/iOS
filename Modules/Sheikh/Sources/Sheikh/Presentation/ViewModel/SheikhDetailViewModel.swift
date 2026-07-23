//
//  SheikhDetailViewModel.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import Combine

@MainActor
public final class SheikhDetailViewModel: ObservableObject {

    @Published public var sheikh: Sheikh? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    private let sheikhID: String
    private let repository: any SheikhRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    
    public init(sheikhID: String, prefetched: Sheikh? = nil) {
        self.sheikhID = sheikhID
        self.repository = SheikhEnvironment.makeRepository()
        self.sheikh = prefetched
    }

    init(
        sheikhID: String,
        prefetched: Sheikh? = nil,
        repository: any SheikhRepositoryProtocol
    ) {
        self.sheikhID = sheikhID
        self.repository = repository
        self.sheikh = prefetched
    }

    
    public func loadDetail() {
        guard sheikh == nil else { return }
        fetchDetail()
    }

    public func refresh() {
        fetchDetail()
    }

    public func clearError() {
        errorMessage = nil
    }


    private func fetchDetail() {
        isLoading = true
        errorMessage = nil

        repository.getSheikhByID(sheikhID)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] sheikh in
                self?.sheikh = sheikh
            }
            .store(in: &cancellables)
    }
}
