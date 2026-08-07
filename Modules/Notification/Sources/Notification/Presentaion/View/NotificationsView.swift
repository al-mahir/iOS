//
//  NotificationsView.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import SwiftUI
import Common

public struct NotificationsView: View {
    @StateObject private var viewModel: NotificationService
    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    @MainActor
    public init(viewModel: NotificationService? = nil) {
        _viewModel = StateObject(
            wrappedValue: viewModel ?? NotificationDIContainer.shared.resolve(NotificationService.self)
        )
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Notifications")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if viewModel.unreadCount > 0 {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Mark all read") { viewModel.markAllAsRead() }
                                .dsFont(DSTypography.labelLarge)
                                .foregroundColor(dsColors.primary)
                        }
                    }
                }
                .onAppear {
                           tabBarVisibility.isVisible = false
               }
               .onDisappear {
                   tabBarVisibility.isVisible = true
               }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.currentUserId == nil {
            emptyState(title: "Sign in to see your notifications", systemImage: "bell.slash")
        } else if viewModel.isLoading && viewModel.notifications.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(dsColors.background)
        } else if viewModel.notifications.isEmpty {
            emptyState(title: "You're all caught up", systemImage: "bell")
        } else {
            ScrollView {
                LazyVStack(spacing: DSSpacing.sm) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRow(notification: notification)
                            .contentShape(Rectangle())
                            .onTapGesture { viewModel.markAsRead(notification) }
                            .swipeActions {
                                Button(role: .destructive) {
                                    viewModel.delete(notification)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(DSSpacing.md)
            }
            .background(dsColors.background)
        }
    }

    private func emptyState(title: String, systemImage: String) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
                .foregroundColor(dsColors.textTertiary)
            Text(title)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(dsColors.background)
    }
}

private struct NotificationRow: View {
    @Environment(\.dsColors) private var dsColors
    let notification: Notification

    var body: some View {
        HStack(alignment: .top, spacing: DSSpacing.smMd) {
            Image(systemName: iconName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(dsColors.onPrimary)
                .frame(width: 36, height: 36)
                .background(Circle().fill(iconColor))

            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text(notification.title)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                Text(notification.body)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
                    .lineLimit(2)
            }

            Spacer(minLength: DSSpacing.sm)

            if !notification.isRead {
                Circle()
                    .fill(dsColors.primary)
                    .frame(width: 8, height: 8)
                    .padding(.top, DSSpacing.xxs)
            }
        }
        .padding(DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(notification.isRead ? dsColors.surfaceContainerLow : dsColors.primaryContainer.opacity(0.4))
        )
    }

    private var iconName: String {
        switch notification.type {
        case .message: return "message.fill"
        case .reminder: return "bell.fill"
        case .update: return "arrow.triangle.2.circlepath"
        case .alert: return "exclamationmark.triangle.fill"
        case .achievement: return "star.fill"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case .message: return dsColors.info
        case .reminder: return dsColors.secondary
        case .update: return dsColors.primary
        case .alert: return dsColors.error
        case .achievement: return dsColors.warning
        }
    }
}
