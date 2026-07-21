//
//  ActiveCircleRow.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//



import SwiftUI
import Common

struct ActiveCircleRow: View {
    @Environment(\.dsColors) private var dsColors
    let circle: ActiveCircleEntity
    let onJoin: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(circle.title)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                Text(circle.host)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textTertiary)
            }

            Spacer()

            Button(action: onJoin) {
                Text("Join")
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.onPrimary)
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.xs)
                    .background(Capsule().fill(dsColors.primary))
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
