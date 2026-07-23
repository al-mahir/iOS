//
//  SheikhAvatarView.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhAvatarView: View {

    public let sheikh: Sheikh
    public let size: CGFloat

    @Environment(\.dsColors) private var dsColors

    private var avatarColor: Color {
        let palette: [Color] = [
            Color(hex: "#7A5545"),   // warm brown
            Color(hex: "#3A5DA0"),   // navy blue
            Color(hex: "#4A7066"),   // teal
            Color(hex: "#7B4A96"),   // purple
            Color(hex: "#A05A2C"),   // amber
            Color(hex: "#2C7A5A"),   // forest green
        ]
        let index = abs(sheikh.fullName.unicodeScalars.first?.value.hashValue ?? 0) % palette.count
        return palette[index]
    }

    private var initials: String {
        let parts = sheikh.fullName.split(separator: " ")
        let first = parts.first?.prefix(1) ?? ""
        let second = parts.dropFirst().first?.prefix(1) ?? ""
        return "\(first)\(second)"
    }


    public init(sheikh: Sheikh, size: CGFloat = 56) {
        self.sheikh = sheikh
        self.size = size
    }


    public var body: some View {
        Group {
            if let urlString = sheikh.profilePictureUrl,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
    }


    private var initialsView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(avatarColor)

            Text(initials)
                .dsFont(size > 80 ? DSTypography.titleLarge : DSTypography.titleSmall)
                .foregroundColor(.white)
        }
    }
}
