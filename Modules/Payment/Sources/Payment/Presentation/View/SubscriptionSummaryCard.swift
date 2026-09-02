//
//  SubscriptionSummaryCard.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import SwiftUI
import Common

// MARK: - SubscriptionSummaryCard

/// A premium card showing the package the user is about to pay for.
struct SubscriptionSummaryCard: View {

    let package: SubscriptionPackage

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {

            // MARK: Header row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text(LocalizedStringKey("reciter.pass.label"), bundle: .paymentBundle)
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(Color.white.opacity(0.8))
                        .textCase(.uppercase)

                    Text(package.reciterName)
                        .dsFont(DSTypography.titleLarge)
                        .foregroundColor(.white)
                }

                Spacer()

                // Price badge
                VStack(spacing: DSSpacing.xxs) {
                    Text(package.formattedPrice)
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(.white)

                    Text(package.formattedDuration)
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(Color.white.opacity(0.8))
                }
                .padding(.horizontal, DSSpacing.smMd)
                .padding(.vertical, DSSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(Color.white.opacity(0.18))
                )
            }

            // Divider
            Rectangle()
                .fill(Color.white.opacity(0.25))
                .frame(height: 1)

            // MARK: Package title & subtitle
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text(package.title)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(.white)
                Text(package.subtitle)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(Color.white.opacity(0.85))
            }

            // MARK: Feature list
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                ForEach(package.features, id: \.self) { feature in
                    FeatureRow(text: feature)
                }
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.xl)
                .fill(DSGradients.primary)
        )
        .shadow(color: Color.black.opacity(0.25), radius: 16, x: 0, y: 6)
    }
}

// MARK: - FeatureRow

private struct FeatureRow: View {
    let text: String

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.white.opacity(0.9))

            Text(text)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(Color.white.opacity(0.95))
        }
    }
}
