//
//  HomeRepositoryProtocol.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//




import Combine

public protocol HomeRepositoryProtocol {
    func fetchGreeting() -> AnyPublisher<UserGreetingEntity, Error>
    func fetchLastRead() -> AnyPublisher<LastReadEntity?, Error>
    func fetchSheikhs() -> AnyPublisher<[SheikhEntity], Error>
    func fetchActiveCircles() -> AnyPublisher<[ActiveCircleEntity], Error>
    func fetchAyahOfTheDay() -> AnyPublisher<AyahOfTheDayEntity, Error>
}
