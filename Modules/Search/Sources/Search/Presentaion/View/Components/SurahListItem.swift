//
//  SurahListItem.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
struct SurahListItem: View {
    let surah: Surah
    
    var body: some View {
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
    }
}
