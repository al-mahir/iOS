//
//  MuallimRootView.swift
//  Mualem
//

import SwiftUI
import Common
import Mushaf

public struct MuallimRootView: View {
    @StateObject private var viewModel: MuallimViewModel
    
    public init(viewModel: MuallimViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        let activeAyahOptional = Binding<Int?>(
            get: { viewModel.currentAyahToProcess == 0 ? nil : viewModel.currentAyahToProcess },
            set: { _ in } // Read-only from Mushaf perspective
        )
        
        ZStack(alignment: .bottom) {
            MushafRootView(
                startPage: viewModel.sessionStartPage,
                targetAyahNumber: nil,
                showBackButton: false,
                hideChrome: true,
                activeAyahBinding: activeAyahOptional,
                activeWordKeyBinding: $viewModel.activeWordKey
            )
            .id(viewModel.sessionStartPage)
            
            if viewModel.currentState == .setup {
                MuallimSetupView(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                MuallimActiveControlBar(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentState)
    }
}
