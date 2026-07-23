//
//  AudioControlBar.swift
//  Listening
//

import SwiftUI
import Common

/// Full-featured audio control bar for Listening Mode.
/// Transport row: gobackward.10 | Prev Ayah | Play/Pause | Next Ayah | goforward.10
/// Repeat toggle lives in the header row (top-right), next to the waveform.
public struct AudioControlBar: View {

    @ObservedObject private var viewModel: ListeningViewModel
    @Environment(\.dsColors) private var dsColors
    @State private var isSeeking  = false
    @State private var seekValue: Double = 0

    public init(viewModel: ListeningViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Top separator
            Rectangle()
                .fill(dsColors.outlineVariant.opacity(0.4))
                .frame(height: 1)

            VStack(spacing: DSSpacing.sm) {
                headerRow
                timelineRow
                transportRow
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.smMd)
            .padding(.bottom, DSSpacing.sm)
            .background(dsColors.surfaceContainer)
        }
    }

    // MARK: - Header Row

    private var headerRow: some View {
        HStack(alignment: .center, spacing: DSSpacing.smMd) {
            // Headphones icon
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer)
                    .frame(width: 42, height: 42)
                Image(systemName: "headphones")
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(dsColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.currentChapterName.isEmpty ? "Loading…" : viewModel.currentChapterName)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .lineLimit(1)

                Text(viewModel.selectedReciter?.displayName ?? "Select a reciter")
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
                    .lineLimit(1)
            }

            Spacer()

            // Waveform while playing
            if viewModel.playbackState == .playing {
                WaveformView()
                    .frame(width: 24, height: 16)
                    .foregroundColor(dsColors.primary)
            } else if viewModel.isLoading {
                ProgressView().scaleEffect(0.75)
            }

            // Repeat toggle — top right
            repeatButton
        }
    }

    // MARK: - Timeline

    private var timelineRow: some View {
        VStack(spacing: 4) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(dsColors.surfaceContainerHighest)
                        .frame(height: 4)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [dsColors.primary, dsColors.primaryVariant],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geo.size.width * (isSeeking ? seekValue : viewModel.progress),
                            height: 4
                        )

                    Circle()
                        .fill(dsColors.primary)
                        .frame(width: 14, height: 14)
                        .offset(x: max(0, geo.size.width * (isSeeking ? seekValue : viewModel.progress) - 7))
                        .shadow(color: dsColors.primary.opacity(0.45), radius: 4)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            isSeeking = true
                            seekValue = max(0, min(value.location.x / geo.size.width, 1))
                        }
                        .onEnded { value in
                            let fraction = max(0, min(value.location.x / geo.size.width, 1))
                            viewModel.seek(to: fraction)
                            isSeeking = false
                        }
                )
            }
            .frame(height: 20)

            HStack {
                Text(viewModel.currentTimeDisplay)
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textTertiary)
                Spacer()
                Text(viewModel.durationDisplay)
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textTertiary)
            }
        }
    }

    // MARK: - Transport Row
    // Layout: gobackward.10 | Prev Ayah | Play/Pause | Next Ayah | goforward.10

    private var transportRow: some View {
        HStack(spacing: DSSpacing.lgXl) {
            // Skip back 10s
            controlButton(icon: "gobackward.10", size: 22) {
                viewModel.skip(seconds: -10)
            }

            // Previous Ayah
            controlButton(icon: "backward.end.fill", size: 18) {
                viewModel.previousAyah()
            }

            // Play / Pause
            playPauseButton

            // Next Ayah
            controlButton(icon: "forward.end.fill", size: 18) {
                viewModel.nextAyah()
            }

            // Skip forward 10s
            controlButton(icon: "goforward.10", size: 22) {
                viewModel.skip(seconds: 10)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Repeat Button (header)

    private var repeatButton: some View {
        let isOn = viewModel.isRepeatEnabled
        return Button {
            viewModel.toggleRepeat()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(isOn ? dsColors.primary.opacity(0.15) : dsColors.surfaceContainerHigh)
                    .frame(width: 36, height: 30)

                HStack(spacing: 3) {
                    Image(systemName: "repeat")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(isOn ? dsColors.primary : dsColors.textSecondary)
                    if isOn {
                        Circle()
                            .fill(dsColors.primary)
                            .frame(width: 5, height: 5)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isOn)
    }

    // MARK: - Play/Pause Button

    private var playPauseButton: some View {
        Button { viewModel.togglePlayPause() } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [dsColors.primary, dsColors.primaryVariant],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: dsColors.primary.opacity(0.4), radius: 8, y: 4)

                if viewModel.isLoading {
                    ProgressView().tint(dsColors.onPrimary)
                } else {
                    Image(systemName: playPauseIcon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(dsColors.onPrimary)
                }
            }
        }
        .scaleEffect(viewModel.playbackState == .playing ? 1.0 : 0.95)
        .animation(.spring(response: 0.25, dampingFraction: 0.65), value: viewModel.playbackState)
    }

    // MARK: - Helpers

    private var playPauseIcon: String {
        switch viewModel.playbackState {
        case .playing:  return "pause.fill"
        case .finished: return "arrow.counterclockwise"
        default:        return "play.fill"
        }
    }

    private func controlButton(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size, weight: .medium))
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 36, height: 36)
        }
    }
}

// MARK: - Waveform Animation

private struct WaveformView: View {
    private let heights: [CGFloat] = [0.4, 0.9, 0.6, 1.0, 0.5]

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                WaveformBar(targetHeight: heights[i], delay: Double(i) * 0.1)
            }
        }
    }
}

private struct WaveformBar: View {
    let targetHeight: CGFloat
    let delay: Double
    @State private var animating = false

    var body: some View {
        Capsule()
            .frame(width: 3, height: animating ? 18 * targetHeight : 4)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) { animating = true }
            }
    }
}
