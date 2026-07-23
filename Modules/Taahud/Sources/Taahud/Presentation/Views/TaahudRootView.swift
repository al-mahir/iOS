//
//  TaahudRootView.swift
//  Taahud
//
//  Created by Basmala Abuzied Ahmed on 22/07/2026.
//


import SwiftUI

public struct TaahudRootView: View {
    // 1. Initialize the DI Container (Defaults to useMockEngine: true)
    private let container = TaahudDIContainer()
    
    @State private var isShowingSession = false
    public init(){}
    public var body: some View {
        VStack(spacing: 20) {
            Button("Start Recitation Session") {
                isShowingSession = true
            }
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $isShowingSession) {
            // 2. Configure the session parameters
            let config = TaahudSessionConfig(
                position: MushafPosition(sura: 1, aya: 1, wordIdx: 1),
                strictness: .normal
            )
            
            // 3. Create ViewModel & View
            TaahudSessionView(
                viewModel: container.makeSessionViewModel(config: config)
            )
        }
    }
}
