//
//  GlobalAudioBanner.swift
//  Listening
//

import SwiftUI
import Common

/// A global floating mini-player banner shown across the app when audio is playing in the background.
public struct GlobalAudioBanner: View {

    @ObservedObject private var viewModel: ListeningViewModel
    private let onTapBanner: () -> Void

    @Environment(\.dsColors) private var dsColors

    public init(viewModel: ListeningViewModel, onTapBanner: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onTapBanner = onTapBanner
    }

    public var body: some View {
        Button(action: onTapBanner) {
            HStack(spacing: DSSpacing.smMd) {
                // Icon / Waveform
                ZStack {
                    Circle()
                        .fill(dsColors.primaryContainer)
                        .frame(width: 38, height: 38)

                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else if viewModel.playbackState == .playing {
                        Image(systemName: "waveform")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(dsColors.primary)
                    } else {
                        Image(systemName: "headphones")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(dsColors.primary)
                    }
                }

                // Surah & Reciter Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.currentChapterName.isEmpty ? String(localized: "Quran Recitation", bundle: CommonBundle.bundle) : SurahData.localizedName(for: viewModel.currentChapterNumber))
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)

                    Text(viewModel.selectedReciter?.localizedName ?? "")
                        .dsFont(DSTypography.caption)
                        .foregroundColor(dsColors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Play / Pause Toggle
                Button {
                    viewModel.togglePlayPause()
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    ZStack {
                        Circle()
                            .fill(dsColors.primary)
                            .frame(width: 34, height: 34)

                        Image(systemName: playPauseIcon)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(dsColors.onPrimary)
                    }
                }
                .buttonStyle(.plain)

                // Close / Stop Button
                Button {
                    viewModel.deactivateListeningMode()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(dsColors.textSecondary)
                        .padding(6)
                        .background(dsColors.surfaceContainerHigh, in: Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(dsColors.background)
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(dsColors.outlineVariant.opacity(0.4), lineWidth: 1)
            )
            .padding(.horizontal, DSSpacing.sm)
        }
        .buttonStyle(.plain)
    }

    private var playPauseIcon: String {
        switch viewModel.playbackState {
        case .playing:  return "pause.fill"
        case .finished: return "arrow.counterclockwise"
        default:        return "play.fill"
        }
    }
}
