//
//  HostJoinRequestsButton.swift
//  Circles
//

import Common
import SwiftUI

struct HostJoinRequestsButton: View {
    @StateObject private var viewModel: HostJoinRequestsViewModel
    @State private var isInboxPresented = false
    @Environment(\.dsColors) private var dsColors

    @MainActor
    init(
        circleID: String,
        accessTokenProvider: @escaping () -> String?
    ) {
        let repository = CircleRepository()
        _viewModel = StateObject(
            wrappedValue: HostJoinRequestsViewModel(
                circleID: circleID,
                getPendingRequestsUseCase: GetPendingRequestsUseCase(repository: repository),
                approveJoinRequestUseCase: ApproveJoinRequestUseCase(repository: repository),
                rejectJoinRequestUseCase: RejectJoinRequestUseCase(repository: repository),
                repository: repository,
                accessTokenProvider: accessTokenProvider
            )
        )
    }

    var body: some View {
        Button {
            isInboxPresented = true
            Task {
                await viewModel.refreshRequests()
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "person.badge.plus")
                    .foregroundColor(dsColors.primary)
                    .frame(width: DSSpacing.xl2, height: DSSpacing.xl2)
                    .background(dsColors.surfaceContainerLow)
                    .clipShape(Circle())

                if viewModel.pendingCount > 0 {
                    Text("\(viewModel.pendingCount)")
                        .dsFont(DSTypography.badgeText)
                        .foregroundColor(dsColors.onPrimary)
                        .padding(DSSpacing.xxs)
                        .background(dsColors.error)
                        .clipShape(Circle())
                        .offset(x: DSSpacing.xs, y: -DSSpacing.xxs)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Join requests")
        .accessibilityValue("\(viewModel.pendingCount) pending")
        .sheet(isPresented: $isInboxPresented) {
            HostJoinRequestsView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .dsTheme()
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
    }
}
