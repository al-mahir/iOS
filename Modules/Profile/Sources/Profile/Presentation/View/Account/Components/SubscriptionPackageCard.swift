//
//  SubscriptionPackageCard.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//
import SwiftUI
import Common

struct SubscriptionPackageCard: View {
    let subscription: SheikhPackageSubscription
    var onCancel: (() -> Void)? = nil

    @Environment(\.dsColors) private var dsColors

    private var endDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: subscription.endDate)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Header Row
            HStack(spacing: DSSpacing.md) {
                sheikhAvatar

                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(subscription.sheikhName)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    Text(subscription.packageName)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }

                Spacer()

                statusBadge
            }

            Divider()
                .background(dsColors.outlineVariant.opacity(0.2))

            // Subscriptions Progress & Metrics
            if subscription.status == .active {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    ProgressView(value: subscription.progress)
                        .tint(dsColors.primary)

                    HStack {
                        Text("\(subscription.usedSessions) of \(subscription.totalSessions) sessions used", bundle: .module)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textPrimary)

                        Spacer()

                        Text("Ends \(endDateText)", bundle: .module)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
            } else {
                Text("Ended \(endDateText)", bundle: .module)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)
            }

            // Price & Destructive Action Footer
            HStack {
                Text("\(Int(subscription.price)) \(subscription.currencyCode)")
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.primary)

                Spacer()

                if subscription.status == .active, let onCancel = onCancel {
                    Button(action: onCancel) {
                        Text("Cancel subscription", bundle: .module)
                            .dsFont(DSTypography.labelSmall)
                            .foregroundColor(dsColors.error)
                            .padding(.horizontal, DSSpacing.sm)
                            .padding(.vertical, DSSpacing.xxs)
                            .background(Capsule().fill(dsColors.error.opacity(0.08)))
                    }
                }
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .fill(dsColors.surfaceContainerLowest)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
        )
        .opacity(subscription.status == .active ? 1.0 : 0.7)
    }

    private var sheikhAvatar: some View {
        ZStack {
            Circle()
                .fill(dsColors.primary.opacity(0.12))
                .frame(width: 44, height: 44)

            Text(String(subscription.sheikhName.prefix(1)))
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.primary)
        }
    }

    private var statusBadge: some View {
        Text(subscription.status.displayLabel)
            .dsFont(DSTypography.labelSmall)
            .foregroundColor(subscription.status == .active ? dsColors.primary : dsColors.textHint)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(
                Capsule().fill(
                    subscription.status == .active
                        ? dsColors.primary.opacity(0.12)
                        : dsColors.surfaceVariant.opacity(0.4)
                )
            )
    }
}
