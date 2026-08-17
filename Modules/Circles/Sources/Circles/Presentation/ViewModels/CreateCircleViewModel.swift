//
//  CreateCircleViewModel.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Combine
import Common
import Foundation

@MainActor
public final class CreateCircleViewModel: ObservableObject {

    // MARK: - Init

    public let createCircleUseCase: CreateCircleUseCase

    public init(createCircleUseCase: CreateCircleUseCase) {
        self.createCircleUseCase = createCircleUseCase
    }

    // MARK: - Published State

    @Published public var circleName: String = ""
    @Published public var startDate: Date = Date() {
        didSet {
            if endDate <= startDate {
                endDate = startDate.addingTimeInterval(3600)
            }
        }
    }
    @Published public var endDate: Date = Date().addingTimeInterval(3600)
    @Published public var maxParticipants: Int = 10
    @Published public var requiresApproval: Bool = true
    @Published public var gender: Gender = .male

    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isCreatedSuccessfully: Bool = false

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Validation

    public var isFormValid: Bool {
        !circleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && endDate > startDate
    }

    // MARK: - Actions

    public func incrementParticipants() {
        if maxParticipants < 100 { maxParticipants += 1 }
    }

    public func decrementParticipants() {
        if maxParticipants > 2 { maxParticipants -= 1 }
    }

    public func createCircle(completion: @escaping (CircleModel) -> Void) {
        guard isFormValid else {
#if DEBUG
            print("[CircleDebug] Create private circle blocked: invalid form")
#endif
            errorMessage = localizedCircleString("Please fill in all required fields.")
            return
        }

        isLoading = true
        errorMessage = nil

        let params = CreateCircleParams(
            name: circleName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            type: .private,
            requiresApproval: requiresApproval,
            maxParticipants: maxParticipants
            // TODO: include gender in CreateCircleParams once backend supports it
        )

#if DEBUG
        print("[CircleDebug] Create private circle started: requiresApproval=\(params.requiresApproval), maxParticipants=\(params.maxParticipants)")
#endif

        createCircleUseCase
            .execute(params)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
#if DEBUG
                    print("[CircleDebug] Create private circle failed: \(error)")
#endif
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] circle in
                guard let self else { return }
                guard !(circle.inviteToken?.isEmpty ?? true) else {
#if DEBUG
                    print("[CircleDebug] Create private circle succeeded without an invite token: circleId=\(circle.id)")
#endif
                    self.errorMessage = localizedCircleString(
                        "Circle created, but its invite token was unavailable."
                    )
                    return
                }
#if DEBUG
                print("[CircleDebug] Create private circle succeeded: circleId=\(circle.id), requiresApproval=\(circle.requiresApproval)")
#endif
                self.isCreatedSuccessfully = true
                completion(circle)
            }
            .store(in: &cancellables)
    }

    public func clearError() { errorMessage = nil }
}
