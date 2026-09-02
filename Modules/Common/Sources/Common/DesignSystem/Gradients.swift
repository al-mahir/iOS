//
//  Gradients.swift
//  Common
//
//  Created by Alaa Ayman on 19/07/2026.
//

import SwiftUI

public enum DSGradients {
    public static let primary = LinearGradient(
        colors: [Color(hex: "#014F39"), Color(hex: "#16B689")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let secondary = LinearGradient(
        colors: [Color(hex: "#396055"), Color(hex: "#7BB7A6")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let success = LinearGradient(
        colors: [Color(hex: "#2D6C4F"), Color(hex: "#68CA9C")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    public static let darkSurface = LinearGradient(
        colors: [Color(hex: "#0F100F"), Color(hex: "#313534")],
        startPoint: .top, endPoint: .bottom
    )

    public static let hero = LinearGradient(
        colors: [Color(hex: "#014F39"), Color(hex: "#174F3F"), Color(hex: "#0F100F")],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
}
