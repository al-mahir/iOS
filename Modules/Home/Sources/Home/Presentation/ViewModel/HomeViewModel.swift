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
import Circles

public final class HomeViewModel: ObservableObject {
    @Published public var greeting: UserGreetingEntity?
    @Published public var lastRead: LastReadEntity?
    @Published public var sheikhs: [Sheikh] = []
    @Published public var circles: [CircleModel] = []
    @Published public var isLoadingCircles: Bool = false
    @Published public var ayahOfTheDay: AyahOfTheDayEntity?
    @Published public var errorMessage: String?

    private let getGreetingUseCase: GetGreetingUseCaseProtocol
    private let getLastReadUseCase: GetLastReadUseCaseProtocol
    private let getSheikhsUseCase: GetSheikhsUseCaseProtocol
    private let listCirclesUseCase: ListCirclesUseCase
    private let getActiveCirclesUseCase: GetActiveCirclesUseCaseProtocol
    private let getAyahOfTheDayUseCase: GetAyahOfTheDayUseCaseProtocol
    
    private var cancellables = Set<AnyCancellable>()

    public init(
        getGreetingUseCase: GetGreetingUseCaseProtocol,
        getLastReadUseCase: GetLastReadUseCaseProtocol,
        getSheikhsUseCase: GetSheikhsUseCaseProtocol,
        getActiveCirclesUseCase: GetActiveCirclesUseCaseProtocol,
        getAyahOfTheDayUseCase: GetAyahOfTheDayUseCaseProtocol,
        listCirclesUseCase: ListCirclesUseCase = ListCirclesUseCase(repository: CircleRepository())
    ) {
        self.getGreetingUseCase = getGreetingUseCase
        self.getLastReadUseCase = getLastReadUseCase
        self.getSheikhsUseCase = getSheikhsUseCase
        self.getActiveCirclesUseCase = getActiveCirclesUseCase
        self.getAyahOfTheDayUseCase = getAyahOfTheDayUseCase
        self.listCirclesUseCase = listCirclesUseCase
        
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

        isLoadingCircles = true
        listCirclesUseCase.execute(params: ListCirclesParams(), page: CirclePageRequest(page: 0, size: 5))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingCircles = false
                if case .failure(let error) = completion {
                    print("Circles fetch error on Home dashboard: \(error)")
                }
            } receiveValue: { [weak self] page in
                self?.circles = Array(page.items.prefix(5))
            }
            .store(in: &cancellables)

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
