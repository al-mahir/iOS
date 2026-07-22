//
//  MushafModeSheet.swift
//  Mushaf
//
//  Created by Alaa Ayman on 20/07/2026.
//


import SwiftUI
import Common

struct MushafModeSheet: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    let selectedMode: MushafMode
    let onStart: (MushafMode) -> Void

    @State private var pendingMode: MushafMode

    init(selectedMode: MushafMode, onStart: @escaping (MushafMode) -> Void) {
        self.selectedMode = selectedMode
        self.onStart = onStart
        self._pendingMode = State(initialValue: selectedMode)
    }

    var body: some View {
            VStack(spacing: DSSpacing.lg) {
                Capsule()
                    .fill(dsColors.outlineVariant)
                    .frame(width: 36, height: 4)
                    .padding(.top, DSSpacing.sm)

                Text("Choose recitation mode")
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textSecondary)

                VStack(spacing: DSSpacing.sm) {
                    ForEach(MushafMode.allCases) { mode in
                        modeRow(mode)
                    }
                }

                AppButton(title: "Start Session") {
                    onStart(pendingMode)
                    dismiss()
                }
               
                .padding(.bottom, DSSpacing.lg)
            }
            .padding(.horizontal, DSSpacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(dsColors.surfaceContainer.ignoresSafeArea())
        }

    private func modeRow(_ mode: MushafMode) -> some View {
        let isSelected = pendingMode == mode

        return Button {
            withAnimation(.easeOut(duration: 0.15)) { pendingMode = mode }
        } label: {
            HStack(spacing: DSSpacing.smMd) {
                ZStack {
                    Circle()
                        .fill(isSelected ? dsColors.primary : dsColors.surfaceContainerHigh)
                        .frame(width: 44, height: 44)
                    Image(systemName: mode.systemImage)
                        .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(mode.englishTitle)
                            .dsFont(DSTypography.bodyMedium)
                            .foregroundColor(dsColors.textPrimary)
                        Spacer()
                    }
                    Text(mode.subtitle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textTertiary)
                }

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(dsColors.primary)
                        
                }
            }
            .padding(DSSpacing.smMd)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(isSelected ? dsColors.primaryContainer.opacity(0.4) : dsColors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .stroke(isSelected ? dsColors.primary : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
