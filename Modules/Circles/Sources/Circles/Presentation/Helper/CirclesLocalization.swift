//
//  CircleAgoraTokenRefreshProvider.swift
//  Circles
//
//  Created by Nadin Ahmed on 17/08/2026.

import Common
import Foundation

@MainActor
internal func localizedCircleString(_ key: String) -> String {
    LanguageManager.localizedString(key, bundle: .module)
}

@MainActor
internal func localizedCircleString(_ key: String, _ arguments: CVarArg...) -> String {
    String(
        format: LanguageManager.localizedString(key, bundle: .module),
        locale: LanguageManager.shared.currentLanguage.locale,
        arguments: arguments
    )
}
