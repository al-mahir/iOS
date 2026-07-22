//
//  MushafPageView.swift
//  Mushaf
//

import SwiftUI
import CoreText
import Common

struct MushafPageView: View {
    let page: MushafPage
    let fontName: String?
    var bottomInset: CGFloat = 0
    var targetAyahNumber: Int? = nil

    @Environment(\.dsColors) private var dsColors

    @State private var layout: PageLayout?
    @State private var isAtBottom = false
    @State private var highlightOpacity: Double = 1

    private let horizontalPadding: CGFloat = 2
    private let verticalPadding: CGFloat = 6
    private let lineSpacingFactor: CGFloat = -0.65

    private let highlightHeightFactor: CGFloat = 0.8

    private struct PageLayout {
        let fontSize: CGFloat
        let lineSpacing: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - bottomInset
            let containerSize = CGSize(
                width: geometry.size.width - horizontalPadding * 2,
                height: max(availableHeight - verticalPadding * 2, 0)
            )
            let resolved = layout ?? PageLayout(fontSize: 24, lineSpacing: 24 * lineSpacingFactor)

            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: resolved.lineSpacing) {
                        ForEach(page.lines) { line in
                            lineView(for: line, fontSize: resolved.fontSize)
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, verticalPadding)
                    .padding(.bottom, bottomInset)
                    .background(
                        GeometryReader { contentGeo in
                            Color.clear
                                .onAppear {
                                    updateScrollState(contentHeight: contentGeo.size.height, visibleHeight: geometry.size.height, minY: contentGeo.frame(in: .named("scroll")).minY)
                                }
                                .onChange(of: contentGeo.frame(in: .named("scroll")).minY) { minY in
                                    updateScrollState(contentHeight: contentGeo.size.height, visibleHeight: geometry.size.height, minY: minY)
                                }
                        }
                    )
                }
                .coordinateSpace(name: "scroll")

                if !isAtBottom {
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
            .environment(\.layoutDirection, .rightToLeft)
            .onAppear {
                if layout == nil {
                    layout = calculateLayout(containerSize: containerSize)
                }
            }
        }
        .id(fontName)
        // Highlight flashes in, holds briefly, then fades — restarts
        // whenever the target ayah changes (e.g. navigating to a new one).
        .task(id: targetAyahNumber) {
            guard targetAyahNumber != nil else { return }
            highlightOpacity = 1
            try? await Task.sleep(nanoseconds: 4_500_000_000)
            withAnimation(.easeOut(duration: 0.8)) {
                highlightOpacity = 0
            }
        }
    }

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
            Text(SurahNames.name(for: line.surahNumber ?? 0))
                .font(.system(size: fontSize * 0.4, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(dsColors.outlineVariant, lineWidth: 1)
                )

        case .basmallah:
            Text("\u{FDFD}")
                .font(pageFont(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.9)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
    }

    /// One word, rendered independently so its highlight can be sized and
    /// animated separately from the font's own line-height box.
    @ViewBuilder
    private func wordView(_ word: QuranWord, fontSize: CGFloat) -> some View {
        Text(word.text)
            .font(pageFont(size: fontSize))
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
                }
            }
    }

    private func spaceWidth(fontSize: CGFloat) -> CGFloat {
        let ctFont = CTFontCreateWithName((fontName ?? "Helvetica") as CFString, fontSize, nil)
        return measureWidth(of: " ", font: ctFont)
    }

    // Used only for layout calibration (measuring the full line's width).
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
        let attributed = NSAttributedString(string: text, attributes: [kCTFontAttributeName as NSAttributedString.Key: font])
        let line = CTLineCreateWithAttributedString(attributed)
        var ascent: CGFloat = 0
        var descent: CGFloat = 0
        var leading: CGFloat = 0
        return CGFloat(CTLineGetTypographicBounds(line, &ascent, &descent, &leading))
    }
}
