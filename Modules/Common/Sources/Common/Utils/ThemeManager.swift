//
//  ThemeManager.swift
//  Common
//
//  Created by Alaa Ayman on 24/07/2026.
//

import SwiftUI
import Combine

public enum AppTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system: return "System Default"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

public final class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()

    private let key = "com.almahir.appTheme"
    private let defaults: UserDefaults

    @Published public var currentTheme: AppTheme {
        didSet {
            defaults.set(currentTheme.rawValue, forKey: key)
        }
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let savedRaw = defaults.string(forKey: key) ?? AppTheme.system.rawValue
        self.currentTheme = AppTheme(rawValue: savedRaw) ?? .system
    }
}
