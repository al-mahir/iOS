//
//  SheikhListRow.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhListRow: View {

    public let sheikh: Sheikh
    @Environment(\.dsColors) private var dsColors

    public var onFavouriteTap: (() -> Void)?

    public init(sheikh: Sheikh, onFavouriteTap: (() -> Void)? = nil) {
        self.sheikh = sheikh
        self.onFavouriteTap = onFavouriteTap
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            SheikhAvatarView(sheikh: sheikh, size: 60)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(sheikh.fullName)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)

                SheikhRatingView(rate: sheikh.rate)

                SheikhStatusBadge(status: sheikh.sheikhStatus)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                onFavouriteTap?()
            } label: {
                Image(systemName: "heart")
                    .font(.system(size: 20, weight: .light))
                    .foregroundColor(dsColors.textSecondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
    }
}
