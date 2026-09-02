//
//  QuranTextDarkModeModifier.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/07/2026.
//

import SwiftUI
struct QuranTextDarkModeModifier: ViewModifier {
    let isDarkMode: Bool
    let isTajweed: Bool

    func body(content: Content) -> some View {
        if isDarkMode && isTajweed {
            content
                .colorInvert()
                .hueRotation(.degrees(180))
        } else {
            content
        }
    }
}
