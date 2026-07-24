//
//  TermsOfServiceView.swift
//  Profile
//
//  Created by Esraa Ehab on 24/07/2026.
//

import SwiftUI
import Common

public struct TermsOfServiceView: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            headerBanner(title: "Terms of Service")

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Terms of Service")
                            .dsFont(DSTypography.headlineMedium)
                            .foregroundColor(dsColors.textPrimary)

                        Text("By using the Al-Mahir application, you agree to the terms outlined below.")
                            .dsFont(DSTypography.bodyLarge)
                            .foregroundColor(dsColors.textSecondary)
                    }

                    sectionBlock(
                        title: "Account Usage",
                        bullets: [
                            "You are responsible for maintaining the confidentiality of your account login credentials.",
                            "Using the application for any unlawful purpose or in violation of applicable regulations is strictly prohibited."
                        ]
                    )

                    sectionBlock(
                        title: "Subscriptions",
                        bullets: [
                            "Subscriptions renew automatically unless cancelled prior to the renewal date.",
                            "Payment management is handled through the App Store and subject to its policies."
                        ]
                    )

                    sectionBlock(
                        title: "Termination of Service",
                        bullets: [
                            "We reserve the right to suspend accounts upon violation of these terms, with notice provided."
                        ]
                    )
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl2)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .environment(\.layoutDirection, .leftToRight)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .dsTheme()
    }

    private func headerBanner(title: String) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.20))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.leading, DSSpacing.md)

                Text(title)
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)

                Color.clear
                    .frame(width: 40, height: 40)
                    .padding(.trailing, DSSpacing.md)
            }
            .padding(.top, DSSpacing.sm)
            .padding(.bottom, DSSpacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(
            ZStack {
                DSGradients.primary

                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .offset(x: geo.size.width - 60, y: -50)
                }
                .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .top)
        )
        .clipShape(BottomRoundedRectangle(radius: DSRadius.xl))
    }

    private func sectionBlock(title: String, bullets: [String]) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .dsFont(DSTypography.titleLarge)
                .foregroundColor(dsColors.textPrimary)

            ForEach(bullets, id: \.self) { bullet in
                HStack(alignment: .top, spacing: DSSpacing.xs) {
                    Circle()
                        .fill(dsColors.primary)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)

                    Text(bullet)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textSecondary)
                }
            }
        }
    }
}

private struct BottomRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
