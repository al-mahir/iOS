//
//  SubscriptionPlansView.swift
//  Settings
//

import SwiftUI
import Common
import Payment
import Sheikh

public struct SubscriptionPlansView: View {

    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackage: SubscriptionPackage? = nil

    private let packages: [SheikhPackage] = SheikhPackage.staticPackages

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // MARK: Header
            ZStack {
                Text("Subscription Plans")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .frame(maxWidth: .infinity)

                HStack {
                    Button(action: { dismiss() }) {
                        Circle()
                            .fill(dsColors.surfaceContainerLow)
                            .frame(width: 38, height: 38)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(dsColors.textPrimary)
                            )
                            .overlay(
                                Circle().stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
                            )
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, DSSpacing.mdLg)
            .padding(.vertical, DSSpacing.md)
            .background(dsColors.surfaceContainerLowest)
            .overlay(
                Rectangle()
                    .fill(dsColors.outlineVariant.opacity(0.3))
                    .frame(height: 1),
                alignment: .bottom
            )

            // MARK: Body
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.md) {

                    // Subtitle
                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Choose a Plan")
                            .dsFont(DSTypography.titleLarge)
                            .foregroundColor(dsColors.textPrimary)
                        Text("Subscribe to a plan and start learning with a certified Sheikh.")
                            .dsFont(DSTypography.bodyMedium)
                            .foregroundColor(dsColors.textSecondary)
                    }
                    .padding(.top, DSSpacing.md)

                    // Package Cards
                    ForEach(packages) { package in
                        SheikhPackageTierCard(
                            package: package,
                            onSelect: {
                                selectedPackage = SubscriptionPackage(
                                    id: package.id,
                                    title: package.nameEn,
                                    subtitle: package.daysPerWeek,
                                    priceEGP: Decimal(package.pricePerMonth),
                                    durationMonths: 1,
                                    reciterName: "Al-Mahir",
                                    features: package.features
                                )
                            }
                        )
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl2)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(item: $selectedPackage) { pkg -> PaymentView in
            PaymentDIContainer.shared.makePaymentView(for: pkg)
        }
    }
}
