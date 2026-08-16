//
//  CircleError.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation
import NetworkKit

public enum CircleError: Error, LocalizedError, Sendable, Equatable {

    case timeOverlap

    case invalidStateTransition(current: CircleStatus, attempted: String)

    case circleFull

    case notOwner

    case unauthorized

    case notFound

    case network(NetworkError)

    case unknown(String)

    // MARK: - LocalizedError

    public var errorDescription: String? {
        switch self {
        case .timeOverlap:
            return
                "You already have an active circle at that time. Please choose a different time."
        case .invalidStateTransition(let current, let attempted):
            return
                "Cannot \(attempted) a circle that is \(current.rawValue.lowercased())."
        case .circleFull:
            return "This circle has reached its maximum number of participants."
        case .notOwner:
            return "You do not have permission to perform this action."
        case .unauthorized:
            return "You are not logged in. Please sign in and try again."
        case .notFound:
            return "The circle could not be found."
        case .network(let error):
            return error.errorDescription
        case .unknown(let message):
            return message
        }
    }
}
