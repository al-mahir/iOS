//
//  TaahudContainerView.swift
//  Reading
//

import SwiftUI

struct TaahudContainerView: View {
    @StateObject private var viewModel: TaahudViewModel
    private let initialPage: Int

    init(viewModel: @autoclosure @escaping () -> TaahudViewModel, initialPage: Int) {
        self._viewModel = StateObject(wrappedValue: viewModel())
        self.initialPage = initialPage
    }

    var body: some View {
        VStack(spacing: 0) {
            errorBanner

            ScrollView {
                if let page = viewModel.currentPage {
                    mushafPage(page)
                        .padding()
                } else {
                    ProgressView()
                        .padding(.top, 80)
                }
            }

            RecitationToolbarView(
                state: viewModel.state,
                hardErrorCount: viewModel.hardErrorCount,
                selectedRules: $viewModel.selectedRules,
                strictness: $viewModel.strictness,
                onMicTapped: viewModel.onMicTapped
            )
        }
        .task {
            await viewModel.loadPage(initialPage)
        }
    }

    @ViewBuilder
    private var errorBanner: some View {
        if case .error(let message) = viewModel.state {
            Text(message)
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(8)
                .frame(maxWidth: .infinity)
                .background(Color.red)
        }
    }

    private func mushafPage(_ page: MushafPageData) -> some View {
        VStack(alignment: .center, spacing: 12) {
            ForEach(page.lines) { line in
                lineView(line)
            }
        }
    }

    private func lineView(_ line: MushafLine) -> some View {
        HStack(spacing: 4) {
            ForEach(line.words) { word in
                WordHighlightOverlay(
                    word: word,
                    status: viewModel.wordHighlights[word.id] ?? .none,
                    errors: viewModel.wordErrors[word.id] ?? []
                )
                .onTapGesture {
                    guard !word.isVerseMarker else { return }
                    viewModel.seek(sura: word.sura, aya: word.aya, wordIdx: word.wordPosition)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
