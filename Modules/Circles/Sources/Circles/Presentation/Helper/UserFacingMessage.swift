//
//  UserFacingMessage.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

import NetworkKit

// MARK: - Private Helpers

@MainActor
internal func userFacingMessage(for error: CircleError) -> String {
    switch error {
    case .timeOverlap:
        return localizedCircleString(
            "You already have a circle scheduled at this time. Choose a different time."
        )
    case .circleFull:
        return localizedCircleString("This circle is full.")
    case .notOwner:
        return localizedCircleString("You don't have permission to do that.")
    case .unauthorized:
        return localizedCircleString("Please sign in and try again.")
    case .notFound:
        return localizedCircleString("Circle not found.")
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

@MainActor
internal func networkUserFacingMessage(for error: NetworkError) -> String {
    switch error {
    case .invalidURL:
        return localizedCircleString("Unable to connect to the service.")
    case .noInternetConnection:
        return localizedCircleString("Please check your internet connection.")
    case .decodingFailed:
        return localizedCircleString("An error occurred while processing the data.")
    case .timeout:
        return localizedCircleString("The request timed out. Please try again.")
    case .cancelled:
        return localizedCircleString("The request was cancelled.")
    case .unauthorized(let message),
         .notFound(let message),
         .validationFailed(let message, _),
         .serverError(_, let message),
         .unknown(let message):
        return message.isEmpty
            ? localizedCircleString("A network error occurred.")
            : message
    }
}
