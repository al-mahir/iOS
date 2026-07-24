//
//  LastReadPreview.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import SwiftUI
import Common

public struct LastReadPreview {
    public let surahName: String
    public let ayahNumber: Int
    public let juzNumber: Int
    public let progress: Double
}

struct LastReadCard: View {
    @Environment(\.dsColors) private var dsColors
    let lastRead: LastReadPreview
    let onResume: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            artwork
            
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Surah \(lastRead.surahName)")
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(dsColors.textPrimary)
                
                Text("Ayah \(lastRead.ayahNumber) · Juz \(lastRead.juzNumber)")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textTertiary)
                
                ProgressView(value: lastRead.progress)
                    .tint(dsColors.primary)
                
                HStack {
                    Text("\(Int(lastRead.progress * 100))% Complete")
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.textSecondary)
                    
                    Spacer()
                    
                    Button(action: onResume) {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Resume Reading")
                                .dsFont(DSTypography.labelLarge)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(dsColors.onPrimary)
                        .padding(.horizontal, DSSpacing.smMd)
                        .padding(.vertical, DSSpacing.sm)
                        .background(Capsule().fill(dsColors.primary))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
        .dsElevation(DSElevation.level2)
    }
    
    private var artwork: some View {
        ZStack(alignment: .topLeading) {
          
            Image("lastReadThumbnail", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fill)
            
            Text("LAST READ")
                .dsFont(DSTypography.overline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(Capsule().fill(Color.black.opacity(0.4)))
                .padding(DSSpacing.smMd)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(
            .rect(
                topLeadingRadius: DSRadius.lg,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: DSRadius.lg
            )
        )
    }
}

struct StartExploringCard: View {
    @Environment(\.dsColors) private var dsColors
    let onStartExploring: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            artwork

            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Start Exploring Quran")
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(dsColors.textPrimary)

                Text("Begin your journey with Al-Fatihah, Page 1")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textTertiary)

                HStack {
                    Spacer()

                    Button(action: onStartExploring) {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Start Exploring")
                                .dsFont(DSTypography.labelLarge)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(dsColors.onPrimary)
                        .padding(.horizontal, DSSpacing.smMd)
                        .padding(.vertical, DSSpacing.sm)
                        .background(Capsule().fill(dsColors.primary))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(DSSpacing.md)
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
        .dsElevation(DSElevation.level2)
    }

    private var artwork: some View {
        ZStack(alignment: .topLeading) {
            Image("lastReadThumbnail", bundle: .module)
                .resizable()
                .aspectRatio(contentMode: .fill)

            Text("EXPLORE QURAN")
                .dsFont(DSTypography.overline)
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xxs)
                .background(Capsule().fill(Color.black.opacity(0.4)))
                .padding(DSSpacing.smMd)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .clipped()
        .clipShape(
            .rect(
                topLeadingRadius: DSRadius.lg,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: DSRadius.lg
            )
        )
    }
}
