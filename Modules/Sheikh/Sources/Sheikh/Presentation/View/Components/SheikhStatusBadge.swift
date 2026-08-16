//
//  SheikhStatusBadge.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhStatusBadge: View {

    public let status: SheikhAvailabilityStatus
    @Environment(\.dsColors) private var dsColors

    public init(status: SheikhAvailabilityStatus) {
        self.status = status
    }

    private var label: String {
        switch status {
        case .available: return String(localized: "Available", bundle: .module)
        case .notAvailable: return String(localized: "In Session", bundle: .module)
        }
    }

    private var dotColor: Color {
        switch status {
        case .available: return dsColors.success
        case .notAvailable: return dsColors.error
        }
    }

    public var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Circle()
                .fill(dotColor)
                .frame(width: 7, height: 7)

            Text(label)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dotColor)
        }
    }
}


  
