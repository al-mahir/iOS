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

    @State private var isNavigatingToCreateCircle = false
    @State private var selectedPublicCircle: CircleModel? = nil

    public let onBack: () -> Void
    public let onNavigateToCreateCircle: () -> Void

    @MainActor
    public init(
        viewModel: ActiveCirclesViewModel? = nil,
        onBack: @escaping () -> Void = {},
        onNavigateToCreateCircle: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? ActiveCirclesViewModel(
                listCirclesUseCase: ListCirclesUseCase(repository: CircleRepository()),
                getMyCirclesUseCase: GetMyCirclesUseCase(repository: CircleRepository())
            )
        )
        self.onBack = onBack
        self.onNavigateToCreateCircle = onNavigateToCreateCircle
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ActiveCirclesHeaderView(
                    title: "Active Circles",
                    onLeadingTap: onBack
                )

                VStack(spacing: DSSpacing.md) {
                    PrivateCodeBanner(viewModel: viewModel)
                        .padding(.horizontal, DSSpacing.md)

                    searchBar

                    statusFilterRow
                }
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.xs)

                ScrollView {
                    LazyVStack(spacing: DSSpacing.md) {
                        if viewModel.isLoading && viewModel.circles.isEmpty {
                            ProgressView()
                                .padding(.top, DSSpacing.xl)
                        } else if viewModel.circles.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(viewModel.circles) { circle in
                                CircleCardView(circle: circle) {
                                    selectedPublicCircle = circle
                                }
                                .onAppear {
                                    if circle.id == viewModel.circles.last?.id {
                                        viewModel.loadMore()
                                    }
                                }
                            }

                            if viewModel.isLoading {
                                ProgressView()
                                    .padding(.vertical, DSSpacing.md)
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
        // Navigate to JoinCircleView for a public circle (no membership yet)
        .navigationDestination(item: $selectedPublicCircle) { circle in
            JoinCircleView(
                circle: circle,
                restoreTabBarOnDisappear: false,
                onDismiss: {
                    selectedPublicCircle = nil
                    viewModel.fetchCircles()
                }
            )
            .dsTheme()
        }
        // Navigate to JoinCircleView for a private circle (membership pre-obtained)
        .navigationDestination(item: $viewModel.pendingPrivateJoin) { result in
            JoinCircleView(
                circle: result.circle,
                pendingMembership: result.membership,
                restoreTabBarOnDisappear: false,
                onDismiss: {
                    viewModel.clearPrivateJoin()
                    viewModel.fetchCircles()
                }
            )
            .dsTheme()
        }
        .navigationDestination(isPresented: $isNavigatingToCreateCircle) {
            CreateCircleView(
                onDismiss: { isNavigatingToCreateCircle = false },
                onCircleCreated: { _ in
                    isNavigatingToCreateCircle = false
                    viewModel.fetchCircles()
                }
            )
            .dsTheme()
        }
        .onAppear {
            tabBarVisibility.isVisible = false
            viewModel.fetchCircles()
        }
        .onDisappear {
            if !isNavigatingToCreateCircle {
                tabBarVisibility.isVisible = true
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
                .font(.system(size: 18, weight: .medium))

            TextField(
                "Search circles...",
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

    // MARK: - Status Filter Row

    private var statusFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DSSpacing.sm) {
                ForEach(viewModel.filterOptions, id: \.1) { (status, label) in
                    let isSelected = viewModel.selectedStatus == status
                    Button(action: {
                        viewModel.selectedStatus = status
                    }) {
                        Text(label)
                            .dsFont(DSTypography.labelMedium)
                            .foregroundColor(
                                isSelected ? dsColors.onPrimary : dsColors.textPrimary
                            )
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.xs)
                            .background(
                                isSelected ? dsColors.primary : dsColors.surfaceContainerLow
                            )
                            .cornerRadius(DSRadius.full)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, DSSpacing.md)
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "person.3")
                .font(.system(size: 44))
                .foregroundColor(dsColors.textHint)

            Text("No circles found")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            Text("Try a different filter or create your own circle")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DSSpacing.xl2)
    }

    // MARK: - Floating Action Button

    private var floatingActionButton: some View {
        Button(action: {
            onNavigateToCreateCircle()
            isNavigatingToCreateCircle = true
        }) {
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
