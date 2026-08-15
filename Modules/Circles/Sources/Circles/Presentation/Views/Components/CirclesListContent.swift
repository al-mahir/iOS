//
//  CirclesListContent.swift
//  Circles
//

import Common
import SwiftUI

public struct CirclesListContent: View {
    @Environment(\.dsColors) private var dsColors
    private let circles: [CircleModel]
    private let isLoading: Bool
    private let errorMessage: String?
    private let emptyMessage: String
    private let onCircleAction: ((CircleModel) -> Void)?
    private let onLastCircleAppear: ((CircleModel) -> Void)?
    private let onRetry: (() -> Void)?

    public init(
        circles: [CircleModel],
        isLoading: Bool,
        errorMessage: String?,
        emptyMessage: String,
        onCircleAction: ((CircleModel) -> Void)? = nil,
        onLastCircleAppear: ((CircleModel) -> Void)? = nil,
        onRetry: (() -> Void)? = nil
    ) {
        self.circles = circles
        self.isLoading = isLoading
        self.errorMessage = errorMessage
        self.emptyMessage = emptyMessage
        self.onCircleAction = onCircleAction
        self.onLastCircleAppear = onLastCircleAppear
        self.onRetry = onRetry
    }

    public var body: some View {
        LazyVStack(spacing: DSSpacing.md) {
            if isLoading && circles.isEmpty {
                ProgressView()
                    .padding(.top, DSSpacing.xl)
            } else if let errorMessage, circles.isEmpty {
                errorView(errorMessage)
            } else if circles.isEmpty {
                CirclesEmptyStateView(message: emptyMessage)
            } else {
                ForEach(circles) { circle in
                    CircleCardView(
                        circle: circle,
                        onJoinTap: onCircleAction.map { action in { action(circle) } }
                    )
                    .onAppear {
                        if circle.id == circles.last?.id {
                            onLastCircleAppear?(circle)
                        }
                    }
                }

                if isLoading {
                    ProgressView()
                        .padding(.vertical, DSSpacing.md)
                }

                if let errorMessage {
                    errorView(errorMessage)
                }
            }
        }
    }

    @ViewBuilder
    private func errorView(_ message: String) -> some View {
        VStack(spacing: DSSpacing.sm) {
            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.error)
                .multilineTextAlignment(.center)

            if let onRetry {
                Button("Retry", action: onRetry)
                    .buttonStyle(DSPrimaryButtonStyle())
            }
        }
        .padding(.top, DSSpacing.xl)
    }
}

public struct CirclesEmptyStateView: View {
    @Environment(\.dsColors) private var dsColors
    private let message: String

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "person.3")
                .font(.system(size: 44))
                .foregroundColor(dsColors.textHint)

            Text("No circles found")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textSecondary)

            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textHint)
                .multilineTextAlignment(.center)
        }
        .padding(.top, DSSpacing.xl2)
    }
}
