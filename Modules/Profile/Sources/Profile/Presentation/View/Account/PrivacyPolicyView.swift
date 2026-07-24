//
//  PrivacyPolicyView.swift
//  Profile
//
//  Created by Esraa Ehab on 24/07/2026.
//

import SwiftUI
import Common

public struct PrivacyPolicyView: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            headerBanner(title: "About Al-Mahir")

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("Al-Mahir")
                            .dsFont(DSTypography.headlineMedium)
                            .foregroundColor(dsColors.textPrimary)

                        Text("Al-Mahir is your companion for Quran recitation and memorisation, combining digital Mushaf, AI recitation correction, and live interactive learning sessions with certified scholars.")
                            .dsFont(DSTypography.bodyLarge)
                            .foregroundColor(dsColors.textSecondary)
                    }

                    sectionBlock(
                        title: "What Makes Us Unique",
                        bullets: [
                            "Official Madinah font Quran text with color-coded Tajweed rules.",
                            "Real-time AI recitation correction while reading.",
                            "Live interactive sessions with certified Quran scholars.",
                            "Comprehensive tracking of your memorisation and revision progress."
                        ]
                    )

                    sectionBlock(
                        title: "Contact Us",
                        bullets: [
                            "We are happy to hear your feedback and suggestions via the Help Center inside the app."
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
        PrivacyPolicyView()
    }
}
