//
//  MuallimRootView.swift
//  Mualem
//

import SwiftUI
import Common
import Mushaf

public struct MuallimRootView: View {
    @StateObject private var viewModel: MuallimViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss
    @State private var isSetupSheetPresented: Bool = true
    
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
            
            if viewModel.currentState != .setup {
                MuallimActiveControlBar(viewModel: viewModel)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.currentState)
        .sheet(isPresented: $isSetupSheetPresented, onDismiss: {
            if viewModel.currentState == .setup {
                // User swiped down to dismiss the Teacher Setup sheet
                dismiss()
            }
        }) {
            MuallimSetupView(viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onChange(of: viewModel.currentState) { newState in
            if newState == .setup {
                isSetupSheetPresented = true
            } else {
                isSetupSheetPresented = false
            }
        }
        .sheet(isPresented: $viewModel.showMistakesSheet) {
            if let result = viewModel.currentFeedbackResult {
                MuallimMistakesSheet(feedbackResult: result) {
                    viewModel.continuePastFeedback()
                    viewModel.showMistakesSheet = false
                }
            }
        }
        .overlay(
            Group {
                if viewModel.currentState == .completed {
                    MuallimSessionSummaryView(
                        results: viewModel.accumulatedResults,
                        totalReps: viewModel.config?.repetitions ?? 1,
                        onPracticeAgain: {
                            viewModel.stopSession()
                        },
                        onDone: {
                            viewModel.stopSession()
                            dismiss()
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                }
            }
        )
    }
}
