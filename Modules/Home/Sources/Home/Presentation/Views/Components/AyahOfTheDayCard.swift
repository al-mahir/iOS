import SwiftUI
import Common

struct AyahOfTheDayCard: View {
    @Environment(\.dsColors) private var dsColors
    let entity: AyahOfTheDayEntity

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            
            // Header Row: Title & Surah/Ayah Badge
            HStack {
                Text("AYAH OF THE DAY", bundle: .module)
                    .dsFont(DSTypography.overline)
                    .foregroundColor(dsColors.warning)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 10, weight: .semibold))
                    let localizedSurah = String(localized: String.LocalizationValue(entity.surahName), bundle: .module)

                    Text("\(localizedSurah) • Ayah \(entity.ayahNumber)", bundle: .module)
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.textSecondary)
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
                metadataItem(icon: "bookmark.fill", text: LocalizedStringKey("Juz \(entity.juzNumber)"))
                Spacer()
                metadataItem(icon: "doc.text.fill", text: LocalizedStringKey("Page \(entity.pageNumber)"))
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
    private func metadataItem(icon: String, text: LocalizedStringKey) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text, bundle: .module)
                .dsFont(DSTypography.labelSmall)
        }
        .foregroundColor(dsColors.textTertiary)
    }
}
