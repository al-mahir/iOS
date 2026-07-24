//
//  SettingsView.swift
//  Settings
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI
import Common

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {

                    SettingsSectionHeader(title: "App appearance")
                    card {
                        SettingsRow(icon: "globe", title: "Language") {
                            viewModel.openLanguageSettings()
                        }
                        rowDivider
                        SettingsRow(icon: "sun.max", title: "Theme", subtitle: viewModel.selectedTheme.displayName) {
                            viewModel.openThemeSettings()
                        }
                    }

                    SettingsSectionHeader(title: "Notifications")
                    card {
                        SettingsRow(
                            icon: "bell",
                            title: "Reminders",
                            isOn: $viewModel.isRemindersEnabled
                        )
                    }

                    SettingsSectionHeader(title: "Sounds and haptics")
                    card {
                        SettingsRow(
                            icon: "exclamationmark.circle",
                            title: "Errors",
                            isOn: $viewModel.isErrorsEnabled
                        )
                    }

                    SettingsSectionHeader(title: "Mushaf preferences")
                    card {
                        SettingsRow(
                            icon: "drop",
                            title: "Tajweed",
                            subtitle: "Colour the script by tajweed rules",
                            isOn: $viewModel.isTajweedEnabled
                        )
                        rowDivider
                        SettingsRow(
                            icon: "drop",
                            title: "Correction settings",
                            subtitle: "Engine, sensitivity, rules and recitation style"
                        ) {
                            viewModel.openMistakesSettings()
                        }
                    }

                    SettingsSectionHeader(title: "Downloads")
                    card {
                        SettingsRow(icon: "headphones", title: "Reciters") {
                            viewModel.openReciters()
                        }
                        rowDivider
                        SettingsRow(icon: "character.bubble", title: "Translation") {
                            viewModel.openTranslations()
                        }
                        rowDivider
                        SettingsRow(icon: "book", title: "Tafsir") {
                            viewModel.openTafsir()
                        }
                    }

                    SettingsSectionHeader(title: "Privacy")
                    card {
                        SettingsRow(
                            icon: "lock",
                            title: "Data usage",
                            isOn: $viewModel.isDataUsageEnabled
                        )
                        rowDivider
                        SettingsRow(
                            icon: "minus.circle",
                            title: "Delete all recordings",
                            isDestructive: true
                        ) {
                            viewModel.requestDeleteAllRecordings()
                        }
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.lg)

                footer
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .dsTheme()
        .confirmationDialog("Select Theme", isPresented: $viewModel.showThemeDialog, titleVisibility: .visible) {
            ForEach(AppTheme.allCases) { theme in
                Button(theme.displayName) {
                    viewModel.selectTheme(theme)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert(isPresented: $viewModel.showDeleteRecordingsAlert) {
            Alert(
                title: Text("Delete Recordings"),
                message: Text("Are you sure you want to delete all recordings? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.executeDeleteAllRecordings()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }

    private var header: some View {
        ZStack {
            Text("Settings")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(dsColors.surfaceContainerLowest)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(dsColors.textPrimary)
                        )
                        .overlay(
                            Circle().stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: dsColors.shadow.opacity(0.05), radius: 4, x: 0, y: 2)
                }

                Spacer()
            }
        }
        .padding(.horizontal, DSSpacing.mdLg)
        .padding(.vertical, DSSpacing.md)
        .background(dsColors.surfaceContainerLowest)
        .overlay(
            Rectangle()
                .fill(dsColors.outlineVariant.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    private var footer: some View {
        VStack(spacing: DSSpacing.xs) {
            Text("Al-Mahir · Version 1.0")
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(dsColors.textHint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xl)
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .background(dsColors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                    .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
            )
    }

    private var rowDivider: some View {
        Divider()
            .background(dsColors.outlineVariant.opacity(0.3))
            .padding(.leading, 56)
    }
}

#Preview {
    SettingsView()
}
