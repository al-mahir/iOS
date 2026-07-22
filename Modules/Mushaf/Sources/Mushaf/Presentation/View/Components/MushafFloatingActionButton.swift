//
//  MushafFloatingActionButton.swift
//  Mushaf
//
//  Created by Alaa Ayman on 20/07/2026.
//


import SwiftUI
import Common
struct MushafFloatingActionButton: View {
    @Environment(\.dsColors) private var dsColors
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "waveform")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(dsColors.onPrimary)
                .frame(width: 56, height: 56)
                .background(Circle().fill(dsColors.primary))
                .dsElevation(DSElevation.level4)
        }
        .accessibilityLabel("Choose recitation mode")
    }
}
