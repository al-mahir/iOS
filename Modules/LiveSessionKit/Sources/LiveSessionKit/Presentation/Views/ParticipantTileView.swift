//
//  ParticipantTileView.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import UIKit
import Common

public struct ParticipantTileView: View {
    @Environment(\.dsColors) private var dsColors
    public let participant: SessionParticipant
    private let setupVideoCanvas: ((UIView) -> Bool)?

    public init(
        participant: SessionParticipant,
        setupVideoCanvas: ((UIView) -> Bool)? = nil
    ) {
        self.participant = participant
        self.setupVideoCanvas = setupVideoCanvas
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Group {
                if participant.isVideoEnabled, let setupVideoCanvas {
                    ParticipantVideoCanvasView(setupCanvas: setupVideoCanvas)
                        .background(dsColors.surfaceContainerLow)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md))
                } else {
                    ZStack {
                        Circle()
                            .fill(dsColors.primaryContainer)
                            .frame(width: 64, height: 64)

                        Text(initials(from: participant.name))
                            .dsFont(DSTypography.headlineMedium)
                            .foregroundColor(dsColors.primary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay(alignment: .bottomTrailing) {
                if participant.isMuted {
                    Image(systemName: "mic.slash.fill")
                        .font(.system(size: 12))
                        .padding(4)
                        .background(dsColors.error)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                        .padding(DSSpacing.xs)
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

private struct ParticipantVideoCanvasView: UIViewRepresentable {
    let setupCanvas: (UIView) -> Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        bindCanvas(to: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        bindCanvas(to: uiView)
    }

    private func bindCanvas(to view: UIView) {
        _ = setupCanvas(view)
    }
}
