//
//  MushafRootView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//

import SwiftUI
import Common
import Bookmarks

public struct MushafRootView: View {
    @State private var fontsReady = false
    @State private var viewModel: MushafViewModel?
    @Environment(\.tabBarVisibility) private var tabBarVisibility
    @Environment(\.dismiss) private var dismiss

    private let startPage: Int
    private let targetAyahNumber: Int?
    /// When true a "← Back" button is shown in the top bar (set to true when
    /// this view is presented modally, e.g. from the Bookmarks tab).
    private let showBackButton: Bool

    public init(startPage: Int = 1, targetAyahNumber: Int? = nil, showBackButton: Bool = false) {
        self.startPage = startPage
        self.targetAyahNumber = targetAyahNumber
        self.showBackButton = showBackButton
    }

    public var body: some View {
        Group {
            if fontsReady, let viewModel = viewModel {
                MushafView(
                    viewModel: viewModel,
                    targetAyahNumber: targetAyahNumber,
                    onDismiss: showBackButton ? { dismiss() } : nil
                )
            } else {
                ProgressView("Loading fonts…")
            }
        }
        .onAppear {
            if viewModel == nil {
                let useCase = DIContainer.shared.resolve(GetMushafPageUseCase.self)
                let pageBookmarkUseCase = DIContainer.shared.resolve(PageBookmarkUseCase.self)
                let surahBookmarkUseCase = DIContainer.shared.resolve(SurahBookmarkUseCase.self)
                let ayahBookmarkUseCase = DIContainer.shared.resolve(AyahBookmarkUseCase.self)

                viewModel = MushafViewModel(
                    getPage: useCase,
                    startPage: startPage,
                    pageBookmarkUseCase: pageBookmarkUseCase,
                    surahBookmarkUseCase: surahBookmarkUseCase,
                    ayahBookmarkUseCase: ayahBookmarkUseCase
                )
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

