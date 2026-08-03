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
    public static func reduce(value: inout [Int: Anchor<CGRect>], nextValue: () -> [Int: Anchor<CGRect>]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct TooltipSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public extension View {
    func tooltipAnchor(_ id: Int) -> some View {
        anchorPreference(key: TooltipAnchorKey.self, value: .bounds) { [id: $0] }
    }
}

// MARK: - Bounded overlay
public struct BoundedTooltipOverlay: View {
    let anchors: [Int: Anchor<CGRect>]
    let currentStep: Int
    let targetStep: Int
    let description: String
    let buttonTitle: String
    let totalSteps: Int
    let preferredPlacement: Placement
    let onNext: () -> Void

    public enum Placement { case above, below }

    @State private var cardSize: CGSize = CGSize(width: 260, height: 90)

    private let cardWidth: CGFloat = 260
    private let sideMargin: CGFloat = 16
    private let topMargin: CGFloat = 8
    private let gap: CGFloat = 12
    private let arrowHeight: CGFloat = 8

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

    public var body: some View {
        GeometryReader { proxy in
            if currentStep == targetStep, let anchor = anchors[targetStep] {
                let rect = proxy[anchor]
                let bounds = proxy.frame(in: .local)

               
                let idealCenterX = rect.midX
                let minCenterX = sideMargin + cardWidth / 2
                let maxCenterX = max(minCenterX, bounds.width - sideMargin - cardWidth / 2)
                let centerX = min(max(idealCenterX, minCenterX), maxCenterX)

                let maxArrowOffset = cardWidth / 2 - 20
                let arrowOffsetX = (idealCenterX - centerX).clamped(to: -maxArrowOffset...maxArrowOffset)

           
                let spaceBelow = bounds.height - rect.maxY
                let spaceAbove = rect.minY
                let needed = cardSize.height + gap + arrowHeight + topMargin
                let placeBelow: Bool = {
                    switch preferredPlacement {
                    case .below: return spaceBelow >= needed || spaceBelow >= spaceAbove
                    case .above: return !(spaceAbove >= needed) && spaceBelow >= spaceAbove
                    }
                }()

                let clampedCardTopY: CGFloat = {
                    if placeBelow {
                        let raw = rect.maxY + gap + arrowHeight
                        return min(raw, bounds.height - topMargin - cardSize.height)
                    } else {
                        let raw = rect.minY - gap - arrowHeight - cardSize.height
                        return max(raw, topMargin)
                    }
                }()

                VStack(spacing: 0) {
                    if !placeBelow {
                        card
                        arrow(pointingDown: true, offsetX: arrowOffsetX)
                    } else {
                        arrow(pointingDown: false, offsetX: arrowOffsetX)
                        card
                    }
                }
                .frame(width: cardWidth)
                .position(
                    x: centerX,
                    y: clampedCardTopY + cardSize.height / 2 + arrowHeight / 2
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                .zIndex(10)
                .animation(.easeInOut(duration: 0.2), value: currentStep)
            }
        }
        .allowsHitTesting(currentStep == targetStep)
    }

    private var card: some View {
        OnboardingTooltipCard(
            stepNumber: targetStep,
            description: description,
            buttonTitle: buttonTitle,
            onNext: onNext,
            totalSteps: totalSteps
        )
        .background(
            GeometryReader { g in
                Color.clear.preference(key: TooltipSizeKey.self, value: g.size)
            }
        )
        .onPreferenceChange(TooltipSizeKey.self) { size in
            if size != .zero, size != cardSize { cardSize = size }
        }
    }

    private func arrow(pointingDown: Bool, offsetX: CGFloat) -> some View {
        Image(systemName: "triangle.fill")
            .rotationEffect(.degrees(pointingDown ? 180 : 0))
            .font(.system(size: 10))
            .foregroundColor(.white)
            .offset(x: offsetX)
    }
}

private extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
