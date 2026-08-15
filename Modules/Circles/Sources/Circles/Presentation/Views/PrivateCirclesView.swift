//
//  PrivateCirclesView.swift
//  Circles
//

import Common
import LiveSessionKit
import NetworkKit
import SwiftUI
import UIKit

public struct PrivateCirclesView: View {
    @StateObject private var viewModel: PrivateCirclesViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    @State private var isNavigatingToCreateCircle = false
    @State private var selectedCircleForEdit: CircleModel?
    @State private var circlePendingDeletion: CircleModel?

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
                    getCircleUseCase: GetCircleUseCase(repository: repository),
                    startCircleUseCase: StartCircleUseCase(repository: repository),
                    getAgoraTokenUseCase: GetAgoraTokenUseCase(repository: repository),
                    cancelCircleUseCase: CancelCircleUseCase(repository: repository)
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
                    emptyMessage: "Create a private circle to manage it here.",
                    cardActions: cardActions,
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
        .overlay(alignment: .bottom) {
            if let feedback = viewModel.actionFeedback {
                feedbackBanner(feedback)
            }
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
        .navigationDestination(item: $selectedCircleForEdit) { circle in
            EditCircleView(
                circle: circle,
                onDismiss: { selectedCircleForEdit = nil },
                onCircleUpdated: { updatedCircle in
                    viewModel.replaceCircle(updatedCircle)
                    selectedCircleForEdit = nil
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
        .fullScreenCover(item: $viewModel.liveSessionDestination) { destination in
            AnyView(
                startLiveSession(
                    circleId: destination.circleId,
                    channelName: destination.agoraToken.channelName,
                    agoraToken: destination.agoraToken.token,
                    uid: destination.agoraToken.uid,
                    userAccount: destination.agoraToken.userAccount,
                    isHost: true,
                    hostToolbarContent: AnyView(
                        HostJoinRequestsButton(
                            circleID: destination.circleId,
                            accessTokenProvider: accessTokenProvider
                        )
                    ),
                    tokenRefreshProvider: viewModel.makeTokenRefreshProvider(
                        circleID: destination.circleId
                    ),
                    onLeft: {
                        viewModel.clearLiveSessionDestination()
                        viewModel.fetchCircles()
                    },
                    onSessionEnded: {
                        viewModel.clearLiveSessionDestination()
                        viewModel.fetchCircles()
                    }
                )
            )
        }
        .confirmationDialog(
            "Delete Circle?",
            isPresented: Binding(
                get: { circlePendingDeletion != nil },
                set: { if !$0 { circlePendingDeletion = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let circle = circlePendingDeletion {
                Button("Delete Circle", role: .destructive) {
                    circlePendingDeletion = nil
                    viewModel.delete(circle: circle)
                }
            }
            Button("Cancel", role: .cancel) {
                circlePendingDeletion = nil
            }
        } message: {
            Text("This scheduled circle will be deleted and cannot be restored.")
        }
        .onAppear {
            tabBarVisibility.isVisible = false
            viewModel.fetchCircles()
        }
        .onDisappear {
            if !isNavigatingToCreateCircle && selectedCircleForEdit == nil
                && viewModel.pendingPrivateJoin == nil
                && viewModel.liveSessionDestination == nil {
                tabBarVisibility.isVisible = true
            }
        }
        .onChange(of: viewModel.actionFeedback) { feedback in
            guard feedback != nil else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                viewModel.clearActionFeedback()
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

    private func cardActions(for circle: CircleModel) -> CircleCardActions? {
        CircleCardActions(
            primaryTitle: circle.canStart ? "Start Session" : nil,
            isPrimaryLoading: viewModel.startingCircleID == circle.id,
            onPrimaryTap: circle.canStart ? { viewModel.start(circle: circle) } : nil,
            onEditTap: circle.canUpdate ? { selectedCircleForEdit = circle } : nil,
            onCopyTokenTap: hasInviteToken(circle)
                ? { copyToken(for: circle) }
                : nil,
            showsCopyToken: true,
            onDeleteTap: circle.canCancel ? { circlePendingDeletion = circle } : nil,
            isDeleting: viewModel.deletingCircleID == circle.id
        )
    }

    private func copyToken(for circle: CircleModel) {
        guard let token = circle.inviteToken?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !token.isEmpty else {
            return
        }

        UIPasteboard.general.string = token
        viewModel.showSuccessFeedback("Token copied")
    }

    private func hasInviteToken(_ circle: CircleModel) -> Bool {
        !(circle.inviteToken?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
    }

    private func feedbackBanner(_ feedback: CircleActionFeedback) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: feedbackIcon(for: feedback))
                .foregroundColor(feedbackColor(for: feedback))
            Text(feedback.message)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
            Spacer()
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerHigh)
        .cornerRadius(DSRadius.lg)
        .dsElevation(DSElevation.level2)
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, DSSpacing.md)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    private func feedbackIcon(for feedback: CircleActionFeedback) -> String {
        switch feedback {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }

    private func feedbackColor(for feedback: CircleActionFeedback) -> Color {
        switch feedback {
        case .success:
            return dsColors.success
        case .error:
            return dsColors.error
        }
    }
}
