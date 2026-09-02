//
//  UserCodeError.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

@MainActor
internal func handleCodeError(_ error: CircleError) -> String {
    switch error {
    case .notFound:
        return localizedCircleString("Invalid code. Please check and try again.")
    case .circleFull:
        return localizedCircleString("This circle is full.")
    case .timeOverlap:
        return localizedCircleString("You already have a circle at this time.")
    case .unauthorized:
        return localizedCircleString("Please sign in and try again.")
    default:
        return localizedCircleString("Something went wrong. Please try again.")
    }
}
