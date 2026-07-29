//
//  SheikhAudioSampleCard.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhAudioSampleCard: View {
    let sample: SheikhAudioSample
    let isPlaying: Bool
    let onPlayToggle: () -> Void

    @Environment(\.dsColors) private var dsColors

    public init(
        sample: SheikhAudioSample,
        isPlaying: Bool,
        onPlayToggle: @escaping () -> Void
    ) {
        self.sample = sample
        self.isPlaying = isPlaying
        self.onPlayToggle = onPlayToggle
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            Button(action: onPlayToggle) {
                ZStack {
                    Circle()
                        .fill(isPlaying ? dsColors.primary : dsColors.primaryContainer)
                        .frame(width: 44, height: 44)

                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isPlaying ? dsColors.onPrimary : dsColors.primary)
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(sample.title)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .fontWeight(.semibold)

                Text(sample.riwaya)
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer(minLength: DSSpacing.xs)

            // Animated Waveform visualizer
            waveformVisualizer
        }
        .padding(DSSpacing.md)
        .frame(width: 240)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(isPlaying ? dsColors.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
                )
        )
    }

    private var waveformVisualizer: some View {
        HStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { index in
                RoundedRectangle(cornerRadius: 1)
                    .fill(isPlaying ? dsColors.primary : dsColors.outlineVariant)
                    .frame(width: 3, height: isPlaying ? barHeights[index] : 10)
                    .animation(
                        isPlaying ? Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true).delay(Double(index) * 0.1) : .default,
                        value: isPlaying
                    )
            }
        }
    }

    private var barHeights: [CGFloat] {
        [14, 22, 12, 18]
    }
}
