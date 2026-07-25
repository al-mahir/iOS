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

public struct MushafRootView: View {

    @State private var fontsReady = false
    @State private var mushafViewModel: MushafViewModel?

    // ObservableObject stored as optional @State — will be wrapped
    // in a child StateObject holder view once resolved.
    @State private var listeningVMResolved: ListeningViewModel?
    @State private var readingVMResolved: ReadingViewModel?

    @Environment(\.tabBarVisibility) private var tabBarVisibility
    @Environment(\.dismiss) private var dismiss

    private let startPage: Int
    private let targetAyahNumber: Int?
    /// When true a "← Back" button is shown in the top bar (set to true when
    /// this view is presented modally, e.g. from the Bookmarks tab).
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
               let readingVM = readingVMResolved {
                MushafViewHost(
                    viewModel: viewModel,
                    listeningVM: listeningVM,
                    readingVM: readingVM,
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
                readingVMResolved = ReadingDIContainer.shared.resolve(ReadingViewModel.self)
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

/// Inner host that owns the ListeningViewModel lifetime through @StateObject.
private struct MushafViewHost: View {
    @StateObject var listeningVM: ListeningViewModel
    @StateObject var readingVM: ReadingViewModel
    let viewModel: MushafViewModel
    let targetAyahNumber: Int?
    let onDismiss: (() -> Void)?

    init(
        viewModel: MushafViewModel,
        listeningVM: ListeningViewModel,
        readingVM: ReadingViewModel,
        targetAyahNumber: Int?,
        onDismiss: (() -> Void)?
    ) {
        self.viewModel = viewModel
        self.targetAyahNumber = targetAyahNumber
        self.onDismiss = onDismiss
        _listeningVM = StateObject(wrappedValue: listeningVM)
        _readingVM = StateObject(wrappedValue: readingVM)
    }

    var body: some View {
        MushafView(
            viewModel: viewModel,
            listeningVM: listeningVM,
            readingVM: readingVM,
            targetAyahNumber: targetAyahNumber,
            onDismiss: onDismiss
        )
    }
}
