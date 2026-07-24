//
//  File.swift
//
//
//  Created by Esraa Ehab on 21/07/2026.
//

import SwiftUI
import Combine

@MainActor
public class ProfileStatsViewModel: ObservableObject {
    @Published var stats: ProfileStats?
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    private let getStatsUseCase: GetProfileStatsUseCase
    
    nonisolated public init(useCase: GetProfileStatsUseCase) {
            self.getStatsUseCase = useCase
        }
    
    func loadStats() async {
        isLoading = true
        errorMessage = nil
        do {
            self.stats = try await getStatsUseCase.execute()
        } catch {
            self.errorMessage = "Error occure when load statistics"
        }
        isLoading = false
    }
}
