//
//  QraaStatus.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 24/07/2026.
//
import Common

enum QraaStatus: Equatable {
    case idle
    case correct
    case incorrect(expectedWord: QuranWord)

    static func == (lhs: QraaStatus, rhs: QraaStatus) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.correct, .correct):
            return true
        case (.incorrect(let word1), .incorrect(let word2)):
            return word1.id == word2.id
        default:
            return false
        }
    }
}

enum RecitationEndMode: Equatable {
    case endOfPage
    case endOfSurah
}

struct RecitationRange: Equatable {
    let startWordId: Int
    let endMode: RecitationEndMode
}
