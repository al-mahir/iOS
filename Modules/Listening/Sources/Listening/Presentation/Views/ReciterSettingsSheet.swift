//
//  ReciterSettingsSheet.swift
//  Listening
//

import SwiftUI
import Common

/// Settings sheet for the Listening Module — only shown when Listening Mode is active.
/// Sections: Reciter selection, Word Highlight toggle, Repeat toggle.
public struct ReciterSettingsSheet: View {

    @ObservedObject private var viewModel: ListeningViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""

    public init(viewModel: ListeningViewModel) {
        self.viewModel = viewModel
    }

    private var filteredReciters: [Reciter] {
        if searchText.isEmpty { return viewModel.reciters }
        return viewModel.reciters.filter {
            $0.displayName.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                dsColors.surfaceContainer.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DSSpacing.lg) {
                        // MARK: Search
                        searchBar

                        // MARK: Reciter List
                        reciterSection

                        // MARK: Listening Preferences
                        preferencesSection
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.md)
                }
            }
            .navigationTitle("Listening Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.primary)
                }
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textTertiary)
            TextField("Search reciter…", text: $searchText)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
        }
        .padding(DSSpacing.smMd)
        .background(dsColors.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }

    // MARK: - Reciter Section

    private var reciterSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionHeader("Reciter", icon: "person.fill")

            if viewModel.reciters.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: DSSpacing.sm) {
                        ProgressView()
                        Text("Loading reciters…")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textTertiary)
                    }
                    .padding(.vertical, DSSpacing.xl)
                    Spacer()
                }
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredReciters.enumerated()), id: \.element.id) { index, reciter in
                        reciterRow(reciter)
                        if index < filteredReciters.count - 1 {
                            Divider()
                                .padding(.leading, DSSpacing.xl3 + DSSpacing.smMd)
                        }
                    }
                }
                .background(dsColors.surface, in: RoundedRectangle(cornerRadius: DSRadius.lg))
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(dsColors.outlineVariant, lineWidth: 1)
                )
            }
        }
    }

    private func reciterRow(_ reciter: Reciter) -> some View {
        let isSelected = viewModel.selectedReciter?.id == reciter.id

        return Button {
            withAnimation(.easeOut(duration: 0.15)) {
                viewModel.selectReciter(reciter)
            }
            UISelectionFeedbackGenerator().selectionChanged()
        } label: {
            HStack(spacing: DSSpacing.smMd) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(isSelected ? dsColors.primary : dsColors.surfaceContainerHigh)
                        .frame(width: 40, height: 40)
                    Text(String(reciter.displayName.prefix(1)))
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(reciter.displayName)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(isSelected ? dsColors.primary : dsColors.textPrimary)
                        .lineLimit(1)

                    if let style = reciter.styleBadge {
                        Text(style)
                            .dsFont(DSTypography.labelSmall)
                            .foregroundColor(dsColors.textTertiary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(dsColors.primary)
                        .font(.system(size: 20))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(
                isSelected ? dsColors.primaryContainer.opacity(0.2) : Color.clear
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preferences Section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            sectionHeader("Preferences", icon: "slider.horizontal.3")

            VStack(spacing: 0) {
                // Word Highlight Toggle
                preferenceRow(
                    icon: "character.cursor.ibeam",
                    iconColor: dsColors.primary,
                    title: "Word Highlight",
                    subtitle: "Highlight each word as the Sheikh recites",
                    isOn: Binding(
                        get: { viewModel.isWordHighlightEnabled },
                        set: { _ in viewModel.toggleWordHighlight() }
                    )
                )

                Divider()
                    .padding(.leading, DSSpacing.xl3)

                // Repeat Toggle
                preferenceRow(
                    icon: "repeat",
                    iconColor: dsColors.secondary,
                    title: "Repeat Chapter",
                    subtitle: "Loop the chapter when playback finishes",
                    isOn: Binding(
                        get: { viewModel.isRepeatEnabled },
                        set: { _ in viewModel.toggleRepeat() }
                    )
                )
            }
            .background(dsColors.surface, in: RoundedRectangle(cornerRadius: DSRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(dsColors.outlineVariant, lineWidth: 1)
            )
        }
    }

    private func preferenceRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: DSSpacing.smMd) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                Text(subtitle)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textTertiary)
            }

            Spacer()

            Toggle("", isOn: isOn)
                .toggleStyle(.switch)
                .tint(dsColors.primary)
                .labelsHidden()
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(dsColors.primary)
            Text(title.uppercased())
                .dsFont(DSTypography.overline)
                .foregroundColor(dsColors.textTertiary)
        }
        .padding(.leading, DSSpacing.xs)
    }
}
