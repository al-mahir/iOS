//
//  SocialMediaLinksView.swift
//  Profile
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI
import Common

struct SocialMediaLinksView: View {
    private struct Platform: Identifiable {
        let id = UUID()
        let symbol: String
        let label: String
    }

    private let platforms: [Platform] = [
        Platform(symbol: "chevron.left.forwardslash.chevron.right", label: "GitHub"),
        Platform(symbol: "bubble.left.and.bubble.right", label: "Discord"),
        Platform(symbol: "xmark", label: "X"),
        Platform(symbol: "f.circle", label: "Facebook"),
        Platform(symbol: "play", label: "YouTube"),
        Platform(symbol: "camera", label: "Instagram")
    ]

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            ForEach(platforms) { platform in
                Button(action: {
                    // Action for platform link
                }) {
                    Image(systemName: platform.symbol)
                        .font(.system(size: 20, weight: .regular))
                        .foregroundColor(dsColors.textPrimary)
                        .frame(width: 40, height: 40)
                        .contentShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(platform.label)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.sm)
    }
}

#Preview {
    SocialMediaLinksView()
        .padding()
        .dsTheme()
}
