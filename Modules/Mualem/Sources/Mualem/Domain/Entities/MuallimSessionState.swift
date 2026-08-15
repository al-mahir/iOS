//
//  MuallimSessionState.swift
//  Mualem
//

import Foundation

public enum MuallimSessionState: Equatable {
    case setup
    case listening       // Sheikh is reciting
    case recording       // User is reciting, AI is evaluating in real-time
    case evaluating      // Waiting for final AI feedback after user stops
    case feedback(result: AyahFeedbackResult)
    case completed
}

