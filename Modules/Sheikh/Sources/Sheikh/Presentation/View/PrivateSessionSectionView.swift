//
//  PrivateSessionSectionView.swift
//  Sheikh
//

import SwiftUI
import Common
import LiveSessionKit

public struct PrivateSessionSectionView: View {

    // MARK: - Properties

    private let sheikhID: String
    private let sheikhName: String
    private let sheikhAvatarURL: String?
    private let initialStatus: SheikhAvailabilityStatus

    @StateObject private var viewModel: PrivateSessionViewModel
    @Environment(\.dsColors) private var dsColors

    @State private var isShowingWaiting: Bool = false
    @State private var liveSessionDestination: LiveSessionDestination? = nil

    // MARK: - Init

    @MainActor
    public init(
        sheikhID: String,
        sheikhName: String,
        sheikhAvatarURL: String?,
        initialStatus: SheikhAvailabilityStatus
    ) {
        self.sheikhID = sheikhID
        self.sheikhName = sheikhName
        self.sheikhAvatarURL = sheikhAvatarURL
        self.initialStatus = initialStatus
        _viewModel = StateObject(
            wrappedValue: SheikhDIContainer.shared.makePrivateSessionViewModel(
                sheikhID: sheikhID,
                initialStatus: initialStatus
            )
        )
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            switch viewModel.sessionState {
            case .idle:
                idleSection
            case .requesting:
                requestingSection
            case .waitingForApproval, .approved, .declined, .cancelled, .expired:
                idleSection
                    .disabled(true)
                    .opacity(0.4)
            }
        }
        // Waiting for approval — driven by a real @State var (NOT a computed Binding).
        .fullScreenCover(isPresented: $isShowingWaiting) {
            WaitingForApprovalView(
                sheikhName: sheikhName,
                sheikhAvatarURL: sheikhAvatarURL,
                onCancel: {
                    // Dismiss the overlay first, then cancel on the VM.
                    isShowingWaiting = false
                    viewModel.cancelRequest()
                }
            )
            .environment(\.dsColors, dsColors)
        }
        // Live session cover.
        .fullScreenCover(item: $liveSessionDestination) { dest in
            AnyView(
                startLiveSession(
                    circleId: dest.requestId,
                    channelName: dest.channelName,
                    agoraToken: dest.agoraToken,
                    uid: dest.uid,
                    userAccount: dest.userAccount,
                    isHost: false,
                    onLeft: {
                        liveSessionDestination = nil
                        viewModel.resetToIdle()
                    },
                    onSessionEnded: {
                        liveSessionDestination = nil
                        viewModel.resetToIdle()
                    }
                )
            )
        }
        // Bottom feedback toasts.
        .overlay(alignment: .bottom) {
            feedbackToast
        }
        // Single onChange drives ALL state transitions.
        .onChange(of: viewModel.sessionState) { _, newState in
            switch newState {
            case .waitingForApproval:
                isShowingWaiting = true

            case .approved(let requestId, let channel, let token, let userAccount):
                // Dismiss waiting screen first, then open the live session.
                isShowingWaiting = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    liveSessionDestination = LiveSessionDestination(
                        requestId: requestId,
                        channelName: channel,
                        agoraToken: token,
                        uid: 0,
                        userAccount: userAccount
                    )
                }

            case .declined, .cancelled, .expired:
                isShowingWaiting = false

            case .idle, .requesting:
                break
            }
        }
        .onAppear {
            viewModel.loadAvailability()
        }
    }

    // MARK: - Idle Section

    @ViewBuilder
    private var idleSection: some View {

        let effectiveStatus = viewModel.availability?.status ?? initialStatus

        if viewModel.isLoadingAvailability && viewModel.availability == nil {
            availabilityLoadingView
        } else if effectiveStatus == .available {
            requestSessionButton
        } else {
            unavailableBanner
        }
    }

    // MARK: - Request Session Button

    private var requestSessionButton: some View {
            // Primary CTA button
            Button(action: { viewModel.requestSession() }) {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "video.fill")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Request Private Session", bundle: .module)
                        .dsFont(DSTypography.buttonText)
                }
                .foregroundColor(dsColors.onPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.smMd)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(DSGradients.primary)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.horizontal, DSSpacing.mdLg)
            .padding(.vertical, DSSpacing.md)
    }

    // MARK: - Requesting Spinner

    private var requestingSection: some View {
        HStack(spacing: DSSpacing.sm) {
            ProgressView()
                .tint(dsColors.primary)
            Text("Sending request…", bundle: .module)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.smMd)
        .transition(.opacity)
    }

    // MARK: - Unavailable Banner

    private var unavailableBanner: some View {
        HStack(spacing: DSSpacing.smMd) {
            Image(systemName: "moon.zzz.fill")
                .foregroundColor(dsColors.textHint)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                Text("Sheikh is Unavailable", bundle: .module)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
                Text("Private sessions are not available right now", bundle: .module)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textHint)
            }
            Spacer()
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
                .overlay(
                    RoundedRectangle(cornerRadius: DSRadius.lg)
                        .stroke(dsColors.outlineVariant, lineWidth: 1)
                )
        )
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.smMd)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: - Availability Loading Shimmer

    private var availabilityLoadingView: some View {
        RoundedRectangle(cornerRadius: DSRadius.md)
            .fill(dsColors.surfaceContainerLow)
            .frame(height: 48)
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.smMd)
            .redacted(reason: .placeholder)
    }

    // MARK: - Feedback Toast

    @ViewBuilder
    private var feedbackToast: some View {
        switch viewModel.sessionState {
        case .declined(let reason):
            toastBanner(
                icon: "xmark.circle.fill",
                color: dsColors.error,
                message: reason ?? String(localized: "The Sheikh has declined your request.", bundle: .module)
            )
        case .expired:
            toastBanner(
                icon: "clock.badge.xmark.fill",
                color: dsColors.warning,
                message: String(localized: "Your request has expired. Please try again.", bundle: .module)
            )
        case .cancelled:
            toastBanner(
                icon: "checkmark.circle.fill",
                color: dsColors.success,
                message: String(localized: "Request cancelled.", bundle: .module)
            )
        default:
            EmptyView()
        }
    }

    private func toastBanner(icon: String, color: Color, message: String) -> some View {
        HStack(spacing: DSSpacing.smMd) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
            Text(message)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
            Spacer()
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerHigh)
                .shadow(color: dsColors.shadow.opacity(0.15), radius: 8, y: 4)
        )
        .padding(.horizontal, DSSpacing.md)
        .padding(.bottom, DSSpacing.md)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .animation(.easeInOut(duration: 0.25), value: viewModel.sessionState)
    }

}

// MARK: - Live Session Destination (Identifiable for .fullScreenCover)

private struct LiveSessionDestination: Identifiable {
    let id = UUID()
    let requestId: String
    let channelName: String
    let agoraToken: String
    let uid: Int
    let userAccount: String?
}

// MARK: - Scale Button Style (private to this file)

private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.88 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
