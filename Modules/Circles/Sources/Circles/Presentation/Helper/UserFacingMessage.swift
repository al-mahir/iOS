//
//  UserFacingMessage.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

// MARK: - Private Helpers

internal func userFacingMessage(for error: CircleError) -> String {
    switch error {
    case .timeOverlap:
        return "You already have a circle scheduled at this time. Choose a different time."
    case .circleFull:
        return "This circle is full."
    case .notOwner:
        return "You don't have permission to do that."
    case .unauthorized:
        return "Please sign in and try again."
    case .notFound:
        return "Circle not found."
    case .invalidStateTransition(_, let attempted):
        return "Cannot \(attempted) the circle right now."
    case .network(let networkError):
        return networkError.errorDescription ?? "A network error occurred."
    case .unknown(let message):
        return message
    }
}
