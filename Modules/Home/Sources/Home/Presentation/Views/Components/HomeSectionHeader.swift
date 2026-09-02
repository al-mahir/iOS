//
//  HomeSectionHeader.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import SwiftUI
import Common

struct HomeSectionHeader: View {
    @Environment(\.dsColors) private var dsColors
    let title: LocalizedStringKey
    var actionTitle: LocalizedStringKey = "See All"
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title, bundle: .module)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
            Spacer()
            Button(action: action) {
                Text(actionTitle, bundle: .module)
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.primary)
            }
        }
    }
}
