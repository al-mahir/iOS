//
//  ParticipantTileView.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import Common

public struct ParticipantTileView: View {
    @Environment(\.dsColors) private var dsColors
    public let participant: SessionParticipant

    public init(participant: SessionParticipant) {
        self.participant = participant
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer)
                    .frame(width: 64, height: 64)

                Text(initials(from: participant.name))
                    .dsFont(DSTypography.headlineMedium)
                    .foregroundColor(dsColors.primary)

                if participant.isMuted {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(systemName: "mic.slash.fill")
                                .font(.system(size: 12))
                                .padding(4)
                                .background(dsColors.error)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                    .frame(width: 64, height: 64)
                }
            }

            HStack(spacing: DSSpacing.xxs) {
                Text(participant.name ?? "User \(participant.uid)")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .lineLimit(1)

                if participant.isHost {
                    Text("(Host)")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.primary)
                }
            }

            if !participant.isFullyConnected {
                Text("Connecting...")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.warning)
            } else if participant.audioLevel > 0 {
                ProgressView(value: Double(min(participant.audioLevel, 100)), total: 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: dsColors.primary))
                    .frame(width: 60)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLow)
        .cornerRadius(DSRadius.lg)
    }

    private func initials(from name: String?) -> String {
        guard let name = name, !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return "U"
        }
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}
