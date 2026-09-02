//
//  TooltipAnchorKey.swift
//  Common
//
//  Created by Basmala Abuzied Ahmed on 03/08/2026.
//

import SwiftUI

// MARK: - Anchor collection

public struct TooltipAnchorKey: PreferenceKey {

    public static var defaultValue: [Int: Anchor<CGRect>] = [:]

    public static func reduce(
        value: inout [Int: Anchor<CGRect>],
        nextValue: () -> [Int: Anchor<CGRect>]
    ) {
        value.merge(nextValue()) { _, new in
            new
        }
    }
}

private struct TooltipSizeKey: PreferenceKey {

    static var defaultValue: CGSize = .zero

    static func reduce(
        value: inout CGSize,
        nextValue: () -> CGSize
    ) {
        value = nextValue()
    }
}

// MARK: - Anchor

public extension View {

    func tooltipAnchor(_ id: Int) -> some View {
        anchorPreference(
            key: TooltipAnchorKey.self,
            value: .bounds
        ) {
            [id: $0]
        }
    }
}

// MARK: - Bounded Overlay

public struct BoundedTooltipOverlay: View {

    let anchors: [Int: Anchor<CGRect>]

    let currentStep: Int
    let targetStep: Int

    let description: String
    let buttonTitle: String

    let totalSteps: Int

    let preferredPlacement: Placement

    let onNext: () -> Void

    public enum Placement {
        case above
        case below
    }

    // MARK: Layout

    @State private var cardSize: CGSize = CGSize(
        width: 260,
        height: 120
    )

    private let cardWidth: CGFloat = 260
    private let sideMargin: CGFloat = 16
    private let topMargin: CGFloat = 8
    private let gap: CGFloat = 12
    private let arrowHeight: CGFloat = 8

    // MARK: Environment

    @Environment(\.layoutDirection)
    private var layoutDirection

    // MARK: Init

    public init(
        anchors: [Int: Anchor<CGRect>],
        currentStep: Int,
        targetStep: Int,
        description: String,
        buttonTitle: String,
        totalSteps: Int = 6,
        preferredPlacement: Placement = .below,
        onNext: @escaping () -> Void
    ) {
        self.anchors = anchors
        self.currentStep = currentStep
        self.targetStep = targetStep
        self.description = description
        self.buttonTitle = buttonTitle
        self.totalSteps = totalSteps
        self.preferredPlacement = preferredPlacement
        self.onNext = onNext
    }

    // MARK: Body

    public var body: some View {

        GeometryReader { proxy in

            if currentStep == targetStep,
               let anchor = anchors[targetStep] {

                let rect = proxy[anchor]
                let bounds = proxy.frame(in: .local)

                let centerX = calculateCenterX(
                    targetX: rect.midX,
                    width: bounds.width
                )

                let arrowOffsetX = calculateArrowOffset(
                    targetX: rect.midX,
                    centerX: centerX
                )

                let spaceBelow =
                    bounds.height - rect.maxY

                let spaceAbove =
                    rect.minY

                let neededHeight =
                    cardSize.height
                    + gap
                    + arrowHeight
                    + topMargin

                let placeBelow =
                    shouldPlaceBelow(
                        spaceBelow: spaceBelow,
                        spaceAbove: spaceAbove,
                        neededHeight: neededHeight
                    )

                let cardTopY =
                    calculateCardTopY(
                        rect: rect,
                        bounds: bounds,
                        placeBelow: placeBelow
                    )

                // MARK: Tooltip Card

                OnboardingTooltipCard(
                    stepNumber: targetStep,
                    description: description,
                    buttonTitle: buttonTitle,
                    onNext: onNext,
                    totalSteps: totalSteps
                )
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .preference(
                                key: TooltipSizeKey.self,
                                value: geometry.size
                            )
                    }
                )
                .onPreferenceChange(
                    TooltipSizeKey.self
                ) { size in

                    guard size != .zero else {
                        return
                    }

                    if size != cardSize {
                        cardSize = size
                    }
                }
                .position(
                    x: centerX,
                    y: cardTopY + cardSize.height / 2
                )
                .transition(
                    .opacity
                    .combined(
                        with: .scale(scale: 0.95)
                    )
                )
                .zIndex(10)

                // MARK: Arrow

                arrow(
                    pointingDown: !placeBelow,
                    offsetX: arrowOffsetX
                )
                .position(
                    x: centerX + arrowOffsetX,
                    y: arrowY(
                        cardTopY: cardTopY,
                        placeBelow: placeBelow
                    )
                )
                .zIndex(11)

                Color.clear
                    .allowsHitTesting(false)
            }
        }
        .allowsHitTesting(
            currentStep == targetStep
        )
        .animation(
            .easeInOut(duration: 0.2),
            value: currentStep
        )
    }

    // MARK: - Center X

    private func calculateCenterX(
        targetX: CGFloat,
        width: CGFloat
    ) -> CGFloat {

        let minCenterX =
            sideMargin
            + cardWidth / 2

        let maxCenterX =
            max(
                minCenterX,
                width
                - sideMargin
                - cardWidth / 2
            )

        return min(
            max(targetX, minCenterX),
            maxCenterX
        )
    }

    // MARK: - Arrow Offset

    private func calculateArrowOffset(
        targetX: CGFloat,
        centerX: CGFloat
    ) -> CGFloat {

        let maxArrowOffset =
            cardWidth / 2 - 20

        return (
            targetX - centerX
        )
        .clamped(
            to:
                -maxArrowOffset
                ...
                maxArrowOffset
        )
    }

    // MARK: - Placement

    private func shouldPlaceBelow(
        spaceBelow: CGFloat,
        spaceAbove: CGFloat,
        neededHeight: CGFloat
    ) -> Bool {

        switch preferredPlacement {

        case .below:

            return
                spaceBelow >= neededHeight
                || spaceBelow >= spaceAbove

        case .above:

            return
                !(spaceAbove >= neededHeight)
                && spaceBelow >= spaceAbove
        }
    }

    // MARK: - Card Y

    private func calculateCardTopY(
        rect: CGRect,
        bounds: CGRect,
        placeBelow: Bool
    ) -> CGFloat {

        if placeBelow {

            let rawTop =
                rect.maxY
                + gap
                + arrowHeight

            return min(
                rawTop,
                bounds.height
                - topMargin
                - cardSize.height
            )

        } else {

            let rawTop =
                rect.minY
                - gap
                - arrowHeight
                - cardSize.height

            return max(
                rawTop,
                topMargin
            )
        }
    }

    // MARK: - Arrow Y

    private func arrowY(
        cardTopY: CGFloat,
        placeBelow: Bool
    ) -> CGFloat {

        if placeBelow {

            // Arrow sits between target and card.
            return cardTopY - arrowHeight / 2

        } else {

            // Arrow sits below card.
            return
                cardTopY
                + cardSize.height
                + arrowHeight / 2
        }
    }

    // MARK: - Arrow

    private func arrow(
        pointingDown: Bool,
        offsetX: CGFloat
    ) -> some View {

        Image(systemName: "triangle.fill")
            .rotationEffect(
                .degrees(
                    pointingDown ? 180 : 0
                )
            )
            .font(.system(size: 10))
            .foregroundColor(.white)
            .offset(x: offsetX)
    }
}

// MARK: - Clamping

private extension Comparable {

    func clamped(
        to range: ClosedRange<Self>
    ) -> Self {

        min(
            max(
                self,
                range.lowerBound
            ),
            range.upperBound
        )
    }
}
