//
//  UserJoinError.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

internal func handleJoinError(_ error: CircleError) -> String {
    switch error {
    case .invalidPassword:
        return "Incorrect circle code. Please try again."
    case .circleFull:
        return "This circle is full."
    case .timeOverlap:
        return "You already have a circle scheduled at this time."
    case .notFound:
        return "Circle not found."
    case .unauthorized:
        return "Please sign in and try again."
    case .notOwner:
        return "You don't have permission to join this circle."
    case .invalidStateTransition(_, let attempted):
        return "Cannot \(attempted) the circle right now."
    case .network(let networkError):
        return networkError.errorDescription ?? "A network error occurred."
    case .unknown(let message):
        return message
    }
}
