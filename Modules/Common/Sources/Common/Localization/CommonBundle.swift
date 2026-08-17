//
//  CommonBundle.swift
//  Common
//
//  Created by Basmala Abuzied Ahmed on 15/08/2026.
//

import Foundation

public enum CommonBundle {
    public static let bundle = Bundle.module

    public static func localizedString(_ key: String) -> String {
        LanguageManager.localizedString(key, bundle: bundle)
    }
}
