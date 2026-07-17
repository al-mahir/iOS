//
//  MushafRootView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import SwiftUI

public struct MushafRootView: View {
    @State private var fontsReady = false

    public init() {}

    public var body: some View {
        Group {
            if fontsReady {
                MushafView(viewModel: DIContainer.shared.resolve(MushafViewModel.self))
            } else {
                ProgressView("Loading fonts…")
            }
        }
        .onAppear {
            MushafFontManager.shared.registerFonts {
                fontsReady = true
            }
        }
    }
}
