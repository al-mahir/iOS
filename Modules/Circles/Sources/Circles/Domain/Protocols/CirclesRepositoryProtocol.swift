//
//  CirclesRepositoryProtocol.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation
import Combine

public protocol CirclesRepositoryProtocol: Sendable {
    func fetchActiveCircles() -> AnyPublisher<[CircleModel], Error>
    func searchCircles(query: String, category: String?) -> AnyPublisher<[CircleModel], Error>
    func createCircle(_ circle: CircleModel) -> AnyPublisher<CircleModel, Error>
    func requestToJoin(circleId: String) -> AnyPublisher<JoinRequest, Error>
    func cancelJoinRequest(requestId: String) -> AnyPublisher<Void, Error>
}
