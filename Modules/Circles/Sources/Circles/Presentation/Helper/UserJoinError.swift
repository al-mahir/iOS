//
//  UserJoinError.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

@MainActor
internal func handleJoinError(_ error: CircleError) -> String {
    switch error {
    case .circleFull:
        return localizedCircleString("This circle is full.")
    case .timeOverlap:
        return localizedCircleString("You already have a circle scheduled at this time.")
    case .notFound:
        return localizedCircleString("Circle not found.")
    case .unauthorized:
        return localizedCircleString("Please sign in and try again.")
    case .notOwner:
        return localizedCircleString("You don't have permission to join this circle.")
    case .invalidStateTransition(_, let attempted):
        return localizedCircleString(
            "Cannot %@ the circle right now.",
            localizedCircleString(attempted)
        )
    case .network(let networkError):
        return networkUserFacingMessage(for: networkError)
    case .unknown(let message):
        return message
    }
}
