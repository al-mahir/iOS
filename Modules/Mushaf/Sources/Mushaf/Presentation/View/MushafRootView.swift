//
//  MushafRootView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI
import Common
import Listening
import Bookmarks
import Taahud

public struct MushafRootView: View {

    @State private var fontsReady = false
    @State private var mushafViewModel: MushafViewModel?

    // ObservableObject stored as optional @State — will be wrapped
    // in a child StateObject holder view once resolved.
    @State private var listeningVMResolved: ListeningViewModel?
    @State private var taahudVMResolved: TaahudViewModel?

    @Environment(\.tabBarVisibility) private var tabBarVisibility
    @Environment(\.dismiss) private var dismiss

    private let startPage: Int
    private let targetAyahNumber: Int?
    private let showBackButton: Bool

    public init(
        startPage: Int = 1,
        targetAyahNumber: Int? = nil,
        showBackButton: Bool = false
    ) {
        self.startPage = startPage
        self.targetAyahNumber = targetAyahNumber
        self.showBackButton = showBackButton
    }

    public var body: some View {
        Group {
            if fontsReady,
               let viewModel = mushafViewModel,
               let listeningVM = listeningVMResolved,
               let taahudVM = taahudVMResolved {
                MushafViewHost(
                    viewModel: viewModel,
                    listeningVM: listeningVM,
                    taahudVM: taahudVM,
                    targetAyahNumber: targetAyahNumber,
                    onDismiss: showBackButton ? { dismiss() } : nil
                )
            } else {
                ProgressView("Loading fonts…")
            }
        }
        .onAppear {
            if mushafViewModel == nil {
                let useCase = DIContainer.shared.resolve(GetMushafPageUseCase.self)
                let pageBookmarkUseCase = DIContainer.shared.resolve(PageBookmarkUseCase.self)
                let surahBookmarkUseCase = DIContainer.shared.resolve(SurahBookmarkUseCase.self)
                let ayahBookmarkUseCase = DIContainer.shared.resolve(AyahBookmarkUseCase.self)

                mushafViewModel = MushafViewModel(
                    getPage: useCase,
                    startPage: startPage,
                    pageBookmarkUseCase: pageBookmarkUseCase,
                    surahBookmarkUseCase: surahBookmarkUseCase,
                    ayahBookmarkUseCase: ayahBookmarkUseCase
                )

                listeningVMResolved = ListeningDIContainer.shared.resolve(ListeningViewModel.self)
                
                taahudVMResolved = TaahudDependencyContainer.makeEmbeddedTaahudViewModel()
            }

            MushafFontManager.shared.registerFonts {
                fontsReady = true
            }

            tabBarVisibility.isVisible = false
        }
        .onDisappear {
            tabBarVisibility.isVisible = true
        }
    }
}

// MARK: - Host view that holds ListeningViewModel as @StateObject

private struct MushafViewHost: View {
    @StateObject var listeningVM: ListeningViewModel
    @StateObject var taahudVM: TaahudViewModel
    let viewModel: MushafViewModel
    let targetAyahNumber: Int?
    let onDismiss: (() -> Void)?

    init(
        viewModel: MushafViewModel,
        listeningVM: ListeningViewModel,
        taahudVM: TaahudViewModel,
        targetAyahNumber: Int?,
        onDismiss: (() -> Void)?
    ) {
        self.viewModel = viewModel
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
        _listeningVM = StateObject(wrappedValue: listeningVM)
        _taahudVM = StateObject(wrappedValue: taahudVM)
    }

    var body: some View {
        MushafView(
            viewModel: viewModel,
            listeningVM: listeningVM,
            taahudVM: taahudVM,
            targetAyahNumber: targetAyahNumber,
            onDismiss: onDismiss
        )
    }
}
