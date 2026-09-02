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
    @State private var selectedHistoryEntry: TestHistoryEntry?
    @ObservedObject private var historyStore = TestHistoryStore.shared

    @Environment(\.tabBarVisibility) private var tabBarVisibility

    /// Invoked by the exam and result screens to exit the whole Test flow
    /// straight back to Home, skipping this hub. Defaults to a no-op so
    /// `TestHubView` still compiles/works if ever pushed from somewhere
    /// other than `HomeView` — in that case its own default back button
    /// still returns to whatever presented it, one level at a time.
    private let onExitTestFlow: () -> Void

    public init(onExitTestFlow: @escaping () -> Void = {}) {
        self.onExitTestFlow = onExitTestFlow
    }

    public var body: some View {
        VStack(spacing: DSSpacing.lg) {
            
            // MARK: - Hero Action Card
            VStack(spacing: DSSpacing.smMd) {
                ZStack {
                    Circle()
                        .fill(DSGradients.primary)
                        .frame(width: 72, height: 72)

                    Image(systemName: "mic.badge.plus")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(.white)
                }
                .dsElevation(DSElevation.level2)
                .padding(.top, DSSpacing.xs)

                Text("Test Your Recitation", bundle: .module)
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text("Select a Juz', Surah, or Ayah range to begin testing your recitation accuracy.", bundle: .module)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DSSpacing.sm)

                Button(action: { navigateToTestSetup = true }) {
                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "play.fill")
                        Text("Start New Test", bundle: .module)
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
                Text("Recent Test History", bundle: .module)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)

                if historyStore.entries.isEmpty {
                    VStack(spacing: DSSpacing.xs) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 32))
                            .foregroundColor(dsColors.textTertiary)
                            .padding(.top, DSSpacing.sm)

                        Text("No tests taken yet", bundle: .module)
                            .dsFont(DSTypography.bodyMedium)
                            .foregroundColor(dsColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .fill(dsColors.surfaceContainerLowest)
                    )
                } else {
                    VStack(spacing: DSSpacing.sm) {
                        ForEach(historyStore.entries) { entry in
                            Button {
                                selectedHistoryEntry = entry
                            } label: {
                                historyRow(for: entry)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .background(dsColors.background)
        .navigationTitle(Text("Quran Test", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToTestSetup) {
            TestFeatureRootView(onExitTestFlow: onExitTestFlow)
                .dsTheme()
        }
        .navigationDestination(item: $selectedHistoryEntry) { entry in
            TestResultView(result: entry.result, onDone: { selectedHistoryEntry = nil })
                .dsTheme()
        }
        .onAppear {
            tabBarVisibility.isVisible = false
        }
    }

    // MARK: - History row

    private func historyRow(for entry: TestHistoryEntry) -> some View {
        HStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(entry.result.scorePercentage >= 70 ? dsColors.successContainer : dsColors.warningContainer)
                    .frame(width: 44, height: 44)
                Text("\(Int(entry.result.scorePercentage))%")
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(entry.result.scorePercentage >= 70 ? dsColors.success : dsColors.warning)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.result.configuration.scope.displayTitle)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                Text("\(entry.result.correctQuestions)/\(entry.result.totalQuestions) perfect", bundle: .module)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.forward")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(dsColors.textSecondary)
        }
        .padding(DSSpacing.smMd)
        .background(dsColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
    }
}
