////
////  QraaMushafPageView.swift
////  Reading
////
//
//import SwiftUI
//import Mushaf
//
//public struct ReadingPageView: View {
//    let page: MushafPage
//    let fontName: String?
//    var bottomInset: CGFloat = 0
//
//    @ObservedObject var viewModel: ReadingViewModel
//
//    public init(page: MushafPage, fontName: String?, bottomInset: CGFloat = 0, viewModel: ReadingViewModel) {
//        self.page = page
//        self.fontName = fontName
//        self.bottomInset = bottomInset
//        self.viewModel = viewModel
//    }
//
//    public var body: some View {
//        ZStack(alignment: .top) {
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 8) {
//                    ForEach(page.lines) { line in
//                        lineView(for: line)
//                    }
//                }
//                .padding(.bottom, bottomInset)
//            }
//
//            if case .incorrect(let expectedWord) = viewModel.status {
//                incorrectToast(expectedWord: expectedWord)
//                    .padding(.top, 12)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }
//
//            if case .correct = viewModel.status {
//                correctToast
//                    .padding(.top, 12)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//            }
//
//            if viewModel.isSessionComplete {
//                completionBanner
//            }
//        }
//        .animation(.easeInOut(duration: 0.25), value: viewModel.status)
//        .animation(.easeInOut(duration: 0.25), value: viewModel.isSessionComplete)
//    }
//
//    private func incorrectToast(expectedWord: QuranWord) -> some View {
//        let spoken = viewModel.lastSpokenText ?? "..."
//        let displayCorrection = viewModel.getDisplayCorrection(for: expectedWord)
//
//        return HStack(spacing: 14) {
//            Image(systemName: "xmark.circle.fill").foregroundColor(.red)
//            Text("محاولة \(viewModel.attemptCount)").font(.caption2).foregroundColor(.secondary)
//            VStack(spacing: 2) {
//                Text("ما قلته").font(.caption2).foregroundColor(.secondary)
//                Text(spoken).font(.system(size: 18, weight: .bold)).foregroundColor(.orange)
//            }
//            Image(systemName: "arrow.left").font(.caption2).foregroundColor(.secondary)
//            VStack(spacing: 2) {
//                Text("الصحيحة").font(.caption2).foregroundColor(.secondary)
//                Text(displayCorrection).font(.system(size: 20, weight: .bold)).foregroundColor(.green)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 10)
//        .background(.ultraThinMaterial, in: Capsule())
//        .shadow(radius: 6)
//    }
//
//    private var correctToast: some View {
//        HStack(spacing: 8) {
//            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
//            Text("صحيح").font(.subheadline).bold().foregroundColor(.green)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 10)
//        .background(.ultraThinMaterial, in: Capsule())
//        .shadow(radius: 6)
//    }
//
//    private var completionBanner: some View {
//        VStack {
//            Spacer()
//            VStack(spacing: 12) {
//                Image(systemName: "star.circle.fill").font(.system(size: 44)).foregroundColor(.yellow)
//                Text("أحسنت! انتهت الجلسة").font(.title3).bold()
//            }
//            .padding(24)
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
//            .shadow(radius: 10)
//            Spacer()
//        }
//    }
//
//    @ViewBuilder
//    private func lineView(for line: MushafLine) -> some View {
//        switch line.lineType {
//        case .ayah:
//            HStack(spacing: 4) {
//                ForEach(line.words, id: \.id) { (word: QuranWord) in
//                    let isRevealed = word.id <= viewModel.lastRevealedWordId
//                    let isEndSymbol = word.wordPosition == 0
//                    let shouldShow = isRevealed || isEndSymbol
//                    let isHidden = !shouldShow
//
//                    Text(word.text)
//                        .font(pageFont(size: 22))
//                        .opacity(isHidden ? 0.0 : 1.0)
//                        .overlay(
//                            Group {
//                                if isHidden {
//                                    HStack(spacing: 2) {
//                                        ForEach(0..<3, id: \.self) { _ in
//                                            Circle().fill(Color.secondary.opacity(0.3)).frame(width: 4, height: 4)
//                                        }
//                                    }
//                                }
//                            }
//                        )
//                        .animation(.easeInOut(duration: 0.3), value: isRevealed)
//                }
//            }
//            .frame(maxWidth: .infinity)
//
//        case .surahName:
//            Text(SurahNames.name(for: line.surahNumber ?? 0))
//                .font(.system(size: 16, weight: .bold))
//
//        case .basmallah:
//            Text("\u{FDFD}").font(pageFont(size: 22))
//        }
//    }
//
//    private func pageFont(size: CGFloat) -> Font {
//        if let fontName { return .custom(fontName, size: size) }
//        return .system(size: size)
//    }
//}
