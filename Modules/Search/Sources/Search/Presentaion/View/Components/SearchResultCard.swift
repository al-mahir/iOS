//
//  SearchResultCard.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
struct SearchResultCard: View {
    let result: SearchResult
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .trailing, spacing: 12) {
                Text(result.ayah.arabicText)
                    .font(.custom("Amiri", size: 20))
                    .multilineTextAlignment(.trailing)
                    .lineSpacing(6)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                HStack {
                    Text("Surah \(result.surah.englishName) • \(result.surah.id):\(result.ayah.number)")
                        .font(.caption)
                        .bold()
                        .foregroundColor(AppColors.primaryAccent)
                    Spacer()
                }
                
                Text(result.ayah.englishTranslation)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Text("Page \(result.pageNumber)")
                        .font(.caption2)
                        .foregroundColor(AppColors.primaryAccent)
                    Spacer()
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(AppColors.primaryAccent)
                        .font(.caption)
                }
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(AppColors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
