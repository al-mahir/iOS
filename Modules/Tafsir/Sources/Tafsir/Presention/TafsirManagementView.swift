//
//  TafsirManagementView.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//

import SwiftUI
import Combine
import Common

public struct TafsirManagementView: View {
    @StateObject private var viewModel = TafsirManagementViewModel()
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        List {
            Section {
                ForEach(viewModel.tafsirs) { tafsir in
                    row(for: tafsir)
                        .listRowBackground(dsColors.surfaceContainerLow)
                }
            } footer: {
                Text("Tap the star to set your primary tafsir — that's the one shown by default when you long-press an ayah.")
                    .dsFont(DSTypography.caption)
                    .foregroundColor(dsColors.textSecondary)
            }
        }
        .scrollContentBackground(.hidden)
        .background(dsColors.background.ignoresSafeArea())
        .navigationTitle("Manage Tafseers")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") { dismiss() }
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.textLink)
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.tafsirs.isEmpty {
                ProgressView()
                    .tint(dsColors.primary)
            }
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear { viewModel.load() }
    }

    @ViewBuilder
    private func row(for tafsir: TafsirInfo) -> some View {
        HStack(spacing: DSSpacing.smMd) {
            // Favorite / Primary Action Button
            Button {
                if tafsir.isDownloaded { viewModel.setPrimary(tafsir.tafsirKey) }
            } label: {
                Image(systemName: viewModel.primaryTafsirKey == tafsir.tafsirKey ? "star.fill" : "star")
                    .foregroundColor(viewModel.primaryTafsirKey == tafsir.tafsirKey ? dsColors.warning : dsColors.textDisabled)
            }
            .buttonStyle(.plain)
            .disabled(!tafsir.isDownloaded)

            // Info Section
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(tafsir.displayName)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)
                
                Text("\(tafsir.languageName) • \(formattedSize(tafsir.fileSizeBytes))")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            // State Actions (Progress, Remove, Download)
            if let progress = viewModel.downloadProgress[tafsir.tafsirKey] {
                ProgressView(value: progress)
                    .tint(dsColors.primary)
                    .frame(width: 60)
            } else if tafsir.isDownloaded {
                Button("Remove") { viewModel.delete(tafsir) }
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.error)
                    .buttonStyle(.borderless)
            } else {
                Button("Download") { viewModel.download(tafsir) }
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.textLink)
                    .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, DSSpacing.xs)
    }

    private func formattedSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: .file)
    }
}
