//
//  QuranPracticePageView.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 25/07/2026.
//

import SwiftUI
import Common

struct QuranPracticePageView: View {
    let page: MushafPage
    var fontName: String?
    var bottomInset: CGFloat = 0
    
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                ForEach(page.lines) { line in
                    practiceLineView(line)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
            .padding(.bottom, bottomInset)
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    @ViewBuilder
    private func practiceLineView(_ line: MushafLine) -> some View {
        switch line.lineType {
        case .ayah:
            ZStack(alignment: .bottom) {
                // Notebook line
                Divider()
                    .background(dsColors.outlineVariant.opacity(0.4))
                    .offset(y: 6)

                HStack(spacing: 4) {
                    ForEach(line.words) { word in
                        if isVerseSymbolWord(word) {
                            // Render EXACTLY ONE badge at this symbol's exact slot
                            ayahBadgeView(numberString: "\(word.ayah)")
                        } else {
                            // Invisible text placeholder to hold original word width and position
                            Text(word.text)
                                .font(pageFont(size: 22))
                                .opacity(0)
                                .lineLimit(1)
                                .fixedSize()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

        case .surahName:
            let surahNum = line.surahNumber ?? 0
            Text(SurahNames.name(for: surahNum))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(dsColors.textPrimary)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(
                    Capsule()
                        .stroke(dsColors.outlineVariant, lineWidth: 1)
                )

        case .basmallah:
            Text("\u{FDFD}")
                .font(pageFont(size: 22))
                .foregroundColor(dsColors.textSecondary)
                .padding(.vertical, 4)
        }
    }

    /// Checks if a word object is the end-of-verse symbol itself
    private func isVerseSymbolWord(_ word: QuranWord) -> Bool {
        if word.wordPosition == 0 { return true }

        let trimmed = word.text.trimmingCharacters(in: .whitespacesAndNewlines)
        return isNumericString(trimmed)
    }

    private func isNumericString(_ text: String) -> Bool {
        guard !text.isEmpty else { return false }
        let numberCharacters = CharacterSet(charactersIn: "0123456789٠١٢٣٤٥٦٧٨٩")
        return text.unicodeScalars.allSatisfy { numberCharacters.contains($0) }
    }

    // Ornamental Ayah Number Badge
    private func ayahBadgeView(numberString: String) -> some View {
        ZStack {
            Circle()
                .stroke(dsColors.primary, lineWidth: 1.5)
                .background(Circle().fill(dsColors.background))
                .frame(width: 28, height: 28)
            
            Text(numberString)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(dsColors.textPrimary)
        }
    }

    private func pageFont(size: CGFloat) -> Font {
        if let fontName {
            return .custom(fontName, size: size)
        }
        return .system(size: size)
    }
}
