import Foundation
import SwiftUI

public enum MushafMode: String, CaseIterable, Identifiable {
    case reading, listening, correction, muallem, tajweedRule

    public var id: String { rawValue }

    public var systemImage: String {
        switch self {
        case .tajweedRule: return "paintpalette"
        case .listening:   return "headphones"
        case .reading:     return "book.closed"
        case .correction:  return "mic"
        case .muallem:     return "arrow.triangle.2.circlepath"
        }
    }

    public var titleKey: LocalizedStringKey {
        switch self {
        case .tajweedRule: return "Tajweed Rules"
        case .listening:   return "Listening"
        case .reading:     return "Reading"
        case .correction:  return "Recitation"
        case .muallem:     return "Teacher"
        }
    }

    public var subtitleKey: LocalizedStringKey {
        switch self {
        case .tajweedRule: return "View color-coded tajweed definitions"
        case .listening:   return "Word-by-word sync playback"
        case .reading:     return "Silent, self-paced reading"
        case .correction:  return "Real-time mistake detection"
        case .muallem:     return "Sheikh recites, then you repeat"
        }
    }

    // ✅ Changed from LocalizedStringKey to LocalizedStringResource
    public var tooltipDescriptionKey: LocalizedStringResource {
        switch self {
        case .tajweedRule: return "View color-coded tajweed definitions."
        case .reading:     return "Use Reading mode to display the traditional Mushaf layout."
        case .listening:   return "Use Listening mode to listen to recitations."
        case .correction:  return "Use Recitation mode to get live AI corrections on your recitation."
        case .muallem:     return "Use Teacher mode to repeat after the Sheikh."
        }
    }

    public var tooltipStep: Int? {
        switch self {
        case .reading:    return 3
        case .listening:  return 4
        case .correction: return 5
        case .muallem:    return 6
        default:          return nil
        }
    }
}
