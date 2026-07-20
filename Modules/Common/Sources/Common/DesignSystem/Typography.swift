//
//  Typography.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI

public enum DSFontWeight {
    case regular, medium, semibold, bold

    var interPostScriptName: String {
        switch self {
        case .regular:  return "Inter-Regular"
        case .medium:   return "Inter-Medium"
        case .semibold: return "Inter-SemiBold"
        case .bold:     return "Inter-Bold"
        }
    }
}


public struct DSTextStyle {
    public let size: CGFloat
    public let weight: DSFontWeight
    public let lineHeight: CGFloat
    public let letterSpacing: CGFloat
    public let paragraphSpacing: CGFloat

    public init(size: CGFloat, weight: DSFontWeight, lineHeight: CGFloat, letterSpacing: CGFloat, paragraphSpacing: CGFloat = 0) {
        self.size = size
        self.weight = weight
        self.lineHeight = lineHeight
        self.letterSpacing = letterSpacing
        self.paragraphSpacing = paragraphSpacing
    }

 
    public func font() -> Font {
        .custom(weight.interPostScriptName, size: size, relativeTo: .body)
    }

    public func arabicFont() -> Font {
        let base = Font.custom("AmiriQuran-Regular", size: size, relativeTo: .body)
        return (weight == .bold || weight == .semibold) ? base.bold() : base
    }

    var extraLineSpacing: CGFloat { max(0, lineHeight - size) }
}

extension DSFontWeight: Equatable {}

public extension View {
   
    func dsFont(_ style: DSTextStyle) -> some View {
        self
            .font(style.font())
            .tracking(style.letterSpacing)
            .lineSpacing(style.extraLineSpacing)
    }


    func dsArabicFont(_ style: DSTextStyle) -> some View {
        self
            .font(style.arabicFont())
            .tracking(style.letterSpacing)
            .lineSpacing(style.extraLineSpacing)
    }
}

public enum DSTypography {
    // Display
    public static let displayLarge  = DSTextStyle(size: 57, weight: .regular, lineHeight: 64, letterSpacing: -0.25, paragraphSpacing: 16)
    public static let displayMedium = DSTextStyle(size: 45, weight: .regular, lineHeight: 52, letterSpacing: 0, paragraphSpacing: 16)
    public static let displaySmall  = DSTextStyle(size: 36, weight: .regular, lineHeight: 44, letterSpacing: 0, paragraphSpacing: 12)

    // Headline
    public static let headlineLarge  = DSTextStyle(size: 32, weight: .semibold, lineHeight: 40, letterSpacing: 0, paragraphSpacing: 12)
    public static let headlineMedium = DSTextStyle(size: 28, weight: .semibold, lineHeight: 36, letterSpacing: 0, paragraphSpacing: 8)
    public static let headlineSmall  = DSTextStyle(size: 24, weight: .semibold, lineHeight: 32, letterSpacing: 0, paragraphSpacing: 8)

    // Title
    public static let titleLarge  = DSTextStyle(size: 22, weight: .medium, lineHeight: 28, letterSpacing: 0, paragraphSpacing: 8)
    public static let titleMedium = DSTextStyle(size: 16, weight: .medium, lineHeight: 24, letterSpacing: 0.15, paragraphSpacing: 4)
    public static let titleSmall  = DSTextStyle(size: 14, weight: .medium, lineHeight: 20, letterSpacing: 0.1, paragraphSpacing: 4)

    // Body
    public static let bodyLarge  = DSTextStyle(size: 16, weight: .regular, lineHeight: 24, letterSpacing: 0.5, paragraphSpacing: 8)
    public static let bodyMedium = DSTextStyle(size: 14, weight: .regular, lineHeight: 20, letterSpacing: 0.25, paragraphSpacing: 6)
    public static let bodySmall  = DSTextStyle(size: 12, weight: .regular, lineHeight: 16, letterSpacing: 0.4, paragraphSpacing: 4)

    // Label
    public static let labelLarge  = DSTextStyle(size: 14, weight: .medium, lineHeight: 20, letterSpacing: 0.1)
    public static let labelMedium = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.5)
    public static let labelSmall  = DSTextStyle(size: 11, weight: .medium, lineHeight: 16, letterSpacing: 0.5)

    // Misc semantic text
    public static let caption  = DSTextStyle(size: 12, weight: .regular, lineHeight: 16, letterSpacing: 0.4)
    public static let hint     = DSTextStyle(size: 12, weight: .regular, lineHeight: 16, letterSpacing: 0.4)
    public static let overline = DSTextStyle(size: 10, weight: .medium, lineHeight: 16, letterSpacing: 1.5)

    // Component-specific
    public static let buttonText      = DSTextStyle(size: 14, weight: .semibold, lineHeight: 20, letterSpacing: 0.1)
    public static let navigationLabel = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.4)
    public static let tabLabel        = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.4)
    public static let chipLabel       = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.2)
    public static let inputLabel      = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.4)
    public static let inputHint       = DSTextStyle(size: 14, weight: .regular, lineHeight: 20, letterSpacing: 0.25)
    public static let inputError      = DSTextStyle(size: 12, weight: .medium, lineHeight: 16, letterSpacing: 0.4)
    public static let dialogTitle     = DSTextStyle(size: 20, weight: .semibold, lineHeight: 28, letterSpacing: 0)
    public static let dialogBody      = DSTextStyle(size: 14, weight: .regular, lineHeight: 20, letterSpacing: 0.25)
    public static let tooltip         = DSTextStyle(size: 12, weight: .regular, lineHeight: 16, letterSpacing: 0.4)
    public static let badgeText       = DSTextStyle(size: 11, weight: .semibold, lineHeight: 14, letterSpacing: 0.2)
}
