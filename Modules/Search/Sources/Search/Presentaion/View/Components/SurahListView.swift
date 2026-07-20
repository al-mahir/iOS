//
//  SurahListView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common

struct SurahListView: View {
    @Environment(\.dsColors) private var dsColors
    
    let surahs: [Surah]
    let onSurahSelected: ((Surah) -> Void)?
    
    public init(surahs: [Surah], onSurahSelected: ((Surah) -> Void)? = nil) {
        self.surahs = surahs
        self.onSurahSelected = onSurahSelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("All 114 Surahs")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
                .padding(.horizontal, DSSpacing.xs)
            
            ForEach(surahs, id: \.id) { surah in
                AppSurahCard(
                    arabicName: surah.arabicName,
                    englishName: surah.englishName,
                    ayahCount: surah.ayahCount,
                    page: surah.pageStart
                ) {
                    onSurahSelected?(surah)
                }
            }
        }
    }
}
