//
//  MushafRootView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI

public struct MushafRootView: View {
    @State private var fontsReady = false
    @State private var viewModel: MushafViewModel?
    @StateObject private var qraaManager = QraaManager()
    
    private let startPage: Int

    public init(startPage: Int = 1) {
        self.startPage = startPage
    }

    public var body: some View {
        Group {
            if fontsReady, let viewModel = viewModel {
                MushafView(viewModel: viewModel, qraaManager: qraaManager)
            } else {
                ProgressView("Loading fonts…")
            }
        }
        .onAppear {
            if viewModel == nil {
                let useCase = DIContainer.shared.resolve(GetMushafPageUseCase.self)
                viewModel = MushafViewModel(getPage: useCase, startPage: startPage)
            }
            
            MushafFontManager.shared.registerFonts {
                fontsReady = true
            }
        }
    }
}
