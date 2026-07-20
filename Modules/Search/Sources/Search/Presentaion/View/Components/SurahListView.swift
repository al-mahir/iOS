//
//  SurahListView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI

struct SurahListView: View {
    let surahs: [Surah]
    let onSurahSelected: ((Surah) -> Void)?
    
    public init(surahs: [Surah], onSurahSelected: ((Surah) -> Void)? = nil) {
        self.surahs = surahs
        self.onSurahSelected = onSurahSelected
    }
    
     var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All 114 Surahs")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            ForEach(surahs) { surah in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(surah.arabicName)
                            .font(.custom("Amiri", size: 18))
                            .foregroundColor(AppColors.primaryAccent)
                        Text("\(surah.englishName) • \(surah.ayahCount) Ayahs • Page \(surah.pageStart)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSurahSelected?(surah)
                }
            }
        }
    }
}
