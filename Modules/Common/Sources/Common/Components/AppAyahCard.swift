//
//  AppAyahCard.swift
//  Common
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI
public struct AppAyahCard: View {
    @Environment(\.dsColors) private var dsColors
    
    public let arabicText: String
    public let englishTranslation: String
    public let surahName: String
    public let surahNumber: Int
    public let ayahNumber: Int
    public let pageNumber: Int
    public let action: () -> Void
    
    public init(arabicText: String, englishTranslation: String, surahName: String, surahNumber: Int, ayahNumber: Int, pageNumber: Int, action: @escaping () -> Void) {
        self.arabicText = arabicText
        self.englishTranslation = englishTranslation
        self.surahName = surahName
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.pageNumber = pageNumber
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            VStack(alignment: .trailing, spacing: DSSpacing.md) {
                Text(arabicText)
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    HStack {
                        Text("Surah \(surahName) • \(surahNumber):\(ayahNumber)")
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(dsColors.primary)
                        Spacer()
                    }
                    
                    Text(englishTranslation)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Text("Page \(pageNumber)")
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(dsColors.primary)
                        Spacer()
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(dsColors.primary)
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(dsColors.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(dsColors.outlineVariant, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
