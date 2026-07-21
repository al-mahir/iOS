//
//  HomeViewModel.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Combine
import Foundation

public final class HomeViewModel: ObservableObject {
    @Published public var greeting: UserGreetingEntity?
    @Published public var lastRead: LastReadEntity?
    @Published public var sheikhs: [SheikhEntity] = []
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
    }

    public func loadDashboard() {
        getGreetingUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.greeting = $0 }).store(in: &cancellables)

        getLastReadUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.lastRead = $0 }).store(in: &cancellables)

        getSheikhsUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.sheikhs = $0 }).store(in: &cancellables)

        getActiveCirclesUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.circles = $0 }).store(in: &cancellables)

        getAyahOfTheDayUseCase.execute().receive(on: DispatchQueue.main)
            .sink(receiveCompletion: handleError, receiveValue: { [weak self] in self?.ayahOfTheDay = $0 }).store(in: &cancellables)
    }

    private func handleError(_ completion: Subscribers.Completion<Error>) {
        if case let .failure(error) = completion {
            self.errorMessage = error.localizedDescription
            print("Ayah API/Cache Error: \(error)")
        }
    }
}
