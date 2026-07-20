//
//  SwiftUIView.swift
//  Authentication
//
//  Created by Nadin Ahmed on 20/07/2026.
//

import Common
import SwiftUI

struct ErrorBanner: View {
    @Environment(\.dsColors) private var dsColors

    var message: String
    var onDismiss: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(dsColors.error)

            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.error)

            Spacer()

            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(dsColors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(dsColors.errorContainer)
        )
    }
}
