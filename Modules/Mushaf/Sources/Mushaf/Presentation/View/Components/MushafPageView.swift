//
//  MushafPageView.swift
//  Mushaf
//

import SwiftUI
import CoreText
import Common
import Tafsir
import Taahud

struct MushafPageView: View {
    let page: MushafPage
    let fontName: String?
    var bottomInset: CGFloat = 0
    var targetAyahNumber: Int? = nil
    var highlightedWordKey: String? = nil
    var isSurahBookmarked: ((Int) -> Bool)? = nil
    var isAyahBookmarked: ((Int, Int) -> Bool)? = nil
    var isTajweedEnabled: Bool = true
    var isCurrentPage: Bool = true
    var isTextHidden: Bool = false
    var currentStep: Int = 0
    var onNextStep: (() -> Void)? = nil
    var onBookmarkSurah: ((Int) -> Void)? = nil
    var onBookmarkAyah: ((_ surah: Int, _ ayah: Int, _ arabicText: String, _ surahName: String) -> Void)? = nil

    // MARK: - Taahud (live AI recitation correction)
    /// Per-word live status from Taahud, keyed the same way as
    /// `highlightedWordKey` ("surah:ayah:wordPosition"). Empty outside of
    /// AI-correction mode — callers only need to pass these two in.
    var taahudWordStatuses: [String: WordHighlightStatus] = [:]
    var taahudWordErrors: [String: [TajweedError]] = [:]
    /// Called when the user taps a word that Taahud has flagged (has one or
    /// more errors attached), so the host can show the explanation.
    var onTaahudWordTapped: ((QuranWord, [TajweedError]) -> Void)? = nil

    @Environment(\.dsColors) private var dsColors
    @Environment(\.colorScheme) private var colorScheme

    @State private var layout: PageLayout?
    @State private var isAtBottom = false
    @State private var highlightOpacity: Double = 1
    @State private var selectedAyah: (surah: Int, ayah: Int)? = nil

    private let horizontalPadding: CGFloat = 2
    private let verticalPadding: CGFloat = 6
    private let lineSpacingFactor: CGFloat = -0.65
    private let highlightHeightFactor: CGFloat = 0.8

    private struct PageLayout {
        let fontSize: CGFloat
        let lineSpacing: CGFloat
    }

    private var firstAyahLineIndex: Int? {
        page.lines.firstIndex { $0.lineType == .ayah && !$0.words.isEmpty }
    }

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - bottomInset
            let containerSize = CGSize(
                width: geometry.size.width - horizontalPadding * 2,
                height: max(availableHeight - verticalPadding * 2, 0)
            )
            let resolved = layout ?? PageLayout(fontSize: 24, lineSpacing: 24 * lineSpacingFactor)

            ZStack(alignment: .top) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: resolved.lineSpacing) {
                        ForEach(page.lines.indices, id: \.self) { index in
                            let line = page.lines[index]
                            lineView(for: line, fontSize: resolved.fontSize)
                                .modifier(
                                    AyahAnchorModifier(
                                        isTarget: isCurrentPage && index == firstAyahLineIndex
                                    )
                                )
                        }
                    }
                    .modifier(QuranTextDarkModeModifier(isDarkMode: colorScheme == .dark, isTajweed: isTajweedEnabled))
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .padding(.bottom, bottomInset)
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear
                                .onAppear {
                                    updateScrollState(
                                        contentHeight: contentGeo.size.height,
                                        visibleHeight: geometry.size.height,
                                        minY: contentGeo.frame(in: .named("scroll")).minY
                                    )
                                }
                                .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { _, minY in
                                    updateScrollState(
                                        contentHeight: contentGeo.size.height,
                                        visibleHeight: geometry.size.height,
                                        minY: minY
                                    )
                                }
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .scrollDisabled(isCurrentPage && currentStep != 0)

                if !isAtBottom {
                    VStack {
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(dsColors.inverseOnSurface)
                                .padding(10)
                                .background(dsColors.inverseSurface.opacity(0.85), in: Circle())
                                .shadow(color: dsColors.shadow.opacity(0.25), radius: 4, y: 2)
                        }
                        .padding(.bottom, bottomInset + 20)
                        .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .sheet(isPresented: Binding(
                get: { selectedAyah != nil },
                set: { isPresented in if !isPresented { selectedAyah = nil } }
            )) {
                if let selection = selectedAyah {
                    TafseerSheet(
                        surah: selection.surah,
                        ayah: selection.ayah,
                        arabicText: arabicText(forSurah: selection.surah, ayah: selection.ayah),
                        surahDisplayName: surahName(forSurah: selection.surah),
                        isAyahBookmarked: isAyahBookmarked?(selection.surah, selection.ayah) ?? false,
                        fontName: self.fontName,
                        onToggleBookmark: {
                            let arabic = arabicText(forSurah: selection.surah, ayah: selection.ayah)
                            let name = surahName(forSurah: selection.surah)
                            onBookmarkAyah?(selection.surah, selection.ayah, arabic, name)
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                }
            }
            .overlay {
                if isTextHidden {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            VStack(spacing: DSSpacing.xs) {
                                Image(systemName: "eye.slash")
                                    .font(.system(size: 26, weight: .semibold))
                                Text("Text hidden")
                                    .dsFont(DSTypography.bodySmall)
                            }
                            .foregroundColor(dsColors.textSecondary)
                        )
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isTextHidden)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                if layout == nil {
                    layout = calculateLayout(containerSize: containerSize)
                }
            }
            .onDisappear {
                selectedAyah = nil
            }
        }
        .id(fontName)
        .task(id: targetAyahNumber) {
            guard targetAyahNumber != nil else { return }
            highlightOpacity = 1
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            withAnimation(.easeOut(duration: 0.8)) {
                highlightOpacity = 0
            }
        }
    }

    // MARK: - Scroll helpers

    private func updateScrollState(contentHeight: CGFloat, visibleHeight: CGFloat, minY: CGFloat) {
        if contentHeight <= (visibleHeight - bottomInset) {
            if !isAtBottom { isAtBottom = true }
        } else {
            let isEnd = (contentHeight + minY - visibleHeight) <= 25
            if isAtBottom != isEnd {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isAtBottom = isEnd
                }
            }
        }
    }

    // MARK: - Line rendering

    @ViewBuilder
    private func lineView(for line: MushafLine, fontSize: CGFloat) -> some View {
        switch line.lineType {
        case .ayah:
            HStack(spacing: spaceWidth(fontSize: fontSize)) {
                ForEach(line.words) { word in
                    wordView(word, fontSize: fontSize)
                }
            }
            .frame(maxWidth: .infinity)

        case .surahName:
            let surahNumber = line.surahNumber ?? 0
            
            let displayName = MockDataService.shared.getAllSurahs()
                .first(where: { $0.id == surahNumber })?.arabicName ?? SurahNames.name(for: surahNumber)

            ZStack {
                Image("surah_frame", bundle: .module)
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(dsColors.primary)
                    .frame(height: 52)
                HStack(spacing: DSSpacing.sm) {
//                     Image(systemName: "bookmark")
//                        .font(.system(size: fontSize * 0.45, weight: .semibold))
//                        .opacity(0)
//                        .accessibilityHidden(true)
                    Spacer()
                    Text(displayName)
                        .dsArabicFont(DSTypography.titleLarge)
                        .foregroundColor(dsColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .padding(.bottom , 10)
                    Spacer()
//                     Image(systemName: (isSurahBookmarked?(surahNumber) ?? false) ? "bookmark.fill" : "bookmark")
//                        .font(.system(size: fontSize * 0.45, weight: .semibold))
//                        .foregroundColor(
//                            (isSurahBookmarked?(surahNumber) ?? false) ? dsColors.primary : dsColors.textTertiary
//                        )
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
//                            onBookmarkSurah?(surahNumber)
//                        }
                }
                .padding(.horizontal, DSSpacing.md)
                .frame(maxWidth: .infinity)
            }.padding(.vertical)

        case .basmallah:
            Text("\u{FDFD}")
                .font(pageFont(size: fontSize))
                .foregroundColor(dsColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Word rendering

    @ViewBuilder
    private func wordView(_ word: QuranWord, fontSize: CGFloat) -> some View {
        let wordKey = "\(word.surah):\(word.ayah):\(word.wordPosition)"
        let isActiveWord = highlightedWordKey == wordKey
        let isSelected = selectedAyah?.ayah == word.ayah && selectedAyah?.surah == word.surah
        let taahudStatus = taahudWordStatuses[wordKey] ?? .none
        let taahudErrors = taahudWordErrors[wordKey] ?? []

        Text(word.text)
            .font(pageFont(size: fontSize))
            .foregroundColor(dsColors.textPrimary)
            .lineLimit(1)
            .minimumScaleFactor(0.97)
            .fixedSize()
            .background(alignment: .center) {
                if word.ayah == targetAyahNumber {
                    RoundedRectangle(cornerRadius: DSRadius.xs)
                        .fill(dsColors.primary.opacity(0.18))
                        .frame(height: fontSize * highlightHeightFactor)
                        .opacity(highlightOpacity)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .animation(.easeInOut(duration: 0.3), value: targetAyahNumber)
                } else if isSelected {
                    RoundedRectangle(cornerRadius: DSRadius.xs)
                        .fill(dsColors.secondary.opacity(0.22))
                        .frame(height: fontSize * highlightHeightFactor)
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        .animation(.easeInOut(duration: 0.2), value: selectedAyah?.ayah)
                } else if taahudStatus == .correct {
                    // Confirms the word was recited correctly — a calm green
                    // wash, distinct from the amber "active target" tint.
                    RoundedRectangle(cornerRadius: DSRadius.xs)
                        .fill(Color.green.opacity(0.14))
                        .frame(height: fontSize * highlightHeightFactor)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: taahudStatus)
                }

                if isActiveWord {
                    RoundedRectangle(cornerRadius: DSRadius.sm)
                        .fill(
                            LinearGradient(
                                colors: [
                                    dsColors.primary.opacity(0.22),
                                    dsColors.primaryVariant.opacity(0.14)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: fontSize * highlightHeightFactor)
                        .shadow(color: dsColors.primary.opacity(0.15), radius: 3)
                        .transition(.opacity.combined(with: .scale(scale: 0.92)))
                }
            }
            .overlay(alignment: .bottom) {
                taahudUnderline(for: taahudStatus, fontSize: fontSize)
            }
            .overlay(alignment: .top) {
                if !taahudErrors.isEmpty {
                    TaahudWordSignBadge(status: taahudStatus, errors: taahudErrors)
                        .offset(y: -fontSize * 0.32)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeOut(duration: 0.2), value: taahudStatus)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                guard !taahudErrors.isEmpty else { return }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                onTaahudWordTapped?(word, taahudErrors)
            }
            .onLongPressGesture(minimumDuration: 0.35) {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                withAnimation(.easeOut(duration: 0.2)) {
                    selectedAyah = (surah: word.surah, ayah: word.ayah)
                }
            }
    }

    /// Underline treatment for a Taahud-flagged word. `.error` gets a solid
    /// red line; `.almost` (`.hint`) gets a dotted orange line — never solid
    /// red — per the strict "soft hint, never a hard error" rule. `.correct`,
    /// `.neutral` (trimmed), and `.none` get no underline at all.
    @ViewBuilder
    private func taahudUnderline(for status: WordHighlightStatus, fontSize: CGFloat) -> some View {
        switch status {
        case .error:
            Rectangle()
                .fill(Color.red)
                .frame(height: 2)
                .padding(.horizontal, 1)
        case .hint:
            Rectangle()
                .fill(Color.orange.opacity(0.8))
                .frame(height: 2)
                .mask(
                    HStack(spacing: 2) {
                        ForEach(0..<6, id: \.self) { _ in Rectangle().frame(width: 2) }
                    }
                )
                .padding(.horizontal, 1)
        case .correct, .neutral, .none:
            EmptyView()
        }
    }

    // MARK: - Helpers

    private func surahName(forSurah surahNumber: Int) -> String {
        SurahNames.name(for: surahNumber)
    }

    private func arabicText(forSurah surah: Int, ayah: Int) -> String {
        var words: [QuranWord] = []
        for line in page.lines {
            for word in line.words where word.surah == surah && word.ayah == ayah {
                words.append(word)
            }
        }
        return words.map(\.text).joined(separator: " ")
    }

    private func spaceWidth(fontSize: CGFloat) -> CGFloat {
        let ctFont = CTFontCreateWithName((fontName ?? "Helvetica") as CFString, fontSize, nil)
        return measureWidth(of: " ", font: ctFont)
    }

    private func ayahText(_ line: MushafLine) -> String {
        line.words.map(\.text).joined(separator: " ")
    }

    private func pageFont(size: CGFloat) -> Font {
        if let fontName {
            return .custom(fontName, size: size)
        }
        return .system(size: size)
    }

    private func calculateLayout(
        containerSize: CGSize,
        referenceSize: CGFloat = 100,
        minSize: CGFloat = 8,
        maxSize: CGFloat = 80
    ) -> PageLayout {
        let ctFont: CTFont = CTFontCreateWithName((fontName ?? "Helvetica") as CFString, referenceSize, nil)

        let ayahLines = page.lines.filter { $0.lineType == .ayah && !$0.words.isEmpty }
        var widestWidth: CGFloat = 0
        for line in ayahLines {
            widestWidth = max(widestWidth, measureWidth(of: ayahText(line), font: ctFont))
        }

        let fontSize: CGFloat = widestWidth > 0
            ? min(max(referenceSize * (containerSize.width / widestWidth), minSize), maxSize)
            : min(max(referenceSize, minSize), maxSize)

        let baseLineSpacing = fontSize * lineSpacingFactor
        let referenceLineHeight = CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
        let lineHeight = referenceLineHeight * (fontSize / referenceSize)
        let lineCount = CGFloat(max(page.lines.count, 1))

        let naturalContentHeight = lineCount * lineHeight + max(lineCount - 1, 0) * baseLineSpacing
        let leftover = max(0, containerSize.height - naturalContentHeight)
        let extraPerGap = lineCount > 1 ? leftover / (lineCount - 1) : 0

        return PageLayout(fontSize: fontSize, lineSpacing: baseLineSpacing + extraPerGap)
    }

    private func measureWidth(of text: String, font: CTFont) -> CGFloat {
        let attributed = NSAttributedString(
            string: text,
            attributes: [kCTFontAttributeName as NSAttributedString.Key: font]
        )
        let line = CTLineCreateWithAttributedString(attributed)
        var ascent: CGFloat = 0, descent: CGFloat = 0, leading: CGFloat = 0
        return CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
    }
}

private struct AyahAnchorModifier: ViewModifier {
    let isTarget: Bool

    func body(content: Content) -> some View {
        if isTarget {
            content.tooltipAnchor(2)
        } else {
            content
        }
    }
}

private struct QuranTextDarkModeModifier: ViewModifier {
    let isDarkMode: Bool
    let isTajweed: Bool

    func body(content: Content) -> some View {
        if isDarkMode && isTajweed {
            content
                .colorInvert()
                .hueRotation(.degrees(180))
        } else {
            content
        }
    }
}
