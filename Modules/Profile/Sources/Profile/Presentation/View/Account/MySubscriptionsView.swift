//
//  MySubscriptionsView.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//

import SwiftUI
import Common

public struct MySubscriptionsView: View {
    @StateObject private var viewModel: MySubscriptionsViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss
    @State private var showPastPackages = false

    @MainActor
    public init(viewModel: MySubscriptionsViewModel = MySubscriptionsViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            headerBanner(title: "My Subscriptions")
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.lg) {
                    if viewModel.isLoading {
                        ProgressView {
                            Text("Loading your packages…", bundle: .module)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, DSSpacing.xl2)
                    } else if let errorMessage = viewModel.errorMessage {
                        errorState(errorMessage)
                    } else if viewModel.subscriptions.isEmpty {
                        emptyState
                    } else {
                        activeSection
                        pastSection
                    }
                }
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, 100)
            }
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .ignoresSafeArea()
        
        .dsTheme()
        .task {
            await viewModel.loadSubscriptions()
        }
        .alert(
            String(localized: "Cancel subscription?", bundle: .module),
            isPresented: Binding(
                get: { viewModel.pendingCancelSubscription != nil },
                set: { if !$0 { viewModel.pendingCancelSubscription = nil } }
            ),
            actions: {
                Button(String(localized: "Keep it", bundle: .module), role: .cancel) {
                    viewModel.pendingCancelSubscription = nil
                }
                Button(String(localized: "Cancel subscription", bundle: .module), role: .destructive) {
                    Task { await viewModel.confirmCancel() }
                }
            },
            message: {
                if let sub = viewModel.pendingCancelSubscription {
                    Text("You'll lose access to the remaining \(sub.sessionsRemaining) session(s) in \"\(sub.packageName)\" with \(sub.sheikhName). This can't be undone.", bundle: .module)
                }
            }
        )
    }

    // MARK: - Sections

    private var activeSection: some View {
        Group {
            if !viewModel.activeSubscriptions.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Text("Active packages", bundle: .module)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)

                    ForEach(viewModel.activeSubscriptions) { subscription in
                        SubscriptionPackageCard(subscription: subscription) {
                            viewModel.requestCancel(subscription)
                        }
                    }
                }
            }
        }
    }

    private var pastSection: some View {
        Group {
            if !viewModel.pastSubscriptions.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.sm) {
                    Button(action: { withAnimation { showPastPackages.toggle() } }) {
                        HStack {
                            Text("Past packages (\(viewModel.pastSubscriptions.count))", bundle: .module)
                                .dsFont(DSTypography.titleMedium)
                                .foregroundColor(dsColors.textPrimary)

                            Spacer()

                            Image(systemName: showPastPackages ? "chevron.up" : "chevron.down")
                                .foregroundColor(dsColors.textHint)
                        }
                    }
                    .buttonStyle(.plain)

                    if showPastPackages {
                        ForEach(viewModel.pastSubscriptions) { subscription in
                            SubscriptionPackageCard(subscription: subscription)
                        }
                    }
                }
                .padding(.top, DSSpacing.sm)
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 40))
                .foregroundColor(dsColors.textHint)

            Text("No packages yet", bundle: .module)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)

            Text("Once you book sessions with a sheikh, your active and past packages will show up here.", bundle: .module)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl2)
    }

    private func errorState(_ message: String) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Text(message)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.error)
                .multilineTextAlignment(.center)

            Button(String(localized: "Try again", bundle: .module)) {
                Task { await viewModel.loadSubscriptions() }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DSSpacing.xl2)
    }

    // MARK: - Header (matches PrivacyPolicyView / TermsOfServiceView styling)

    private func headerBanner(title: LocalizedStringKey) -> some View {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color.white.opacity(0.20))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .padding(.leading, DSSpacing.md)

                    Text(title, bundle: .module)
                        .dsFont(DSTypography.titleLarge)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)

                    Color.clear
                        .frame(width: 40, height: 40)
                        .padding(.trailing, DSSpacing.md)
                }
                .padding(.top, 60)
                .padding(.bottom, DSSpacing.md)
            }
        .frame(maxWidth: .infinity, maxHeight: 150)
        .background(
            ZStack {
                DSGradients.primary

                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 160, height: 160)
                        .offset(x: geo.size.width - 60, y: -50)
                }
                .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .top)
        )
        .clipShape(BottomRoundedRectangleShape(radius: DSRadius.xl))
    }
}

private struct BottomRoundedRectangleShape: Shape {
    let radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - radius, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: rect.minX + radius, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.maxY - radius),
            control: CGPoint(x: rect.minX, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}
