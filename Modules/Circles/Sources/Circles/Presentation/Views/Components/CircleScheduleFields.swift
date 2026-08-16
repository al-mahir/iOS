//
//  CircleScheduleFields.swift
//  Circles
//
//  Created by Nadin Ahmed on 15/08/2026.
//

import Common
import SwiftUI

struct CircleScheduleFields: View {
    @Environment(\.dsColors) private var dsColors

    @Binding private var name: String
    @Binding private var startDate: Date
    @Binding private var endDate: Date

    init(name: Binding<String>, startDate: Binding<Date>, endDate: Binding<Date>) {
        _name = name
        _startDate = startDate
        _endDate = endDate
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            nameField
            startDateField
            endDateField
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Circle Name", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            TextField(
                localizedCircleString("e.g., Daily Fajr Recitation"),
                text: $name
            )
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.md)
                .background(dsColors.surfaceContainerLow)
                .cornerRadius(DSRadius.lg)
        }
    }

    private var startDateField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("Start Date & Time", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            DatePicker(
                "",
                selection: $startDate,
                in: Date().addingTimeInterval(-3600)...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(dsColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
        .frame(maxWidth: .infinity)
    }

    private var endDateField: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Text("End Date & Time", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)

            DatePicker(
                "",
                selection: $endDate,
                in: startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)
            .tint(dsColors.primary)
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(dsColors.surfaceContainerLow)
            .cornerRadius(DSRadius.lg)
        }
        .frame(maxWidth: .infinity)
    }
}
