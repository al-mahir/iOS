//
//  SheikhDetailView.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI
import Common

public struct SheikhDetailView: View {

    @StateObject private var viewModel: SheikhDetailViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    public init(sheikh: Sheikh) {
        _viewModel = StateObject(
            wrappedValue: SheikhDetailViewModel(
                sheikhID: sheikh.id,
                prefetched: sheikh
            )
        )
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: DSSpacing.none) {

            SheikhHeaderBanner(
                title: viewModel.sheikh?.fullName ?? "Sheikh Profile",
                onLeadingTap: {
                    dismiss()
                }
            )

            ScrollView {
                if viewModel.isLoading {
                    loadingView
                        .padding(.top, DSSpacing.xl2)
                } else if let sheikh = viewModel.sheikh {
                    profileContent(sheikh)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                        .padding(.top, DSSpacing.xl2)
                }
            }
            .background(dsColors.background)
        }
        .background(dsColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: viewModel.isLoading)
        .onAppear {
            viewModel.loadDetail()
        }
    }

    @ViewBuilder
    private func profileContent(_ sheikh: Sheikh) -> some View {
        VStack(spacing: DSSpacing.none) {

            SheikhAvatarView(sheikh: sheikh, size: 110)
                .padding(.top, DSSpacing.lg)

            Text(sheikh.fullName)
                .dsFont(DSTypography.titleLarge)
                .foregroundColor(dsColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.top, DSSpacing.sm)

            Text("Quran & Memorisation")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .padding(.top, DSSpacing.xxs)

            SheikhStatusBadge(status: sheikh.sheikhStatus)
                .padding(.top, DSSpacing.xs)

            statsRow(sheikh)
                .padding(.top, DSSpacing.lg)
                .padding(.horizontal, DSSpacing.md)

            Divider()
                .foregroundColor(dsColors.outlineVariant)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.md)

            bioSection
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.md)

            activeSessionsSection(sheikh)
                .padding(.horizontal, DSSpacing.md)
                .padding(.top, DSSpacing.lg)
                .padding(.bottom, DSSpacing.xl2)
        }
    }

    // MARK: - Stats Row

    private func statsRow(_ sheikh: Sheikh) -> some View {
        HStack(spacing: DSSpacing.none) {
            SheikhStatItem(
                value: String(format: "%.1f", sheikh.rate),
                label: "Rating"
            )

            Divider()
                .frame(height: 36)
                .foregroundColor(dsColors.outlineVariant)

            SheikhStatItem(value: "203", label: "Reviews")

            Divider()
                .frame(height: 36)
                .foregroundColor(dsColors.outlineVariant)

            SheikhStatItem(value: "510", label: "Students")

            Divider()
                .frame(height: 36)
                .foregroundColor(dsColors.outlineVariant)

            SheikhStatItem(value: "1", label: "Sessions")
        }
    }

    // MARK: - Bio Section

    private var bioSection: some View {
        VStack(alignment: .trailing, spacing: DSSpacing.sm) {
            Text("About")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(
                "A scholar specialised in Quran sciences, certified with an unbroken chain of transmission (isnad)."
            )
            .dsFont(DSTypography.bodyMedium)
            .foregroundColor(dsColors.textSecondary)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Active Sessions

    private func activeSessionsSection(_ sheikh: Sheikh) -> some View {
        VStack(alignment: .trailing, spacing: DSSpacing.md) {
            Text("Active Sessions")
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)

            sessionCard(sheikh: sheikh)
        }
    }

    private func sessionCard(sheikh: Sheikh) -> some View {
        HStack(spacing: DSSpacing.smMd) {
            VStack(alignment: .leading, spacing: DSSpacing.xs) {
                HStack(spacing: DSSpacing.xs) {
                    Text("Surah Al-Kahf")
                        .dsFont(DSTypography.titleSmall)
                        .foregroundColor(dsColors.textPrimary)
                }

                Text("Beginner")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.primary)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xxs)
                    .background(
                        Capsule()
                            .fill(dsColors.primaryContainer)
                    )

                HStack(spacing: DSSpacing.sm) {
                    SheikhAvatarView(sheikh: sheikh, size: 38)

                    VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                        Text(sheikh.fullName)
                            .dsFont(DSTypography.labelSmall)
                            .foregroundColor(dsColors.textSecondary)
                        Text("Reading · 8/15")
                            .dsFont(DSTypography.caption)
                            .foregroundColor(dsColors.textTertiary)
                    }
                }
            }

            Spacer()

            Button {
                // TODO: wire join action
            } label: {
                Text("Join")
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.onPrimary)
                    .padding(.horizontal, DSSpacing.mdLg)
                    .padding(.vertical, DSSpacing.smMd)
                    .background(
                        RoundedRectangle(cornerRadius: DSRadius.md)
                            .fill(dsColors.primary)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(DSSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
    }

    private var liveIndicator: some View {
        HStack(spacing: DSSpacing.xs) {
            Circle()
                .fill(Color.red)
                .frame(width: 7, height: 7)
            Text("LIVE")
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(.red)
        }
        .padding(.horizontal, DSSpacing.sm)
        .padding(.vertical, DSSpacing.xxs)
        .background(
            Capsule()
                .stroke(Color.red.opacity(0.4), lineWidth: 1)
        )
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: DSSpacing.md) {
            RoundedRectangle(cornerRadius: DSRadius.md)
                .fill(dsColors.surfaceContainerLow)
                .frame(width: 110, height: 110)
                .shimmering()

            RoundedRectangle(cornerRadius: DSRadius.xs)
                .fill(dsColors.surfaceContainerLow)
                .frame(width: 180, height: 20)
                .shimmering()

            RoundedRectangle(cornerRadius: DSRadius.xs)
                .fill(dsColors.surfaceContainerLow)
                .frame(width: 120, height: 14)
                .shimmering()
        }
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: DSSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(dsColors.error)

            Text(message)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.xl)

            Button {
                viewModel.refresh()
            } label: {
                Text("Try Again")
                    .dsFont(DSTypography.buttonText)
                    .foregroundColor(dsColors.primary)
            }
        }
    }
}

// MARK: - Shimmer

extension View {
    fileprivate func shimmering() -> some View {
        modifier(DetailShimmerModifier())
    }
}

private struct DetailShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: max(0, phase - 0.3)),
                        .init(color: Color.white.opacity(0.5), location: phase),
                        .init(color: .clear, location: min(1, phase + 0.3)),
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .clipped()
            )
            .onAppear {
                withAnimation(
                    .linear(duration: 1.4).repeatForever(autoreverses: false)
                ) {
                    phase = 1.5
                }
            }
    }
}
