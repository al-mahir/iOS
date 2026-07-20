//
//  SwiftUIView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Common
import SwiftUI

struct FooterWithButton: View {
    var message: String
    var buttonText: String
    var onButtonClicked: () -> Void

    @Environment(\.dsColors) private var dsColors
    
    var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)

            Button {
                onButtonClicked()
            } label: {
                Text(buttonText)
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.primary)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
