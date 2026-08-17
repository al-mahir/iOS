//
//  HostJoinRequestsView.swift
//  Circles
//

import Common
import SwiftUI

struct HostJoinRequestsView: View {
    @ObservedObject var viewModel: HostJoinRequestsViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            header

            if let message = viewModel.connectionError ?? viewModel.errorMessage {
                errorBanner(message)
            }

            content
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.md)
        .padding(.bottom, DSSpacing.lg)
        .background(dsColors.surface)
    }

    private var header: some View {
        HStack(spacing: DSSpacing.sm) {
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text("Join Requests", bundle: .module)
                    .dsFont(DSTypography.titleLarge)
                    .foregroundColor(dsColors.textPrimary)

                Text(
                    "Approve participants while your session is live.",
                    bundle: .module
                )
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            Button(action: dismiss.callAsFunction) {
                Image(systemName: "xmark")
                    .foregroundColor(dsColors.textPrimary)
                    .frame(width: DSSpacing.xl, height: DSSpacing.xl)
                    .background(dsColors.surfaceContainerLow)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                Text("Close join requests", bundle: .module)
            )
        }
    }

    private var content: some View {
        ScrollView {
            if viewModel.isLoading, viewModel.requests.isEmpty {
                ProgressView()
                    .tint(dsColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DSSpacing.xl2)
            } else if viewModel.requests.isEmpty {
                VStack(spacing: DSSpacing.sm) {
                    Image(systemName: "person.2")
                        .foregroundColor(dsColors.textSecondary)
                    Text("No pending requests", bundle: .module)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                    Text("Pull down to refresh pending requests.", bundle: .module)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.xl2)
            } else {
                LazyVStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.requests, id: \.userId) { request in
                        HostJoinRequestRow(
                            request: request,
                            isActing: viewModel.isActing(on: request),
                            onApprove: { viewModel.approve(request) },
                            onReject: { viewModel.reject(request) }
                        )
                    }
                }
                .padding(.bottom, DSSpacing.sm)
            }
        }
        .refreshable {
            await viewModel.refreshRequests()
        }
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(dsColors.error)
            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textPrimary)
            Spacer()
            Button(localizedCircleString("Retry")) {
                viewModel.retry()
            }
            .dsFont(DSTypography.labelLarge)
            .foregroundColor(dsColors.primary)
        }
        .padding(DSSpacing.sm)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.sm)
    }
}

private struct HostJoinRequestRow: View {
    let request: PendingJoinRequest
    let isActing: Bool
    let onApprove: () -> Void
    let onReject: () -> Void

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(request.username)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)

            Text("Requested to join this session", bundle: .module)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)

            HStack(spacing: DSSpacing.sm) {
                Button(localizedCircleString("Reject"), action: onReject)
                    .dsFont(DSTypography.labelLarge)
                    .foregroundColor(dsColors.error)
                    .disabled(isActing)

                Spacer()

                Button(action: onApprove) {
                    if isActing {
                        ProgressView()
                            .tint(dsColors.onPrimary)
                    } else {
                        Text("Approve", bundle: .module)
                            .dsFont(DSTypography.labelLarge)
                    }
                }
                .foregroundColor(dsColors.onPrimary)
                .padding(.horizontal, DSSpacing.md)
                .padding(.vertical, DSSpacing.sm)
                .background(dsColors.primary)
                .cornerRadius(DSRadius.sm)
                .disabled(isActing)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.md)
    }
}
