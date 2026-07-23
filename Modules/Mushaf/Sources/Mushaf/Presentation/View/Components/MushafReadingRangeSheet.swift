//
//  MushafReadingRangeSheet.swift
//  Mushaf
//
//  Created by Alaa Ayman on 23/07/2026.
//

import SwiftUI
import Common

/// Shown right after the person picks Reading / Correction / Muallem mode, so they can
/// choose where on the current page to start, and whether the session should stop at the
/// end of this page or keep going across pages until the current Surah ends.
///
/// Note: this is scoped to the *currently loaded* page because the bundled DB doesn't carry
/// a surah -> page index. If a true "jump to any Surah/Ayah in the Quran" picker is needed
/// later, that index can be derived from the existing `words` table.
struct MushafReadingRangeSheet: View {
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    let hasSavedPosition: Bool
    let onConfirm: (RecitationRangeChoice) -> Void

    @State private var startChoice: RecitationRangeChoice.StartChoice
    @State private var endChoice: RecitationRangeChoice.EndChoice = .endOfPage

    init(hasSavedPosition: Bool, onConfirm: @escaping (RecitationRangeChoice) -> Void) {
        self.hasSavedPosition = hasSavedPosition
        self.onConfirm = onConfirm
        _startChoice = State(initialValue: hasSavedPosition ? .continueFromLastPosition : .beginningOfPage)
    }

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            Capsule()
                .fill(dsColors.outlineVariant)
                .frame(width: 36, height: 4)
                .padding(.top, DSSpacing.sm)

            Text("Where do you want to start?")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            VStack(spacing: DSSpacing.sm) {
                choiceRow(title: "Start of this page", isSelected: startChoice == .beginningOfPage) {
                    startChoice = .beginningOfPage
                }
                if hasSavedPosition {
                    choiceRow(title: "Continue from where I left off", isSelected: startChoice == .continueFromLastPosition) {
                        startChoice = .continueFromLastPosition
                    }
                }
            }

            Text("Where should it stop?")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            VStack(spacing: DSSpacing.sm) {
                choiceRow(title: "End of this page", isSelected: endChoice == .endOfPage) {
                    endChoice = .endOfPage
                }
                choiceRow(title: "End of this Surah (continues onto the next pages automatically)", isSelected: endChoice == .endOfSurah) {
                    endChoice = .endOfSurah
                }
            }

            AppButton(title: "Start Session") {
                onConfirm(RecitationRangeChoice(start: startChoice, end: endChoice))
                dismiss()
            }
            .padding(.bottom, DSSpacing.lg)
        }
        .padding(.horizontal, DSSpacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(dsColors.surfaceContainer.ignoresSafeArea())
    }

    private func choiceRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                Spacer()
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

struct RecitationRangeChoice {
    enum StartChoice: Equatable {
        case beginningOfPage
        case continueFromLastPosition
    }

    enum EndChoice: Equatable {
        case endOfPage
        case endOfSurah
    }

    let start: StartChoice
    let end: EndChoice
}
