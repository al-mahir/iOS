//
//  TaahudWordErrorDetailSheet.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 05/08/2026.
//

import SwiftUI
import Common
import Taahud

struct TaahudWordErrorDetailSheet: View {
    let word: QuranWord
    let errors: [TajweedError]

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            Text(word.text)
                .dsArabicFont(DSTypography.titleLarge)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, DSSpacing.sm)

            Divider()

            ForEach(errors) { error in
                HStack(alignment: .top, spacing: DSSpacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(error.rule.replacingOccurrences(of: "_", with: " ").capitalized)
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(dsColors.textPrimary)
                        Text(error.message)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(DSSpacing.md)
    }
}
