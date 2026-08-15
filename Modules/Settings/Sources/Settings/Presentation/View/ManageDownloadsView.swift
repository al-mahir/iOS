//
//  ManageDownloadsView.swift
//  Settings
//

import SwiftUI
import Common
import Listening

/// View for managing and selectively deleting offline reciter audio recordings.
public struct ManageDownloadsView: View {

    @ObservedObject private var downloadManager: AudioDownloadManager = .shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    @State private var isSelectionMode: Bool = false
    @State private var selectedItemIDs: Set<String> = []
    @State private var showDeleteConfirmation: Bool = false
    @State private var showDeleteAllConfirmation: Bool = false
    @State private var expandedReciterIDs: Set<Int> = []
    @State private var singleSurahToDelete: DownloadedSurah? = nil
    @State private var reciterToDelete: (id: Int, name: String)? = nil

    public init() {}

    private var groupedDownloads: [(reciterId: Int, reciterName: String, items: [DownloadedSurah])] {
        let dict = Dictionary(grouping: downloadManager.downloads, by: { $0.reciterId })
        return dict.map { (reciterId, items) in
            let name = items.first?.reciterName ?? String(
                localized: "Reciter #\(reciterId)",
                bundle: CommonBundle.bundle
            )
            return (reciterId: reciterId, reciterName: name, items: items.sorted(by: { $0.surahNumber < $1.surahNumber }))
        }.sorted(by: { $0.reciterName < $1.reciterName })
    }

    private var selectedTotalSize: String {
        let selectedItems = downloadManager.downloads.filter { selectedItemIDs.contains($0.id) }
        let bytes = selectedItems.reduce(0) { $0 + $1.fileSize }
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    public var body: some View {
        VStack(spacing: 0) {
            header

            if downloadManager.downloads.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: DSSpacing.md) {
                        storageSummaryCard

                        ForEach(groupedDownloads, id: \.reciterId) { group in
                            reciterSection(group)
                        }

                        deleteAllButton
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.md)
                    .padding(.bottom, isSelectionMode ? 80 : DSSpacing.xl)
                }

                if isSelectionMode {
                    bottomActionBar
                }
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .dsTheme()
        .alert("Delete Selected Recordings", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                downloadManager.deleteDownloads(ids: selectedItemIDs)
                selectedItemIDs.removeAll()
                isSelectionMode = false
            }
        } message: {
            Text("Are you sure you want to delete \(selectedItemIDs.count) selected recording(s) (\(selectedTotalSize))? This cannot be undone.")
        }
        .alert("Delete All Recordings", isPresented: $showDeleteAllConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete All", role: .destructive) {
                downloadManager.deleteAllDownloads()
                selectedItemIDs.removeAll()
                isSelectionMode = false
            }
        } message: {
            Text("Are you sure you want to delete all offline recordings (\(downloadManager.formattedTotalStorageSize))? This action cannot be undone.")
        }
        .alert(
            "Delete Surah",
            isPresented: Binding(
                get: { singleSurahToDelete != nil },
                set: { if !$0 { singleSurahToDelete = nil } }
            )
        ) {
            if let item = singleSurahToDelete {
                Button("Cancel", role: .cancel) { singleSurahToDelete = nil }
                Button("Delete", role: .destructive) {
                    downloadManager.deleteDownload(reciterId: item.reciterId, surahNumber: item.surahNumber)
                    singleSurahToDelete = nil
                }
            }
        } message: {
            if let item = singleSurahToDelete {
                Text("Are you sure you want to delete \(item.surahName) (\(item.formattedSize))?")
            }
        }
        .alert(
            "Delete Reciter Recordings",
            isPresented: Binding(
                get: { reciterToDelete != nil },
                set: { if !$0 { reciterToDelete = nil } }
            )
        ) {
            if let group = reciterToDelete {
                Button("Cancel", role: .cancel) { reciterToDelete = nil }
                Button("Delete All", role: .destructive) {
                    downloadManager.deleteReciterDownloads(reciterId: group.id)
                    reciterToDelete = nil
                }
            }
        } message: {
            if let group = reciterToDelete {
                Text("Are you sure you want to delete all offline recordings for \(group.name)?")
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Manage Offline Recordings")
                .dsFont(DSTypography.titleMedium)
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
                }

                Spacer()

                if !downloadManager.downloads.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isSelectionMode.toggle()
                            if !isSelectionMode {
                                selectedItemIDs.removeAll()
                            }
                        }
                    }) {
                        // A ternary of two string literals loses its LocalizedStringKey
                        // inference and would render un-localized verbatim text, so branch
                        // explicitly instead of `Text(isSelectionMode ? "Cancel" : "Select")`.
                        if isSelectionMode {
                            Text("Cancel")
                                .dsFont(DSTypography.labelLarge)
                                .foregroundColor(dsColors.primary)
                        } else {
                            Text("Select")
                                .dsFont(DSTypography.labelLarge)
                                .foregroundColor(dsColors.primary)
                        }
                    }
                }
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

    // MARK: - Storage Summary Card

    private var storageSummaryCard: some View {
        HStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer)
                    .frame(width: 48, height: 48)
                Image(systemName: "internaldrive.fill")
                    .font(.system(size: 20))
                    .foregroundColor(dsColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(downloadManager.formattedTotalStorageSize)
                    .dsFont(DSTypography.headlineMedium)
                    .foregroundColor(dsColors.textPrimary)
                Text("Total storage used by \(downloadManager.downloads.count) offline surahs")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Reciter Section

    private func reciterSection(_ group: (reciterId: Int, reciterName: String, items: [DownloadedSurah])) -> some View {
        let isExpanded = expandedReciterIDs.contains(group.reciterId) || isSelectionMode
        let groupBytes = group.items.reduce(0) { $0 + $1.fileSize }
        let groupSizeStr = ByteCountFormatter.string(fromByteCount: groupBytes, countStyle: .file)
        let allGroupSelected = group.items.allSatisfy { selectedItemIDs.contains($0.id) }

        return VStack(spacing: 0) {
            // Reciter Header
            HStack(spacing: DSSpacing.smMd) {
                if isSelectionMode {
                    Button(action: {
                        if allGroupSelected {
                            for item in group.items { selectedItemIDs.remove(item.id) }
                        } else {
                            for item in group.items { selectedItemIDs.insert(item.id) }
                        }
                    }) {
                        Image(systemName: allGroupSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(allGroupSelected ? dsColors.primary : dsColors.textHint)
                            .font(.system(size: 20))
                    }
                }

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if expandedReciterIDs.contains(group.reciterId) {
                            expandedReciterIDs.remove(group.reciterId)
                        } else {
                            expandedReciterIDs.insert(group.reciterId)
                        }
                    }
                }) {
                    HStack(spacing: DSSpacing.smMd) {
                        ZStack {
                            Circle()
                                .fill(dsColors.primaryContainer.opacity(0.5))
                                .frame(width: 36, height: 36)
                            Text(String(group.reciterName.prefix(1)))
                                .dsFont(DSTypography.titleSmall)
                                .foregroundColor(dsColors.primary)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.reciterName)
                                .dsFont(DSTypography.titleMedium)
                                .foregroundColor(dsColors.textPrimary)
                            Text("\(group.items.count) Surahs · \(groupSizeStr)")
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textSecondary)
                        }

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(dsColors.textHint)
                    }
                }
                .buttonStyle(.plain)

                if !isSelectionMode {
                    Button(action: {
                        reciterToDelete = (group.reciterId, group.reciterName)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(dsColors.error)
                            .padding(6)
                    }
                }
            }
            .padding(DSSpacing.md)
            .background(dsColors.surfaceContainerLowest)

            if isExpanded {
                Divider()
                    .background(dsColors.outlineVariant.opacity(0.3))

                VStack(spacing: 0) {
                    ForEach(Array(group.items.enumerated()), id: \.element.id) { index, item in
                        surahRow(item)
                        if index < group.items.count - 1 {
                            Divider()
                                .padding(.leading, isSelectionMode ? 60 : 48)
                                .background(dsColors.outlineVariant.opacity(0.2))
                        }
                    }
                }
                .background(dsColors.surfaceContainerLowest.opacity(0.7))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Surah Row

    private func surahRow(_ item: DownloadedSurah) -> some View {
        let isSelected = selectedItemIDs.contains(item.id)

        return HStack(spacing: DSSpacing.smMd) {
            if isSelectionMode {
                Button(action: {
                    if isSelected {
                        selectedItemIDs.remove(item.id)
                    } else {
                        selectedItemIDs.insert(item.id)
                    }
                }) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? dsColors.primary : dsColors.textHint)
                        .font(.system(size: 18))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Surah \(item.surahName) (#\(item.surahNumber))")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                Text(item.formattedSize)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)
            }

            Spacer()

            if !isSelectionMode {
                Button(action: {
                    singleSurahToDelete = item
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                        .foregroundColor(dsColors.error.opacity(0.8))
                        .padding(6)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelectionMode {
                if isSelected {
                    selectedItemIDs.remove(item.id)
                } else {
                    selectedItemIDs.insert(item.id)
                }
            }
        }
    }

    // MARK: - Bottom Action Bar (Selection Mode)

    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
                .background(dsColors.outlineVariant.opacity(0.3))

            HStack {
                Text("\(selectedItemIDs.count) selected (\(selectedTotalSize))")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)

                Spacer()

                Button(action: {
                    if !selectedItemIDs.isEmpty {
                        showDeleteConfirmation = true
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14))
                        Text("Delete Selected")
                            .dsFont(DSTypography.labelLarge)
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.vertical, DSSpacing.sm)
                    .background(selectedItemIDs.isEmpty ? dsColors.textDisabled : dsColors.error, in: Capsule())
                    .foregroundColor(.white)
                }
                .disabled(selectedItemIDs.isEmpty)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.smMd)
            .background(dsColors.surfaceContainerLowest)
        }
    }

    // MARK: - Delete All Button

    private var deleteAllButton: some View {
        Button(action: {
            showDeleteAllConfirmation = true
        }) {
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(dsColors.error)
                Text("Delete All Recordings")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.error)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DSSpacing.md)
            .background(dsColors.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: DSRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .stroke(dsColors.error.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, DSSpacing.md)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()

            ZStack {
                Circle()
                    .fill(dsColors.surfaceContainerHigh)
                    .frame(width: 80, height: 80)
                Image(systemName: "arrow.down.circle")
                    .font(.system(size: 40))
                    .foregroundColor(dsColors.textHint)
            }

            Text("No Offline Recordings")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)

            Text("Surahs you download for offline listening will appear here. You can select and delete them anytime.")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.xl)

            Spacer()
        }
    }
}
