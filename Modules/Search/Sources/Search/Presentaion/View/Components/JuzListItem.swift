//
//  JuzListItem.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
struct JuzListItem: View {
    let juz: Juz
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Juz' \(juz.number)")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("Surah \(juz.surahRange) • Page \(juz.pageStart)-\(juz.pageEnd)")
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
