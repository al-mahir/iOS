//
//  PrivateCirclesView.swift
//  Circles
//

import Common
import NetworkKit
import SwiftUI

public struct PrivateCirclesView: View {
    @StateObject private var viewModel: PrivateCirclesViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    @State private var isNavigatingToCreateCircle = false

    public let onBack: () -> Void
    public let onNavigateToCreateCircle: () -> Void
    public let accessTokenProvider: () -> String?

    @MainActor
    public init(
        viewModel: PrivateCirclesViewModel? = nil,
        onBack: @escaping () -> Void = {},
        onNavigateToCreateCircle: @escaping () -> Void = {},
        accessTokenProvider: @escaping () -> String? = {
            AppRequestInterceptors.shared.tokenProvider?()
        }
    ) {
        if let viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            let repository = CircleRepository()
            _viewModel = StateObject(
                wrappedValue: PrivateCirclesViewModel(
                    getPrivateCirclesUseCase: GetPrivateCirclesUseCase(repository: repository),
                    joinPrivateCircleUseCase: JoinPrivateCircleUseCase(repository: repository),
                    getCircleUseCase: GetCircleUseCase(repository: repository)
                )
            )
        }
        self.onBack = onBack
        self.onNavigateToCreateCircle = onNavigateToCreateCircle
        self.accessTokenProvider = accessTokenProvider
    }

    public var body: some View {
        VStack(spacing: 0) {
            ActiveCirclesHeaderView(
                title: "Private Circles",
                onLeadingTap: onBack
            )

            PrivateCodeBanner(viewModel: viewModel)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)
                .padding(.bottom, DSSpacing.md)

            CircleSearchField(query: $viewModel.searchQuery)
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.xs)

            ScrollView {
                CirclesListContent(
                    circles: viewModel.circles,
                    isLoading: viewModel.isLoading,
                    errorMessage: viewModel.errorMessage,
                    emptyMessage: "Join a private circle with an invite token to see it here.",
                    onRetry: viewModel.fetchCircles
                )
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.xs)
                .padding(.bottom, DSSpacing.xl2 + DSSpacing.xl2 + DSSpacing.smMd)
            }
        }
        .background(dsColors.background)
        .overlay(alignment: .bottomTrailing) {
            floatingActionButton
                .padding(.trailing, DSSpacing.mdLg)
                .padding(.bottom, DSSpacing.xl)
        }
        .fullScreenCover(item: $viewModel.pendingPrivateJoin) { result in
            JoinCircleView(
                circle: result.circle,
                pendingMembership: result.membership,
                accessTokenProvider: accessTokenProvider,
                restoreTabBarOnDisappear: false,
                onDismiss: {
                    viewModel.clearPrivateJoin()
                    viewModel.fetchCircles()
                }
            )
            .dsTheme()
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
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
            if !isNavigatingToCreateCircle && viewModel.pendingPrivateJoin == nil {
                tabBarVisibility.isVisible = true
            }
        }
    }

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
