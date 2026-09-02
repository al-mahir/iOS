//
//  CircleCardView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct CircleCardActions {
    public let primaryTitle: String?
    public let isPrimaryLoading: Bool
    public let onPrimaryTap: (() -> Void)?
    public let onEditTap: (() -> Void)?
    public let onCopyTokenTap: (() -> Void)?
    public let showsCopyToken: Bool
    public let onDeleteTap: (() -> Void)?
    public let isDeleting: Bool

    public init(
        primaryTitle: String? = nil,
        isPrimaryLoading: Bool = false,
        onPrimaryTap: (() -> Void)? = nil,
        onEditTap: (() -> Void)? = nil,
        onCopyTokenTap: (() -> Void)? = nil,
        showsCopyToken: Bool = false,
        onDeleteTap: (() -> Void)? = nil,
        isDeleting: Bool = false
    ) {
        self.primaryTitle = primaryTitle
        self.isPrimaryLoading = isPrimaryLoading
        self.onPrimaryTap = onPrimaryTap
        self.onEditTap = onEditTap
        self.onCopyTokenTap = onCopyTokenTap
        self.showsCopyToken = showsCopyToken
        self.onDeleteTap = onDeleteTap
        self.isDeleting = isDeleting
    }

    var hasMenuActions: Bool {
        onEditTap != nil || showsCopyToken || onDeleteTap != nil
    }
}

public struct CircleCardView: View {
    @Environment(\.dsColors) private var dsColors
    public let circle: CircleModel
    public let onJoinTap: (() -> Void)?
    public let actions: CircleCardActions?

    public init(
        circle: CircleModel,
        onJoinTap: (() -> Void)? = nil,
        actions: CircleCardActions? = nil
    ) {
        self.circle = circle
        self.onJoinTap = onJoinTap
        self.actions = actions
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                statusBadge

                Spacer()

                if circle.status == .ongoing {
                    liveBadge
                }

                if actions?.hasMenuActions == true {
                    actionsMenu
                }
            }.padding(.bottom, DSSpacing.sm)

            // Circle identity
            HStack(alignment: .top, spacing: DSSpacing.sm) {
                circleIcon

                VStack(alignment: .leading) {
                    Text(circle.name)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                        .padding(.bottom, DSSpacing.sm)

                    HStack(spacing: DSSpacing.xs) {
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                            .foregroundColor(dsColors.textHint)
                            .padding(.bottom, DSSpacing.xs)

                        Text(formattedDate(circle.startDate))
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textHint)
                    }
                    
                    Text(participantCountText)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(circle.isFull ? dsColors.error : dsColors.textHint)
                }

                Spacer()
            }

            if let onJoinTap {
                actionButton(
                    title: localizedCircleString("Join"),
                    isLoading: false,
                    action: onJoinTap
                )
                    .disabled(circle.isFull)
            } else if let actions, let primaryTitle = actions.primaryTitle,
                      let onPrimaryTap = actions.onPrimaryTap {
                actionButton(
                    title: primaryTitle,
                    isLoading: actions.isPrimaryLoading,
                    action: onPrimaryTap
                )
                .disabled(actions.isPrimaryLoading)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.md)
        .dsElevation(DSElevation.level1)
    }

    // MARK: - Sub-views

    private var liveBadge: some View {
        HStack(spacing: 4) {
            Text("LIVE", bundle: .module)
                .dsFont(DSTypography.badgeText)
                .foregroundColor(Color.red)
            Circle()
                .fill(Color.red)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xxs)
        .background(Color.red.opacity(0.12))
        .cornerRadius(DSRadius.full)
    }

    private var statusBadge: some View {
        Text(statusLabel)
            .dsFont(DSTypography.badgeText)
            .foregroundColor(statusTextColor)
            .padding(.horizontal, DSSpacing.sm)
            .padding(.vertical, DSSpacing.xxs)
            .background(statusTextColor.opacity(0.12))
            .cornerRadius(DSRadius.full)
    }

    private var circleIcon: some View {
        ZStack {
            Circle()
                .fill(dsColors.primaryContainer)
                .frame(width: 40, height: 40)

            Image(systemName: "person.3.sequence.fill")
                .font(.system(size: 14))
                .foregroundColor(dsColors.primary)
        }
    }

    private var actionsMenu: some View {
        Menu {
            if let onEditTap = actions?.onEditTap {
                Button(action: onEditTap) {
                    Label {
                        Text("Edit Circle", bundle: .module)
                    } icon: {
                        Image(systemName: "pencil")
                    }
                }
            }

            if actions?.showsCopyToken == true {
                Button(action: { actions?.onCopyTokenTap?() }) {
                    Label {
                        Text("Copy Token", bundle: .module)
                    } icon: {
                        Image(systemName: "doc.on.doc")
                    }
                }
                .disabled(actions?.onCopyTokenTap == nil)
            }

            if let onDeleteTap = actions?.onDeleteTap {
                Button(role: .destructive, action: onDeleteTap) {
                    Label {
                        Text(
                            actions?.isDeleting == true
                                ? localizedCircleString("Deleting…")
                                : localizedCircleString("Delete Circle")
                        )
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                .disabled(actions?.isDeleting == true)
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(dsColors.textSecondary)
                .frame(width: 32, height: 32)
                .background(dsColors.surfaceContainerLow)
                .clipShape(Circle())
        }
    }

    private func actionButton(
        title: String,
        isLoading: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            Spacer()

            Button(action: action) {
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(
                                CircularProgressViewStyle(tint: dsColors.onPrimary)
                            )
                    } else {
                        Text(title)
                            .dsFont(DSTypography.buttonText)
                    }
                }
                .foregroundColor(circle.isFull ? dsColors.textDisabled : dsColors.onPrimary)
                .padding(.horizontal, DSSpacing.lg)
                .padding(.vertical, DSSpacing.sm)
                .background(circle.isFull ? dsColors.surfaceContainerLow : dsColors.primary)
                .cornerRadius(DSRadius.sm)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(circle.isFull || isLoading)
        }
    }

    // MARK: - Helpers

    private var participantCountText: String {
        localizedCircleString(
            "%lld/%lld participants",
            circle.memberCount,
            circle.maxParticipants
        )
    }

    private var statusLabel: String {
        switch circle.status {
        case .scheduled: return localizedCircleString("Scheduled")
        case .ongoing:   return localizedCircleString("Live")
        case .completed: return localizedCircleString("Completed")
        case .cancelled: return localizedCircleString("Cancelled")
        }
    }

    private var statusTextColor: Color {
        switch circle.status {
        case .scheduled: return dsColors.info
        case .ongoing:   return dsColors.success
        case .completed: return dsColors.textHint
        case .cancelled: return dsColors.error
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = LanguageManager.shared.currentLanguage.locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
