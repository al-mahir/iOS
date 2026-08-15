//
//  SettingsSectionHeader.swift
//  Settings
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI
import Common

struct SettingsSectionHeader: View {
    let title: LocalizedStringKey
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        HStack {
            Text(title, bundle: CommonBundle.bundle)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textSecondary)
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xs)
        .padding(.top, DSSpacing.lg)
        .padding(.bottom, DSSpacing.sm)
    }
}
