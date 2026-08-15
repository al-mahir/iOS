//
//  SwiftUIView.swift
//  Circles
//
//  Created by Nadin Ahmed on 15/08/2026.
//

import Common
import SwiftUI

public struct PrivateCirclesView: View {
    @StateObject private var viewModel: PrivateCirclesViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    @State private var isNavigatingToCreateCircle = false

    public let onBack: () -> Void
    public let onNavigateToCreateCircle: () -> Void

    @MainActor
    public init(
        viewModel: PrivateCirclesViewModel? = nil,
        onBack: @escaping () -> Void = {},
        onNavigateToCreateCircle: @escaping () -> Void = {}
    ) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(
                wrappedValue: PrivateCirclesViewModel(
                    listCirclesUseCase: ListCirclesUseCase(
                        repository: CircleRepository()
                    ),
                    getMyCirclesUseCase: GetMyCirclesUseCase(
                        repository: CircleRepository()
                    )
                )
            )
        }
        self.onBack = onBack
        self.onNavigateToCreateCircle = onNavigateToCreateCircle
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
                .padding(.bottom, DSSpacing.xs)
                .background(dsColors.background)

            Spacer()
        }
        .overlay(alignment: .bottomTrailing) {
            floatingActionButton
                .padding(.trailing, DSSpacing.mdLg)
                .padding(.bottom, DSSpacing.xl)
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
            if !isNavigatingToCreateCircle {
                tabBarVisibility.isVisible = true
            }
        }
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
