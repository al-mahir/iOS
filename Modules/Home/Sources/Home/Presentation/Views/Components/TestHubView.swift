//
//  TestHubView.swift
//  Home
//
//  Created by Basmala Abuzied Ahmed on 04/08/2026.
//

import SwiftUI
import Common
import Test

public struct TestHubView: View {
    @Environment(\.dsColors) private var dsColors
    @State private var navigateToTestSetup = false
    
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    public init() {}

    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            
            // MARK: - Hero Action Card
            VStack(spacing: DSSpacing.smMd) {
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 72, height: 72)

                    Image(systemName: "mic.badge.plus")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(dsColors.primary)
                }
                .padding(.top, DSSpacing.xs)

                Text("Test Your Recitation")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text("Select a Juz', Surah, or Ayah range to begin testing your recitation accuracy.")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.sm)

                Button(action: { navigateToTestSetup = true }) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "play.fill")
                        Text("Start New Test")
                    }
                }
                .buttonStyle(DSPrimaryButtonStyle())
                .padding(.top, DSSpacing.xs)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(dsColors.surfaceContainerLow)
            )
            .dsElevation(DSElevation.level1)

            // MARK: - History Section
            VStack(alignment: .leading, spacing: DSSpacing.smMd) {
                Text("Recent Test History")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)

                VStack(spacing: DSSpacing.xs) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 32))
                        .foregroundColor(dsColors.textTertiary)
                        .padding(.top, DSSpacing.sm)

                    Text("No tests taken yet")
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(dsColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(dsColors.surfaceContainerLowest)
                )
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .background(dsColors.background)
        .navigationTitle("Quran Test")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToTestSetup) {
            TestFeatureRootView()
                .dsTheme()
        }
        .onAppear {
            tabBarVisibility.isVisible = false
        }
        .onDisappear {
            tabBarVisibility.isVisible = true
        }
    }
}
