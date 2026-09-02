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
    /// PostScript name of the page-specific Quran font.
    /// When provided the Arabic text is rendered with the correct Mushaf glyph set.
    /// Falls back to a plain system font when nil (e.g. fonts not yet loaded).
    public let fontName: String?
    public let action: () -> Void

    public init(
        arabicText: String,
        englishTranslation: String,
        surahName: String,
        surahNumber: Int,
        ayahNumber: Int,
        pageNumber: Int,
        fontName: String? = nil,
        action: @escaping () -> Void
    ) {
        self.arabicText = arabicText
        self.englishTranslation = englishTranslation
        self.surahName = surahName
        self.surahNumber = surahNumber
        self.ayahNumber = ayahNumber
        self.pageNumber = pageNumber
        self.fontName = fontName
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            VStack(alignment: .trailing, spacing: DSSpacing.md) {
                // Arabic text — uses the Quran font when available so glyphs
                // are rendered exactly as they appear in the Mushaf.
                Text(arabicText)
                    .font(quranFont)
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

    /// Resolve the font: use the page-specific Quran font when available,
    /// otherwise fall back to a legible system Arabic size.
    private var quranFont: Font {
        if let name = fontName {
            return .custom(name, size: 24)
        }
        return .system(size: 22)
    }
}

