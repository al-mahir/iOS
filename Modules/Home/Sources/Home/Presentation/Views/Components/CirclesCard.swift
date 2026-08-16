//
//  SwiftUIView.swift
//  Home
//
//  Created by Nadin Ahmed on 15/08/2026.
//

import Common
import SwiftUI

struct CirclesCard: View {

    @Environment(\.dsColors) private var dsColors

    var title: LocalizedStringKey
    var description: LocalizedStringKey
    var icon: String
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .foregroundColor(dsColors.primary)
                }

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(title, bundle: .module)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                        .padding(.bottom, DSSpacing.xs)
                    Text(description, bundle: .module)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(dsColors.textHint)
            }
            .padding(DSSpacing.md)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
