//
//  SwiftUIView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import SwiftUI
import Common

struct OrDivider: View {
    @Environment(\.dsColors) private var dsColors
    
    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Rectangle()
                .fill(dsColors.outlineVariant)
                .frame(height: 1)
            Text("OR")
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textTertiary)
            Rectangle()
                .fill(dsColors.outlineVariant)
                .frame(height: 1)
        }
        .padding(.horizontal, DSSpacing.md)
    }
}
