//
//  TaahudWordErrorListSheet.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 09/08/2026.
//

import SwiftUI
import Common
import Taahud

struct TaahudWordErrorListSheet: View {
    let flaggedWords: [(word: QuranWord, errors: [TajweedError])]
    var onClearAll: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var fontManager = MushafFontManager.shared
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        NavigationStack {
            Group {
                if flaggedWords.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(flaggedWords.indices, id: \.self) { index in
                                wordSection(flaggedWords[index])

                                if index < flaggedWords.count - 1 {
                                    Divider()
                                        .padding(.vertical, DSSpacing.sm)
                                }
                            }
                        }
                        .padding(DSSpacing.md)
                    }
                }
            }
            .navigationTitle("Recitation Errors")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !flaggedWords.isEmpty {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            onClearAll?()
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "trash")
                                Text("Clear")
                            }
                            .font(.subheadline)
                        }
                    }
                }
            }
        }
        .onAppear {
            fontManager.registerFonts()
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 32))
                .foregroundColor(.green)
            Text("No mistakes yet")
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private func wordSection(_ flagged: (word: QuranWord, errors: [TajweedError])) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                Spacer()
                Text(flagged.word.text)
                    .font(font(forPage: flagged.word.wordPosition))
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
            }

            ForEach(flagged.errors) { error in
                HStack(alignment: .top, spacing: DSSpacing.sm) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                        .padding(.top, 2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(error.rule.replacingOccurrences(of: "_", with: " ").capitalized)
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(dsColors.textPrimary)
                        Text(error.message)
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
            }
        }
    }

    private func font(forPage page: Int) -> Font {
        if let fontName = fontManager.fontName(forPage: page, set: .tajweed) {
            return .custom(fontName, size: 32)
        }
        return .system(size: 32)
    }
}
