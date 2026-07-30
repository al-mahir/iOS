//
//  MuallimSessionState.swift
//  Mualem
//

import Foundation

public enum MuallimSessionState: Equatable {
    case setup
    case listening
    case recording
    case feedback(mistakes: [RecitationMistake])
    case completed
}
