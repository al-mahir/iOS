//
//  MushafRootView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import SwiftUI

import SwiftUI

public struct MushafRootView: View {
    @State private var fontsReady = false
    @State private var viewModel: MushafViewModel?
    
    private let startPage: Int
    private let targetAyahNumber: Int?


    public init(startPage: Int = 1, targetAyahNumber: Int? = nil) {
        self.startPage = startPage
        self.targetAyahNumber = targetAyahNumber
    }

    public var body: some View {
        Group {
            if fontsReady, let viewModel = viewModel {
           
                MushafView(viewModel: viewModel, targetAyahNumber: targetAyahNumber)
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
