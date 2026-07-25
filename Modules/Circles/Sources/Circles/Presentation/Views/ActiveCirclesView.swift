//
//  ActiveCirclesView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct ActiveCirclesView: View {
    @StateObject private var viewModel: ActiveCirclesViewModel
    @Environment(\.dsColors) private var dsColors

    @Environment(\.tabBarVisibility) private var tabBarVisibility

    public let onBack: () -> Void
    public let onNavigateToCreateCircle: () -> Void
    public let onJoinCircle: (CircleModel) -> Void

    @MainActor
    public init(
        viewModel: ActiveCirclesViewModel? = nil,
        onBack: @escaping () -> Void = {},
        onNavigateToCreateCircle: @escaping () -> Void = {},
        onJoinCircle: @escaping (CircleModel) -> Void = { _ in }
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ActiveCirclesViewModel()
        )
        self.onBack = onBack
        self.onNavigateToCreateCircle = onNavigateToCreateCircle
        self.onJoinCircle = onJoinCircle
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ActiveCirclesHeaderView(
                    title: "Active Circles",
                    onLeadingTap: onBack
                )

                VStack(spacing: DSSpacing.md) {
                    searchBar

                    FilterChipRow(
                        categories: viewModel.categories,
                        selectedCategory: $viewModel.selectedCategory
                    )
                }
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.xs)

                ScrollView {
                    LazyVStack(spacing: DSSpacing.md) {
                        if viewModel.isLoading {
                            ProgressView()
                                .padding(.top, DSSpacing.xl)
                        } else if viewModel.circles.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(viewModel.circles) { circle in
                                CircleCardView(circle: circle) {
                                    onJoinCircle(circle)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, 90)
                }
            }
            .background(dsColors.background)

            floatingActionButton
                .padding(.trailing, DSSpacing.mdLg)
                .padding(.bottom, DSSpacing.xl)
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
        .onAppear {
            tabBarVisibility.isVisible = false
            viewModel.fetchCircles()
        }
        .onDisappear {
            tabBarVisibility.isVisible = true
        }
    }

    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
                .font(.system(size: 18, weight: .medium))

            TextField(
                "Search by Surah or Sheikh...",
                text: $viewModel.searchQuery
            )
            .dsFont(DSTypography.bodyMedium)
            .foregroundColor(dsColors.textPrimary)

            if !viewModel.searchQuery.isEmpty {
                Button(action: {
                    viewModel.searchQuery = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(dsColors.textHint)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.lg)
        .padding(.horizontal, DSSpacing.md)
    }

    private var emptyStateView: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "person.3")
                .font(.system(size: 44))
                .foregroundColor(dsColors.textHint)

            Text("No active circles found")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            Text("Try searching for a different Sheikh or Surah")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
        }
        .padding(.top, DSSpacing.xl2)
    }

    private var floatingActionButton: some View {
        Button(action: onNavigateToCreateCircle) {
            ZStack {
                Circle()
                    .fill(DSGradients.primary)
                    .frame(width: 58, height: 58)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(dsColors.onPrimary)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .dsElevation(DSElevation.level3)
    }
}
