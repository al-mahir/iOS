//
//  TafsirDetailView.swift
//  Search
//

import SwiftUI
import Common

/// Full-screen view for a loaded Tafsir commentary.
struct TafsirDetailView: View {
    let tafsirData: TafsirData
    let surahName: String
    let arabicName: String

    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .top) {
            dsColors.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    headerSection
                        .padding(.bottom, DSSpacing.lg)

                    // Commentary card
                    tafsirTextCard
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.bottom, 40)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
    }

    // MARK: - Header

    private var headerSection: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [dsColors.primary, dsColors.primary.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                // Navigation row
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Text("Tafsir Ibn Kathir", bundle: .module)
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(.white.opacity(0.9))

                    Spacer()
                    // Balance the back button width
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.md)

                // Surah + Ayah identity
                VStack(spacing: DSSpacing.xs) {
                    Text(arabicName)
                        .dsArabicFont(DSTypography.headlineMedium)
                        .foregroundColor(.white)

                    Text(surahName)
                        .dsFont(DSTypography.headlineSmall)
                        .foregroundColor(.white.opacity(0.9))

                    HStack(spacing: DSSpacing.sm) {
                        Label("Surah \(tafsirData.surah)", systemImage: "book.closed")
                        Text("·")
                        Label("Ayah \(tafsirData.ayah)", systemImage: "text.alignleft")
                    }
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(.white.opacity(0.75))
                    .labelStyle(.titleAndIcon)
                }
                .padding(.top, DSSpacing.md)
                .padding(.bottom, DSSpacing.xl)
            }
        }
        .frame(minHeight: 200)
    }

    // MARK: - Commentary card

    private var tafsirTextCard: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            // Card label
            HStack(spacing: DSSpacing.sm) {
                Image(systemName: "text.quote")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dsColors.primary)
                Text("Commentary", bundle: .module)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
            }

            Divider()
                .background(dsColors.outlineVariant)

            // Tafsir body text lines
            let lines = tafsirData.text.components(separatedBy: "\n")
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                    TafsirParagraphView(text: line)
                }
            }
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Paragraph Renderer

private struct TafsirParagraphView: View {
    let text: String
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            Spacer().frame(height: 4)
        } else if isArabicLine(trimmed) {
            Text(trimmed)
                .dsArabicFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(10)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, DSSpacing.xs)
                .environment(\.layoutDirection, .rightToLeft)
                .textSelection(.enabled)
        } else {
            Text(trimmed)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .textSelection(.enabled)
        }
    }

    private func isArabicLine(_ string: String) -> Bool {
        let arabicScalars = string.unicodeScalars.filter { scalar in
            (0x0600...0x06FF).contains(scalar.value) ||
            (0x0750...0x077F).contains(scalar.value) ||
            (0x08A0...0x08FF).contains(scalar.value) ||
            (0xFB50...0xFDFF).contains(scalar.value) ||
            (0xFE70...0xFEFF).contains(scalar.value)
        }
        let letterScalars = string.unicodeScalars.filter { CharacterSet.letters.contains($0) }
        guard !letterScalars.isEmpty else { return false }
        return Double(arabicScalars.count) / Double(letterScalars.count) > 0.4
    }
}
