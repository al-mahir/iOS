//
//  MushafView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import SwiftUI

struct MushafView: View {
    @StateObject private var viewModel: MushafViewModel
    @ObservedObject private var fontManager = MushafFontManager.shared
    @State private var isShowingPageJump = false

    init(viewModel: MushafViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            TabView(selection: $viewModel.pageNumber) {
                ForEach(1...viewModel.totalPages, id: \.self) { number in
                    pageContent(for: number)
                        .tag(number)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .environment(\.layoutDirection, .rightToLeft)
            .onChange(of: viewModel.pageNumber) { newValue in
                viewModel.loadPage(newValue)
            }

            if viewModel.isLoading {
                ProgressView()
            }
        }
        .overlay(alignment: .bottom) {
            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .padding(.bottom, 12)
            }
        }
        .safeAreaInset(edge: .top) {
            topBar
        }
        .sheet(isPresented: $isShowingPageJump) {
            PageJumpSheet(
                totalPages: viewModel.totalPages,
                currentPage: viewModel.pageNumber
            ) { newPage in
                viewModel.pageNumber = newPage
            }
            .presentationDetents([.height(220)])
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                isShowingPageJump = true
            } label: {
                HStack(spacing: 4) {
                    Text("Page \(viewModel.pageNumber)")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 9, weight: .semibold))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Toggle(isOn: $viewModel.isTajweedEnabled) {
                Text("Tajweed").font(.caption)
            }
            .toggleStyle(.switch)
            .labelsHidden()
            .disabled(!fontManager.isReady || !fontManager.isFontSetAvailable(.plain))
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private func pageContent(for number: Int) -> some View {
        if number == viewModel.pageNumber, let page = viewModel.currentPage {
            let fontSet: MushafFontSet = viewModel.isTajweedEnabled ? .tajweed : .plain
            MushafPageView(page: page, fontName: fontManager.fontName(forPage: number, set: fontSet))
        } else {
            Color.clear
        }
    }
}