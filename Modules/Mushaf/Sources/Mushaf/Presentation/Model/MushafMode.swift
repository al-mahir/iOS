//
//  MushafMode.swift
//  Mushaf
//
//  Created by Alaa Ayman on 20/07/2026.
//


import Foundation

public enum MushafMode: String, CaseIterable, Identifiable {
    case listening, reading, correction, muallem

    public var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .listening:  return "headphones"
        case .reading:     return "book.closed"
        case .correction:  return "mic"
        case .muallem:     return "arrow.triangle.2.circlepath"
        }
    }

    var englishTitle: String {
        switch self {
        case .listening:  return "Listening"
        case .reading:     return "Reading"
        case .correction:  return "Correction"
        case .muallem:     return "Mu'allem"
        }
    }

   

    var subtitle: String {
        switch self {
        case .listening:  return "Word-by-word sync playback"
        case .reading:     return "Silent, self-paced reading"
        case .correction:  return "Real-time mistake detection"
        case .muallem:     return "Sheikh recites, then you repeat"
        }
    }
}
