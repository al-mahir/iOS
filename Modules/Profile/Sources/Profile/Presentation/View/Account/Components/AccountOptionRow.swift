//
//  AccountOptionRow.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common

struct AccountOptionRow: View {
    let title: String
    var icon: String? = nil
    var showChevron: Bool = false
    var action: () -> Void = {}

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                Text(title)
                    .dsFont(DSTypography.bodyLarge)
                    .foregroundColor(dsColors.textPrimary)

                Spacer()

                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(dsColors.textPrimary)
                } else if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(dsColors.textHint)
                }
            }
            .padding(.horizontal, DSSpacing.xs)
            .padding(.vertical, DSSpacing.md)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle(dsColors: dsColors))
    }
}

private struct RowPressStyle: ButtonStyle {
    let dsColors: DSColors

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? dsColors.surfaceVariant.opacity(0.3) : Color.clear)
    }
}

#Preview {
    VStack(spacing: 0) {
        AccountOptionRow(title: "Request a new feature", icon: "bubble.left")
        Divider()
        AccountOptionRow(title: "Privacy policy", showChevron: true)
    }
    .padding()
    .dsTheme()
}
