//
//  CirclesRepositoryImpl.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation
import Combine

public final class CirclesRepositoryImpl: CirclesRepositoryProtocol, @unchecked Sendable {
    private let dataSource: InMemoryCirclesDataSource

    public init(dataSource: InMemoryCirclesDataSource = .shared) {
        self.dataSource = dataSource
    }

    public func fetchActiveCircles() -> AnyPublisher<[CircleModel], Error> {
        let circles = dataSource.getCircles()
        return Just(circles)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func searchCircles(query: String, category: String?) -> AnyPublisher<[CircleModel], Error> {
        var circles = dataSource.getCircles()

        if let category = category, !category.isEmpty, category != "All" {
            circles = circles.filter { circle in
                circle.topic.localizedCaseInsensitiveContains(category) ||
                circle.name.localizedCaseInsensitiveContains(category)
            }
        }

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedQuery.isEmpty {
            circles = circles.filter { circle in
                circle.name.localizedCaseInsensitiveContains(trimmedQuery) ||
                circle.sheikhName.localizedCaseInsensitiveContains(trimmedQuery) ||
                circle.topic.localizedCaseInsensitiveContains(trimmedQuery)
            }
        }

        return Just(circles)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func createCircle(_ circle: CircleModel) -> AnyPublisher<CircleModel, Error> {
        let created = dataSource.addCircle(circle)
        return Just(created)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func requestToJoin(circleId: String) -> AnyPublisher<JoinRequest, Error> {
        guard let request = dataSource.createJoinRequest(circleId: circleId) else {
            return Fail(error: NSError(domain: "CirclesError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Circle not found"]))
                .eraseToAnyPublisher()
        }
        return Just(request)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    public func cancelJoinRequest(requestId: String) -> AnyPublisher<Void, Error> {
        dataSource.cancelJoinRequest(requestId: requestId)
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
