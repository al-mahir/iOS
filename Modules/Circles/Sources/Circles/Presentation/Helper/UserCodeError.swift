//
//  UserCodeError.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

internal func handleCodeError(_ error: CircleError) -> String {
    switch error {
    case .notFound:
        return "Invalid code. Please check and try again."
    case .circleFull:
        return "This circle is full."
    case .timeOverlap:
        return "You already have a circle at this time."
    case .unauthorized:
        return "Please sign in and try again."
    default:
        return "Something went wrong. Please try again."
    }
}
