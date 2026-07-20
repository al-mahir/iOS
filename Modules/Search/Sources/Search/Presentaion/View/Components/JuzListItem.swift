//
//  JuzListItem.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//


import SwiftUI
import Common

struct JuzListItem: View {
    @Environment(\.dsColors) private var dsColors
    let juz: Juz
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text("Juz' \(juz.number)")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                
                Text("Surah \(juz.surahRange) • Page \(juz.pageStart)-\(juz.pageEnd)")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(dsColors.textSecondary)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
        )
    }
}
