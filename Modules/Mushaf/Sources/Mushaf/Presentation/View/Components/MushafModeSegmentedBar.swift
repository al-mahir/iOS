//
//  MushafModeSegmentedBar.swift
//  Mushaf
//
//  Inline replacement for the old MushafModeSheet flow — modes are now
//  switched directly from the bottom bar via a segmented control, and an
//  eye toggle lets the user hide/reveal the page text (for memorisation
//  practice) without leaving the bottom bar.
//

import SwiftUI
import Common

struct MushafModeSegmentedBar: View {
    @Environment(\.dsColors) private var dsColors

    @Binding var selectedMode: MushafMode
    let modes: [MushafMode]
    let isTextHidden: Bool
    let onToggleTextHidden: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            // Eye toggle — show/hide the Qur'an text on the page.
            Button(action: onToggleTextHidden) {
                Image(systemName: isTextHidden ? "eye.slash" : "eye")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(dsColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(dsColors.surfaceContainerLow))
            }
            .accessibilityLabel(isTextHidden ? "Show text" : "Hide text")

            // Mode segments.
            HStack(spacing: 2) {
                ForEach(modes) { mode in
                    segmentButton(mode)
                }
            }
            .padding(3)
            .background(Capsule().fill(dsColors.surfaceContainerLow))
        }
    }

    private func segmentButton(_ mode: MushafMode) -> some View {
        let isSelected = mode == selectedMode

        return Button {
            guard !isSelected else { return }
            withAnimation(.easeOut(duration: 0.2)) { selectedMode = mode }
        } label: {
            Text(mode.englishTitle)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, DSSpacing.sm)
                .padding(.vertical, DSSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Capsule().fill(isSelected ? dsColors.primary : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}
