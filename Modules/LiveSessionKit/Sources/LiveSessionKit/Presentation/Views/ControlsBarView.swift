//
//  ControlsBarView.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import Common

public struct ControlsBarView: View {
    @Environment(\.dsColors) private var dsColors
    public let isMuted: Bool
    public let isVideoEnabled: Bool
    public let isHost: Bool
    public let onToggleMute: () -> Void
    public let onToggleVideo: () -> Void
    public let onLeave: () -> Void
    public let onEndSession: () -> Void

    public init(
        isMuted: Bool,
        isVideoEnabled: Bool,
        isHost: Bool,
        onToggleMute: @escaping () -> Void,
        onToggleVideo: @escaping () -> Void,
        onLeave: @escaping () -> Void,
        onEndSession: @escaping () -> Void
    ) {
        self.isMuted = isMuted
        self.isVideoEnabled = isVideoEnabled
        self.isHost = isHost
        self.onToggleMute = onToggleMute
        self.onToggleVideo = onToggleVideo
        self.onLeave = onLeave
        self.onEndSession = onEndSession
    }

    public var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Mute Button
            Button(action: onToggleMute) {
                Image(systemName: isMuted ? "mic.slash.fill" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isMuted ? .white : dsColors.onPrimary)
                    .frame(width: 50, height: 50)
                    .background(isMuted ? dsColors.error : dsColors.primary)
                    .clipShape(Circle())
            }

            // Video Button
            Button(action: onToggleVideo) {
                Image(systemName: isVideoEnabled ? "video.fill" : "video.slash.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isVideoEnabled ? dsColors.onPrimary : dsColors.textSecondary)
                    .frame(width: 50, height: 50)
                    .background(isVideoEnabled ? dsColors.primary : dsColors.surfaceContainerLow)
                    .clipShape(Circle())
            }

            Spacer()

            // Leave Button
            Button(action: onLeave) {
                Image(systemName: "phone.down.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(dsColors.error)
                    .clipShape(Circle())
            }

            // End Session Button (Host Only)
            if isHost {
                Button(action: onEndSession) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 56, height: 56)
                        .background(.red)
                        .clipShape(Circle())
                }
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surface)
        .cornerRadius(DSRadius.xl)
        .dsElevation(DSElevation.level2)
    }
}
