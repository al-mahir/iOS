
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

                    Text("Tafsir Ibn Kathir")
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
                Text("Commentary")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
            }

            Divider()
                .background(dsColors.outlineVariant)

            // Tafsir body text
            Text(tafsirData.text)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}
