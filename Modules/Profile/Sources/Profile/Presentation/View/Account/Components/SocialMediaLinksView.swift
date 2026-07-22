//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct SocialMediaLinksView: View {
    private struct Platform: Identifiable {
        let id = UUID()
        let symbol: String
        let label: String
    }
 
    private let platforms: [Platform] = [
        Platform(symbol: "chevron.left.slash.chevron.right", label: "GitHub"),
        Platform(symbol: "message.fill", label: "Discord"),
        Platform(symbol: "xmark", label: "X"),
        Platform(symbol: "music.note", label: "TikTok"),
        Platform(symbol: "play.fill", label: "YouTube"),
        Platform(symbol: "camera.fill", label: "Instagram")
    ]
 
    var body: some View {
        HStack(spacing: 12) {
            ForEach(platforms) { platform in
                Button(action: {
                }) {
                    Circle()
                        .fill(Color(.secondarySystemGroupedBackground))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Image(systemName: platform.symbol)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(hex: "0E5A47"))
                        )
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.08), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(platform.label)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
 
#Preview {
    SocialMediaLinksView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
