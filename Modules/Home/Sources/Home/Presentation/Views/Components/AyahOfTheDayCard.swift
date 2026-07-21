//
//  AyahOfTheDayCard.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import SwiftUI
import Common

struct AyahOfTheDayCard: View {
    @Environment(\.dsColors) private var dsColors
    let entity: AyahOfTheDayEntity

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            
            // Header Row: Title & Surah/Ayah Badge
            HStack {
                Text("AYAH OF THE DAY")
                    .dsFont(DSTypography.overline)
                    .foregroundColor(dsColors.warning)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 10, weight: .semibold))
                    Text("\(entity.surahName) • Ayah \(entity.ayahNumber)")
                        .dsFont(DSTypography.caption)
                }
                .foregroundColor(dsColors.primary)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, 6)
                .background(Capsule().fill(dsColors.primary.opacity(0.12)))
            }

            // Body: Arabic & Translation
            VStack(spacing: DSSpacing.sm) {
                Text(entity.arabicText)
                    .dsArabicFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                
                Text(entity.translation)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.vertical, DSSpacing.xs)
            
            Divider()
                .background(dsColors.outlineVariant)
            
            // Footer Row: Juz & Page Metadata
            HStack {
                metadataItem(icon: "bookmark.fill", text: "Juz \(entity.juzNumber)")
                Spacer()
                metadataItem(icon: "doc.text.fill", text: "Page \(entity.pageNumber)")
            }
        }
        .padding(DSSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant, lineWidth: 1)
        )
    }
    
    // Helper view for bottom metadata
    private func metadataItem(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .dsFont(DSTypography.labelSmall)
        }
        .foregroundColor(dsColors.textTertiary)
    }
}
