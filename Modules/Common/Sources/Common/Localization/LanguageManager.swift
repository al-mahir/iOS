//
//  LanguageManager.swift
//  Common
//
//  Created by Basmala Abuzied Ahmed on 15/08/2026.
//


import Foundation
import SwiftUI
import Combine

public enum AppLanguage: String, CaseIterable, Identifiable, Equatable {
    case system
    case english = "en"
    case arabic = "ar"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .system:
            return String(localized: "System", bundle: .module)
        case .english:
            return "English"
        case .arabic:
            return "العربية"
        }
    }

    fileprivate var appleLanguageCodes: [String]? {
        switch self {
        case .system: return nil
        case .english: return ["en"]
        case .arabic: return ["ar"]
        }
    }

    public var locale: Locale {
        switch self {
        case .system: return .autoupdatingCurrent
        case .english: return Locale(identifier: "en")
        case .arabic: return Locale(identifier: "ar")
        }
    }

    public var layoutDirection: LayoutDirection {
        switch self {
        case .system:
            return Locale.current.language.characterDirection == .rightToLeft ? .rightToLeft : .leftToRight
        case .english:
            return .leftToRight
        case .arabic:
            return .rightToLeft
        }
    }
}

@MainActor
public final class LanguageManager: ObservableObject {

    public static let shared = LanguageManager()

    private static let storageKey = "com.almahir.appLanguage"

    @Published public private(set) var currentLanguage: AppLanguage

    private init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppLanguage(rawValue: raw) {
            currentLanguage = saved
        } else {
            currentLanguage = .system
        }
    }

    public func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language

        UserDefaults.standard.set(language.rawValue, forKey: Self.storageKey)
        if let codes = language.appleLanguageCodes {
            UserDefaults.standard.set(codes, forKey: "AppleLanguages")
        } else {
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }
}
