//
//  AppSurahCard.swift
//  Common
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI

public struct AppSurahCard: View {
    @Environment(\.dsColors) private var dsColors
    
    public let surahNumber: Int?
    public let arabicName: String
    public let englishName: String
    public let revelationType: String?
    public let ayahCount: Int
    public let page: Int
    public let action: () -> Void
    
    public init(
        surahNumber: Int? = nil,
        arabicName: String,
        englishName: String,
        revelationType: String? = nil,
        ayahCount: Int,
        page: Int,
        action: @escaping () -> Void
    ) {
        self.surahNumber = surahNumber
        self.arabicName = arabicName
        self.englishName = englishName
        self.revelationType = revelationType
        self.ayahCount = ayahCount
        self.page = page
        self.action = action
    }

    private var subtitleText: String {
        var parts: [String] = []
        if let type = revelationType, !type.trimmingCharacters(in: .whitespaces).isEmpty {
            parts.append(type)
        }
        parts.append("\(ayahCount) Ayahs")
        parts.append("Page \(page)")
        return parts.joined(separator: " • ")
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: DSSpacing.md) {
                // Surah Number Badge
                if let number = surahNumber {
                    Text("\(number)")
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(dsColors.surfaceContainerHigh)
                        )
                }

                // Names & Single-line Subtitle Metadata
                VStack(alignment: .leading, spacing: 2) {
                    Text(englishName)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)
                    
                    Text(subtitleText)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                        .lineLimit(1)
                }
                
                Spacer()

                // Arabic Surah Name in Quran Font
                Text(arabicName)
                    .dsArabicFont(DSTypography.titleLarge)
                    .foregroundColor(dsColors.primary)
                    .lineLimit(1)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(dsColors.textHint)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(dsColors.surfaceContainerLow)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(dsColors.outlineVariant, lineWidth: 0.5)
            )
        }
        .buttonStyle(.plain)
    }
}

