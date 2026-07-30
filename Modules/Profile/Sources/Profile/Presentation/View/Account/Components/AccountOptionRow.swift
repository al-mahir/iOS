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
    var badge: String? = nil
    var action: () -> Void = {}

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(dsColors.primary)
                        .frame(width: 28, height: 28, alignment: .center)
                }

                Text(title)
                    .dsFont(DSTypography.bodyLarge)
                    .foregroundColor(dsColors.textPrimary)

                Spacer()

                if let badge = badge {
                    Text(badge)
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.primary)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xxs)
                        .background(Capsule().fill(dsColors.primary.opacity(0.12)))
                }

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(dsColors.textHint)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle(dsColors: dsColors))
    }
}

private struct RowPressStyle: ButtonStyle {
    let dsColors: DSColors

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? dsColors.surfaceVariant.opacity(0.4) : Color.clear)
    }
}

