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
        Platform(symbol: "chevron.left.forwardslash.chevron.right", label: String(localized: "GitHub", bundle: .module)),
        Platform(symbol: "bubble.left.and.bubble.right", label: String(localized: "Discord", bundle: .module)),
        Platform(symbol: "xmark", label: String(localized: "X", bundle: .module)),
        Platform(symbol: "f.circle", label: String(localized: "Facebook", bundle: .module)),
        Platform(symbol: "play", label: String(localized: "YouTube", bundle: .module)),
        Platform(symbol: "camera", label: String(localized: "Instagram", bundle: .module))
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
