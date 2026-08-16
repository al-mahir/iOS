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

    @State private var selectedPublicCircle: CircleModel? = nil

    public let onBack: () -> Void

    @MainActor
    public init(
        viewModel: ActiveCirclesViewModel? = nil,
        onBack: @escaping () -> Void = {},
    ) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(
                wrappedValue: ActiveCirclesViewModel(
                    listCirclesUseCase: ListCirclesUseCase(repository: CircleRepository())
                )
            )
        }
        self.onBack = onBack
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ActiveCirclesHeaderView(
                    title: "Active Circles",
                    onLeadingTap: onBack
                )

                VStack(spacing: DSSpacing.md) {
                    CircleSearchField(query: $viewModel.searchQuery)
                        .padding(.horizontal, DSSpacing.md)
                    statusFilterRow
                }
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.xs)

                ScrollView {
                    CirclesListContent(
                        circles: viewModel.circles,
                        isLoading: viewModel.isLoading,
                        errorMessage: viewModel.errorMessage,
                        emptyMessage: "Try a different filter or create your own circle",
                        onCircleAction: { selectedPublicCircle = $0 },
                        onLastCircleAppear: { _ in viewModel.loadMore() },
                        onRetry: viewModel.fetchCircles
                    )
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, DSSpacing.xl2 + DSSpacing.xl2 + DSSpacing.smMd)
                }
            }
            .background(dsColors.background)
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
        .onAppear {
            tabBarVisibility.isVisible = false
            viewModel.fetchCircles()
        }
        .onDisappear {
            let navigatingToJoin = selectedPublicCircle != nil
            if !navigatingToJoin {
                tabBarVisibility.isVisible = true
            }
        }
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

}
