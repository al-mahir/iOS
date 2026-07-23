//
//  Color.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI
import CoreGraphics

// MARK: - Hex Color Helper
public extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255,
            green: Double((rgb & 0x00FF00) >> 8) / 255,
            blue: Double(rgb & 0x0000FF) / 255
        )
    }
}

// MARK: - 1. Color Tokens
public enum DSColor {
    public static func primary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#B0E8D8") : Color(hex: "#014F39") }
    public static func onPrimary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#174F3F") : Color(hex: "#FFFFFF") }
    public static func primaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#1A7F63") : Color(hex: "#DAF1EA") }
    public static func onPrimaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#DAF1EA") : Color(hex: "#0E251E") }
    public static func primaryVariant(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#80E5C9") : Color(hex: "#1A7F63") }
    public static func secondary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#C1D7D1") : Color(hex: "#488473") }
    public static func onSecondary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#283E38") : Color(hex: "#FFFFFF") }
    public static func secondaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#396055") : Color(hex: "#E1EAE7") }
    public static func onSecondaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E1EAE7") : Color(hex: "#151E1B") }
    public static func secondaryVariant(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#9FC6BB") : Color(hex: "#396055") }
    public static func tertiary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#D7C1D2") : Color(hex: "#854778") }
    public static func onTertiary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#3E2839") : Color(hex: "#FFFFFF") }
    public static func tertiaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#603958") : Color(hex: "#EAE1E8") }
    public static func onTertiaryContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#EAE1E8") : Color(hex: "#1E151C") }
    public static func background(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#0F100F") : Color(hex: "#FAFAFA") }
    public static func onBackground(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E5E6E6") : Color(hex: "#191A1A") }
    public static func surface(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#0F100F") : Color(hex: "#FAFAFA") }
    public static func onSurface(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E5E6E6") : Color(hex: "#191A1A") }
    public static func surfaceVariant(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#455450") : Color(hex: "#E4E7E6") }
    public static func onSurfaceVariant(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#C8D0CE") : Color(hex: "#455450") }
    public static func surfaceDim(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#0F100F") : Color(hex: "#DDDFDE") }
    public static func surfaceBright(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#3B403E") : Color(hex: "#FAFAFA") }
    public static func surfaceContainerLowest(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#0A0A0A") : Color(hex: "#FFFFFF") }
    public static func surfaceContainerLow(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#191A1A") : Color(hex: "#F5F5F5") }
    public static func surfaceContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#1E201F") : Color(hex: "#EFF0F0") }
    public static func surfaceContainerHigh(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#2A2D2C") : Color(hex: "#EAEBEB") }
    public static func surfaceContainerHighest(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#363A39") : Color(hex: "#E5E6E6") }
    public static func outline(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#8DA59E") : Color(hex: "#6E9187") }
    public static func outlineVariant(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#455450") : Color(hex: "#C8D0CE") }
    public static func inverseSurface(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E5E6E6") : Color(hex: "#313534") }
    public static func inverseOnSurface(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#313534") : Color(hex: "#F2F3F2") }
    public static func inversePrimary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#16B689") : Color(hex: "#B0E8D8") }
    public static func scrim(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#000000") : Color(hex: "#000000") }
    public static func shadow(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#000000") : Color(hex: "#000000") }
    public static func surfaceTint(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#B0E8D8") : Color(hex: "#014F39") }
    public static func textPrimary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E5E6E6") : Color(hex: "#191A1A") }
    public static func textSecondary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#C8D0CE") : Color(hex: "#455450") }
    public static func textTertiary(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#949E9B") : Color(hex: "#788783") }
    public static func textDisabled(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#616B68") : Color(hex: "#AFB6B4") }
    public static func textHint(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#788783") : Color(hex: "#949E9B") }
    public static func textLink(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#B0E8D8") : Color(hex: "#014F39") }
    public static func textVisitedLink(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#D7C1D2") : Color(hex: "#854778") }
    public static func success(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#BBDDCD") : Color(hex: "#359769") }
    public static func onSuccess(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#224434") : Color(hex: "#FFFFFF") }
    public static func successContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#2D6C4F") : Color(hex: "#DFECE6") }
    public static func onSuccessContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#DFECE6") : Color(hex: "#13201A") }
    public static func warning(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E6D3B2") : Color(hex: "#B17A1B") }
    public static func onWarning(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#4D3A19") : Color(hex: "#FFFFFF") }
    public static func warningContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#7D591C") : Color(hex: "#F0E8DB") }
    public static func onWarningContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#F0E8DB") : Color(hex: "#241C0F") }
    public static func error(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#E3B8B5") : Color(hex: "#A92C23") }
    public static func onError(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#4A1F1C") : Color(hex: "#FFFFFF") }
    public static func errorContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#772822") : Color(hex: "#EFDEDC") }
    public static func onErrorContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#EFDEDC") : Color(hex: "#231210") }
    public static func info(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#B8CBE0") : Color(hex: "#2C64A0") }
    public static func onInfo(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#1F3247") : Color(hex: "#FFFFFF") }
    public static func infoContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#284B71") : Color(hex: "#DEE5ED") }
    public static func onInfoContainer(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#DEE5ED") : Color(hex: "#121921") }
    public static func divider(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#455450") : Color(hex: "#C8D0CE") }
    public static func border(for scheme: ColorScheme) -> Color { scheme == .dark ? Color(hex: "#8DA59E") : Color(hex: "#6E9187") }
}

public struct DSColors {
    public let primary, onPrimary, primaryContainer, onPrimaryContainer, primaryVariant: Color
    public let secondary, onSecondary, secondaryContainer, onSecondaryContainer, secondaryVariant: Color
    public let tertiary, onTertiary, tertiaryContainer, onTertiaryContainer: Color
    public let background, onBackground, surface, onSurface, surfaceVariant, onSurfaceVariant, surfaceDim, surfaceBright: Color
    public let surfaceContainerLowest, surfaceContainerLow, surfaceContainer, surfaceContainerHigh, surfaceContainerHighest: Color
    public let outline, outlineVariant, inverseSurface, inverseOnSurface, inversePrimary, scrim, shadow, surfaceTint: Color
    public let textPrimary, textSecondary, textTertiary, textDisabled, textHint, textLink, textVisitedLink: Color
    public let success, onSuccess, successContainer, onSuccessContainer: Color
    public let warning, onWarning, warningContainer, onWarningContainer: Color
    public let error, onError, errorContainer, onErrorContainer: Color
    public let info, onInfo, infoContainer, onInfoContainer, divider, border: Color

    public init(scheme: ColorScheme) {
        self.primary = DSColor.primary(for: scheme)
        self.onPrimary = DSColor.onPrimary(for: scheme)
        self.primaryContainer = DSColor.primaryContainer(for: scheme)
        self.onPrimaryContainer = DSColor.onPrimaryContainer(for: scheme)
        self.primaryVariant = DSColor.primaryVariant(for: scheme)
        self.secondary = DSColor.secondary(for: scheme)
        self.onSecondary = DSColor.onSecondary(for: scheme)
        self.secondaryContainer = DSColor.secondaryContainer(for: scheme)
        self.onSecondaryContainer = DSColor.onSecondaryContainer(for: scheme)
        self.secondaryVariant = DSColor.secondaryVariant(for: scheme)
        self.tertiary = DSColor.tertiary(for: scheme)
        self.onTertiary = DSColor.onTertiary(for: scheme)
        self.tertiaryContainer = DSColor.tertiaryContainer(for: scheme)
        self.onTertiaryContainer = DSColor.onTertiaryContainer(for: scheme)
        self.background = DSColor.background(for: scheme)
        self.onBackground = DSColor.onBackground(for: scheme)
        self.surface = DSColor.surface(for: scheme)
        self.onSurface = DSColor.onSurface(for: scheme)
        self.surfaceVariant = DSColor.surfaceVariant(for: scheme)
        self.onSurfaceVariant = DSColor.onSurfaceVariant(for: scheme)
        self.surfaceDim = DSColor.surfaceDim(for: scheme)
        self.surfaceBright = DSColor.surfaceBright(for: scheme)
        self.surfaceContainerLowest = DSColor.surfaceContainerLowest(for: scheme)
        self.surfaceContainerLow = DSColor.surfaceContainerLow(for: scheme)
        self.surfaceContainer = DSColor.surfaceContainer(for: scheme)
        self.surfaceContainerHigh = DSColor.surfaceContainerHigh(for: scheme)
        self.surfaceContainerHighest = DSColor.surfaceContainerHighest(for: scheme)
        self.outline = DSColor.outline(for: scheme)
        self.outlineVariant = DSColor.outlineVariant(for: scheme)
        self.inverseSurface = DSColor.inverseSurface(for: scheme)
        self.inverseOnSurface = DSColor.inverseOnSurface(for: scheme)
        self.inversePrimary = DSColor.inversePrimary(for: scheme)
        self.scrim = DSColor.scrim(for: scheme)
        self.shadow = DSColor.shadow(for: scheme)
        self.surfaceTint = DSColor.surfaceTint(for: scheme)
        self.textPrimary = DSColor.textPrimary(for: scheme)
        self.textSecondary = DSColor.textSecondary(for: scheme)
        self.textTertiary = DSColor.textTertiary(for: scheme)
        self.textDisabled = DSColor.textDisabled(for: scheme)
        self.textHint = DSColor.textHint(for: scheme)
        self.textLink = DSColor.textLink(for: scheme)
        self.textVisitedLink = DSColor.textVisitedLink(for: scheme)
        self.success = DSColor.success(for: scheme)
        self.onSuccess = DSColor.onSuccess(for: scheme)
        self.successContainer = DSColor.successContainer(for: scheme)
        self.onSuccessContainer = DSColor.onSuccessContainer(for: scheme)
        self.warning = DSColor.warning(for: scheme)
        self.onWarning = DSColor.onWarning(for: scheme)
        self.warningContainer = DSColor.warningContainer(for: scheme)
        self.onWarningContainer = DSColor.onWarningContainer(for: scheme)
        self.error = DSColor.error(for: scheme)
        self.onError = DSColor.onError(for: scheme)
        self.errorContainer = DSColor.errorContainer(for: scheme)
        self.onErrorContainer = DSColor.onErrorContainer(for: scheme)
        self.info = DSColor.info(for: scheme)
        self.onInfo = DSColor.onInfo(for: scheme)
        self.infoContainer = DSColor.infoContainer(for: scheme)
        self.onInfoContainer = DSColor.onInfoContainer(for: scheme)
        self.divider = DSColor.divider(for: scheme)
        self.border = DSColor.border(for: scheme)
    }
}

private struct DSColorsKey: EnvironmentKey {
    static let defaultValue = DSColors(scheme: .light)
}

public extension EnvironmentValues {
    var dsColors: DSColors {
        get { self[DSColorsKey.self] }
        set { self[DSColorsKey.self] = newValue }
    }
}

public struct DSThemeModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    public func body(content: Content) -> some View {
        content.environment(\.dsColors, DSColors(scheme: colorScheme))
    }
}

public extension View {
    func dsTheme() -> some View { modifier(DSThemeModifier()) }
}
