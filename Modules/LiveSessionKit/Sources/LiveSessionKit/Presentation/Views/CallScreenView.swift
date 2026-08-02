//
//  CallScreenView.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import SwiftUI
import Common
import AgoraKit

public struct CallScreenView: View {
    @StateObject private var viewModel: CallScreenViewModel
    @Environment(\.dsColors) private var dsColors

    public init(viewModel: CallScreenViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            dsColors.background.ignoresSafeArea()

            VStack(spacing: DSSpacing.md) {
                // Top Navigation Bar / Header
                HStack {
                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(viewModel.channelName)
                            .dsFont(DSTypography.headlineSmall)
                            .foregroundColor(dsColors.textPrimary)

                        HStack(spacing: DSSpacing.xs) {
                            Circle()
                                .fill(viewModel.connectionState == .connected ? dsColors.success : dsColors.warning)
                                .frame(width: 8, height: 8)

                            Text("\(viewModel.participants.count) Participants")
                                .dsFont(DSTypography.labelMedium)
                                .foregroundColor(dsColors.textSecondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.sm)

                // Connection State Overlay Banner
                if viewModel.connectionState == .reconnecting {
                    HStack {
                        ProgressView()
                            .tint(dsColors.onPrimary)
                        Text("Reconnecting to session...")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.onPrimary)
                    }
                    .padding(DSSpacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(dsColors.warning)
                    .transition(.opacity)
                }

                // Session Ended Notice Banner
                if let notice = viewModel.sessionEndedNotice {
                    Text(notice)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundColor(.white)
                        .padding(DSSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(dsColors.error)
                        .cornerRadius(DSRadius.md)
                        .padding(.horizontal, DSSpacing.md)
                }

                // Grid of Participants
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 140), spacing: DSSpacing.md)],
                        spacing: DSSpacing.md
                    ) {
                        ForEach(viewModel.participants) { participant in
                            ParticipantTileView(participant: participant)
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                }

                Spacer()

                // Controls Bar
                ControlsBarView(
                    isMuted: viewModel.isMuted,
                    isVideoEnabled: viewModel.isVideoEnabled,
                    isHost: viewModel.isHost,
                    onToggleMute: { viewModel.toggleMute() },
                    onToggleVideo: { viewModel.toggleVideo() },
                    onLeave: { viewModel.leaveSession() },
                    onEndSession: { viewModel.endSession() }
                )
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.md)
            }

            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.4).ignoresSafeArea()
                    ProgressView("Processing...")
                        .padding(DSSpacing.lg)
                        .background(dsColors.surface)
                        .cornerRadius(DSRadius.lg)
                }
            }
        }
        .dsTheme()
        .onAppear {
            viewModel.joinSession()
        }
        .alert(isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage ?? "An unexpected error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
