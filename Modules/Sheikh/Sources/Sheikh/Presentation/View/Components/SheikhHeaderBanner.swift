//
//  SheikhHeaderBanner.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhHeaderBanner: View {

    public let title: String
    public let onLeadingTap: (() -> Void)?
    public let onTrailingTap: (() -> Void)?

    public init(
        title: String,
        onLeadingTap: (() -> Void)? = nil,
        onTrailingTap: (() -> Void)? = nil
    ) {
        self.title = title
        self.onLeadingTap = onLeadingTap
        self.onTrailingTap = onTrailingTap
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                sideButton(
                    systemName: "chevron.left",
                    action: onLeadingTap
                )
                .padding(.leading, DSSpacing.md)

                Text(title)
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)

                sideButton(
                    systemName: "arrow.right",
                    action: onTrailingTap
                )
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

    // MARK: - Helpers

    @ViewBuilder
    private func sideButton(systemName: String, action: (() -> Void)?) -> some View {
        if let action {
            Button(action: action) {
                Image(systemName: systemName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.white.opacity(0.20))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        } else {
            Color.clear
                .frame(width: 40, height: 40)
        }
    }
}

// MARK: - BottomRoundedRectangle

private struct BottomRoundedRectangle: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Top-left corner (sharp)
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // Top-right corner (sharp)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // Bottom-right corner (rounded)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        // Bottom-left corner (rounded)
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}
