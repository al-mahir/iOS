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
    @Published public var circleName: String = ""
    @Published public var selectedTopic: String = ""
    @Published public var visibility: CircleVisibility = .publicCircle
    @Published public var participantLimit: Int = 10
    @Published public var requiresApproval: Bool = true
    @Published public var sheikhName: String = "Sheikh Ahmad"
    @Published public var sheikhInitials: String = "SA"

    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var isCreatedSuccessfully: Bool = false

    public let topics: [String] = [
        "Surah Yasin",
        "Surah Al-Kahf",
        "Surah Al-Baqarah",
        "Surah Al-Mulk",
        "Juz Amma",
        "General Recitation",
    ]

    private let repository: CirclesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(repository: CirclesRepositoryProtocol = CirclesRepositoryImpl())
    {
        self.repository = repository
    }

    public var isFormValid: Bool {
        !circleName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !selectedTopic.isEmpty
    }

    public func incrementParticipantLimit() {
        if participantLimit < 50 {
            participantLimit += 1
        }
    }

    public func decrementParticipantLimit() {
        if participantLimit > 2 {
            participantLimit -= 1
        }
    }

    public func createCircle(completion: @escaping (CircleModel) -> Void) {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields."
            return
        }

        isLoading = true
        errorMessage = nil

        let newCircle = CircleModel(
            name: circleName.trimmingCharacters(in: .whitespacesAndNewlines),
            topic: selectedTopic,
            sheikhName: sheikhName,
            sheikhInitials: sheikhInitials,
            level: .intermediate,
            visibility: visibility,
            isLive: true,
            currentParticipants: 1,
            maxParticipants: participantLimit,
            requiresApproval: requiresApproval
        )

        repository.createCircle(newCircle)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] comp in
                self?.isLoading = false
                if case .failure(let error) = comp {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] circle in
                self?.isCreatedSuccessfully = true
                completion(circle)
            }
            .store(in: &cancellables)
    }
}
