//
//  InMemoryCirclesDataSource.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Foundation

public final class InMemoryCirclesDataSource: @unchecked Sendable {
    public static let shared = InMemoryCirclesDataSource()

    private var circles: [CircleModel]
    private var joinRequests: [String: JoinRequest] = [:]
    private let queue = DispatchQueue(label: "com.almahir.circles.datasource", attributes: .concurrent)

    public init(initialCircles: [CircleModel]? = nil) {
        if let initialCircles = initialCircles {
            self.circles = initialCircles
        } else {
            self.circles = [
                CircleModel(
                    id: "c1",
                    name: "Surah Yasin",
                    topic: "Surah Yasin",
                    sheikhName: "Sheikh Ahmad",
                    sheikhInitials: "SA",
                    level: .intermediate,
                    visibility: .publicCircle,
                    isLive: true,
                    currentParticipants: 12,
                    maxParticipants: 20,
                    requiresApproval: true
                ),
                CircleModel(
                    id: "c2",
                    name: "Surah Al-Kahf",
                    topic: "Surah Al-Kahf",
                    sheikhName: "Sheikh Omar",
                    sheikhInitials: "SO",
                    level: .beginner,
                    visibility: .publicCircle,
                    isLive: true,
                    currentParticipants: 8,
                    maxParticipants: 10,
                    requiresApproval: true
                ),
                CircleModel(
                    id: "c3",
                    name: "Surah Al-Baqarah",
                    topic: "Surah Al-Baqarah",
                    sheikhName: "Sheikh Hassan",
                    sheikhInitials: "SH",
                    level: .advanced,
                    visibility: .publicCircle,
                    isLive: true,
                    currentParticipants: 25,
                    maxParticipants: 25,
                    requiresApproval: true
                ),
                CircleModel(
                    id: "c4",
                    name: "Juz Amma",
                    topic: "Juz Amma",
                    sheikhName: "Sheikh Ibrahim",
                    sheikhInitials: "SI",
                    level: .beginner,
                    visibility: .publicCircle,
                    isLive: true,
                    currentParticipants: 5,
                    maxParticipants: 12,
                    requiresApproval: true
                )
            ]
        }
    }

    public func getCircles() -> [CircleModel] {
        queue.sync { circles }
    }

    public func addCircle(_ circle: CircleModel) -> CircleModel {
        queue.sync(flags: .barrier) {
            circles.insert(circle, at: 0)
            return circle
        }
    }

    public func createJoinRequest(circleId: String) -> JoinRequest? {
        queue.sync(flags: .barrier) {
            guard let circle = circles.first(where: { $0.id == circleId }) else { return nil }
            let request = JoinRequest(
                circleId: circle.id,
                circleName: circle.name,
                sheikhName: circle.sheikhName,
                status: .pending
            )
            joinRequests[request.id] = request
            return request
        }
    }

    public func cancelJoinRequest(requestId: String) {
        queue.sync(flags: .barrier) {
            if var req = joinRequests[requestId] {
                req = JoinRequest(
                    id: req.id,
                    circleId: req.circleId,
                    circleName: req.circleName,
                    sheikhName: req.sheikhName,
                    status: .cancelled,
                    requestedAt: req.requestedAt
                )
                joinRequests[requestId] = req
            }
        }
    }
}
