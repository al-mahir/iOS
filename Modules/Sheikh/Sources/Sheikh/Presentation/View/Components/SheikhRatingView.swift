//
//  SheikhRatingView.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhRatingView: View {

    public let rate: Double

    public init(rate: Double) {
        self.rate = rate
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xxs) {
            Image(systemName: "star.fill")
                .foregroundColor(Color(hex: "#F5A623"))
                .font(.system(size: 12, weight: .medium))

            Text(String(format: "%.1f", rate))
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(Color(hex: "#F5A623"))
        }
    }
}
