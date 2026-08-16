//
//  SplashScreenView.swift
//  AlMahir
//
//  Created by Antigravity on 16/08/2026.
//

import SwiftUI
import Common

public struct SplashScreenView: View {
    public init() {}

    public var body: some View {
        ZStack {
            Color(hex: "#FEFEFE")
                .ignoresSafeArea()

            Image("Almahir")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 220, maxHeight: 220)
        }
    }
}

#Preview {
    SplashScreenView()
}
