//
//  SheikhDetailView.swift
//  Sheikh
//

import SwiftUI
import Common

public struct SheikhDetailView: View {

    @StateObject private var viewModel: SheikhDetailViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @MainActor
    public init(sheikh: Sheikh) {
        _viewModel = StateObject(
            wrappedValue: SheikhDIContainer.shared.makeSheikhDetailViewModel(
                sheikhID: sheikh.id,
                prefetched: sheikh
            )
        )
    }

    @MainActor
    public init(sheikhID: String) {
        _viewModel = StateObject(
            wrappedValue: SheikhDIContainer.shared.makeSheikhDetailViewModel(
                sheikhID: sheikhID
            )
        )
    }

    @State private var showUnfavoriteAlert: Bool = false

    public var body: some View {
        VStack(spacing: DSSpacing.none) {
            if let sheikh = viewModel.sheikh {
                // Header (Top App Bar + Profile Avatar + Name + Status)
                SheikhProfileHeaderView(
                    sheikh: sheikh,
                    onBackTap: {
                        viewModel.stopAudio()
                        dismiss()
                    },
                    onFavoriteTap: {
                        if sheikh.isFavorite {
                            showUnfavoriteAlert = true
                        } else {
                            viewModel.toggleFavorite()
                        }
                    }
                )

                PrivateSessionSectionView(
                    sheikhID: sheikh.id,
                    sheikhName: sheikh.fullName,
                    sheikhAvatarURL: sheikh.profilePictureUrl,
                    initialStatus: sheikh.sheikhStatus
                )
                
                // Sticky Segmented Tab Bar
                SheikhSegmentedTabBar(selectedTab: $viewModel.selectedTab)

                // Tab Content Scroll View
                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {
                        switch viewModel.selectedTab {
                        case .about:
                            aboutTabContent(sheikh)
                        case .reviews:
                            reviewsTabContent(sheikh)
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.md)
                    .padding(.bottom, DSSpacing.xl2)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 110)
                }
            } else if viewModel.isLoading {
                loadingSkeleton
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTab)
        .onAppear {
            viewModel.loadDetail()
        }
        .onDisappear {
            viewModel.stopAudio()
        }
        .alert(String(localized: "Remove Bookmark?", bundle: .module), isPresented: $showUnfavoriteAlert) {
            Button(String(localized: "Remove", bundle: .module), role: .destructive) {
                viewModel.toggleFavorite()
            }
            Button(String(localized: "Cancel", bundle: .module), role: .cancel) {}
        } message: {
            if let sheikh = viewModel.sheikh {
                Text("Are you sure you want to remove \(sheikh.fullName) from your bookmarks?", bundle: .module)
            } else {
                Text("Are you sure you want to remove this sheikh from your bookmarks?", bundle: .module)
            }
        }
    }

    // MARK: - Tab 1: About Content

    private func aboutTabContent(_ sheikh: Sheikh) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.lg) {
            // 2x2 Grid: Target, Languages, Qira'at, Experience
            SheikhDemographicsGrid(sheikh: sheikh)

            // Biography Section
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                Text("BIOGRAPHY", bundle: .module)
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
                    .fontWeight(.bold)

                Text(sheikh.biography)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .lineSpacing(4)
            }
            .padding(DSSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(dsColors.surfaceContainerLow)
            )

            // Audio Samples Horizontal Scroll Section
            if !sheikh.audioSamples.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("AUDIO SAMPLES", bundle: .module)
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.textSecondary)
                        .fontWeight(.bold)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DSSpacing.md) {
                            ForEach(sheikh.audioSamples) { sample in
                                SheikhAudioSampleCard(
                                    sample: sample,
                                    isPlaying: viewModel.playingSampleID == sample.id && viewModel.isPlayingAudio,
                                    onPlayToggle: {
                                        viewModel.toggleAudioSample(sample)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private func reviewsTabContent(_ sheikh: Sheikh) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            SheikhReviewSummaryHeader(
                rating: sheikh.rate,
                reviewCount: sheikh.reviewCount,
                hasVerifiedIjazah: sheikh.hasVerifiedIjazah
            )

            VStack(spacing: DSSpacing.smMd) {
                ForEach(sheikh.reviews) { review in
                    SheikhReviewRow(review: review)
                }
            }
        }
    }

    // MARK: - Loading & Error States

    private var loadingSkeleton: some View {
        VStack(spacing: DSSpacing.lg) {
            Spacer()
            ProgressView()
                .scaleEffect(1.3)
            Text("Loading Sheikh details...", bundle: .module)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
            Spacer()
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(dsColors.error)

            Text(message)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)

            Button(String(localized: "Try Again", bundle: .module)) {
                viewModel.refresh()
            }
            .buttonStyle(DSPrimaryButtonStyle())
            .padding(.horizontal, DSSpacing.xl)

            Spacer()
        }
    }
}
