//
//  MushafModeSegmentedBar.swift
//  Mushaf
//


import SwiftUI
import Common

struct MushafModeSegmentedBar: View {
    @Environment(\.dsColors) private var dsColors

    @Binding var selectedMode: MushafMode
    let modes: [MushafMode]
    let isTextHidden: Bool
    let onToggleTextHidden: () -> Void

    var currentStep: Int = 0
    var onNextStep: () -> Void = {}

    var body: some View {
        HStack(spacing: DSSpacing.sm) {
            Button(action: onToggleTextHidden) {
                Image(systemName: isTextHidden ? "eye.slash" : "eye")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(dsColors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(dsColors.surfaceContainerLow))
            }

            // Mode segments
            HStack(spacing: 2) {
                ForEach(modes) { mode in
                    segmentButton(mode)
                }
            }
            .padding(3)
            .background(Capsule().fill(dsColors.surfaceContainerLow))
        }
    }

    @ViewBuilder
    private func segmentButton(_ mode: MushafMode) -> some View {
        let isSelected = mode == selectedMode

        Button {
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
        .modifier(SegmentAnchorModifier(mode: mode))
    }
}

private struct SegmentAnchorModifier: ViewModifier {
    let mode: MushafMode

    private var targetStep: Int? {
        switch mode {
        case .reading:    return 3
        case .listening:  return 4
        case .correction: return 5
        case .muallem:    return 6
        default:          return nil
        }
    }

    func body(content: Content) -> some View {
        if let step = targetStep {
            content.tooltipAnchor(step)
        } else {
            content
        }
    }
}

