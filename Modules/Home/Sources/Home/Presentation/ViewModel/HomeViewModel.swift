//
//  HomeViewModel.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine
import Foundation
import Common
import Sheikh
import NetworkKit

public final class HomeViewModel: ObservableObject {
    @Published public var greeting: UserGreetingEntity?
    @Published public var lastRead: LastReadEntity?
    @Published public var sheikhs: [Sheikh] = [Sheikh.dummyTestSheikh]
    @Published public var circles: [ActiveCircleEntity] = []
    @Published public var ayahOfTheDay: AyahOfTheDayEntity?
    @Published public var errorMessage: String?

    private let getGreetingUseCase: GetGreetingUseCaseProtocol
    private let getLastReadUseCase: GetLastReadUseCaseProtocol
    private let getSheikhsUseCase: GetSheikhsUseCaseProtocol
    private let getActiveCirclesUseCase: GetActiveCirclesUseCaseProtocol
    private let getAyahOfTheDayUseCase: GetAyahOfTheDayUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()

    public init(
        getGreetingUseCase: GetGreetingUseCaseProtocol,
        getLastReadUseCase: GetLastReadUseCaseProtocol,
        getSheikhsUseCase: GetSheikhsUseCaseProtocol,
        getActiveCirclesUseCase: GetActiveCirclesUseCaseProtocol,
        getAyahOfTheDayUseCase: GetAyahOfTheDayUseCaseProtocol
    ) {
        self.getGreetingUseCase = getGreetingUseCase
        self.getLastReadUseCase = getLastReadUseCase
        self.getSheikhsUseCase = getSheikhsUseCase
        self.getActiveCirclesUseCase = getActiveCirclesUseCase
        self.getAyahOfTheDayUseCase = getAyahOfTheDayUseCase
        
        loadDashboard()

        NotificationCenter.default.publisher(for: .readingProgressDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadLastRead()
            }
            .store(in: &cancellables)
    }

    public func loadDashboard() {
        getGreetingUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.greeting = $0 }).store(in: &cancellables)

        loadLastRead()

        getSheikhsUseCase.execute()
            .map { list -> [Sheikh] in
                if list.isEmpty {
                    return [Sheikh.dummyTestSheikh]
                }
                return Array(list.prefix(5))
            }
            .catch { _ in
                Just([Sheikh.dummyTestSheikh])
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in self?.sheikhs = $0 })
            .store(in: &cancellables)

        getActiveCirclesUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.circles = $0 }).store(in: &cancellables)

        getAyahOfTheDayUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.ayahOfTheDay = $0 }).store(in: &cancellables)
    }

    public func loadLastRead() {
        getLastReadUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.lastRead = $0 }).store(in: &cancellables)
    }

    private func handleError(_ completion: Subscribers.Completion<Error>) {
        if case let .failure(error) = completion {
            self.errorMessage = error.localizedDescription
            print("Ayah API/Cache Error: \(error)")
        }
    }
}
