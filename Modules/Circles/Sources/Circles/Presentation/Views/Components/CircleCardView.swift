//
//  CircleCardView.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Common
import SwiftUI

public struct CircleCardView: View {
    @Environment(\.dsColors) private var dsColors
    public let circle: CircleModel
    public let onJoinTap: () -> Void

    public init(circle: CircleModel, onJoinTap: @escaping () -> Void) {
        self.circle = circle
        self.onJoinTap = onJoinTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            HStack {
                statusBadge

                Spacer()

                if circle.status == .ongoing {
                    liveBadge
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

            // Join button
            HStack {
                Spacer()

                Button(action: onJoinTap) {
                    Text("Join")
                        .dsFont(DSTypography.buttonText)
                        .foregroundColor(circle.isFull ? dsColors.textDisabled : dsColors.onPrimary)
                        .padding(.horizontal, DSSpacing.lg)
                        .padding(.vertical, DSSpacing.sm)
                        .background(circle.isFull ? dsColors.surfaceContainerLow : dsColors.primary)
                        .cornerRadius(DSRadius.sm)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(circle.isFull)
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
            Text("LIVE")
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

    // MARK: - Helpers

    private var participantCountText: String {
        "\(circle.memberCount)/\(circle.maxParticipants) participants"
    }

    private var statusLabel: String {
        switch circle.status {
        case .scheduled: return "Scheduled"
        case .ongoing:   return "Live"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
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
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
