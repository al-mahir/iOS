//
//  EditCircleViewModel.swift
//  Circles
//
//  Created by Nadin Ahmed on 15/08/2026.
//

import Combine
import Foundation

@MainActor
public final class EditCircleViewModel: ObservableObject {
    public let circle: CircleModel

    private let updateCircleUseCase: UpdateCircleUseCase
    private var cancellables = Set<AnyCancellable>()

    @Published public var name: String
    @Published public var startDate: Date {
        didSet {
            if endDate <= startDate {
                endDate = startDate.addingTimeInterval(3600)
            }
        }
    }
    @Published public var endDate: Date
    @Published public var isSaving = false
    @Published public var errorMessage: String?

    public init(circle: CircleModel, updateCircleUseCase: UpdateCircleUseCase) {
        self.circle = circle
        self.updateCircleUseCase = updateCircleUseCase
        name = circle.name
        startDate = circle.startDate
        endDate = circle.endDate
    }

    public var isFormValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && endDate > startDate
    }

    public func save(onUpdated: @escaping (CircleModel) -> Void) {
        guard isFormValid, !isSaving else { return }

        isSaving = true
        errorMessage = nil

        let params = UpdateCircleParams(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate
        )

        updateCircleUseCase
            .execute(circle: circle, params: params)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isSaving = false
                if case .failure(let error) = completion {
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { updatedCircle in
                onUpdated(updatedCircle)
            }
            .store(in: &cancellables)
    }
}
