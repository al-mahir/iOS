//
//  Elevation.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//



import SwiftUI

public struct DSElevationLevel {
    public let opacity: Double
    public let blur: CGFloat
    public let offsetY: CGFloat

    public init(opacity: Double, blur: CGFloat, offsetY: CGFloat) {
        self.opacity = opacity
        self.blur = blur
        self.offsetY = offsetY
    }
}

public enum DSElevation {
    public static let level0 = DSElevationLevel(opacity: 0,    blur: 0,  offsetY: 0)
    public static let level1 = DSElevationLevel(opacity: 0.08, blur: 3,  offsetY: 1)
    public static let level2 = DSElevationLevel(opacity: 0.10, blur: 6,  offsetY: 2)
    public static let level3 = DSElevationLevel(opacity: 0.12, blur: 10, offsetY: 4)
    public static let level4 = DSElevationLevel(opacity: 0.14, blur: 16, offsetY: 6)
    public static let level5 = DSElevationLevel(opacity: 0.16, blur: 24, offsetY: 8)
}

public extension View {
    
    func dsElevation(_ level: DSElevationLevel) -> some View {
        modifier(DSElevationModifier(level: level))
    }
}

private struct DSElevationModifier: ViewModifier {
    @Environment(\.dsColors) private var dsColors
    let level: DSElevationLevel

    func body(content: Content) -> some View {
        content.shadow(
            color: dsColors.shadow.opacity(level.opacity),
            radius: level.blur,
            x: 0,
            y: level.offsetY
        )
    }
}
