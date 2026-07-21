//
//  MushafPageView.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import SwiftUI
import CoreText

struct MushafPageView: View {
    let page: MushafPage
    let fontName: String?
    var bottomInset: CGFloat = 0

    @State private var layout: PageLayout?
    @State private var isAtBottom = false
    @State private var contentHeight: CGFloat = 0

    private let horizontalPadding: CGFloat = 2
    private let verticalPadding: CGFloat = 6
    private let lineSpacingFactor: CGFloat = -0.65

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

                // MARK: - Scroll Indicator Arrow
                if !isAtBottom {
                    Button(action: {}) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color.black.opacity(0.4), in: Circle())
                            .shadow(radius: 4)
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
    }

    private func updateScrollState(contentHeight: CGFloat, visibleHeight: CGFloat, minY: CGFloat) {
        // If content fits completely within viewable height, hide arrow immediately
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
            Text(ayahText(line))
                .font(pageFont(size: fontSize))
                .lineLimit(1)
                .minimumScaleFactor(0.97)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

        case .surahName:
            Text(SurahNames.name(for: line.surahNumber ?? 0))
                .font(.system(size: fontSize * 0.4, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
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

    private func pageFont(size: CGFloat) -> Font {
        if let fontName {
            return .custom(fontName, size: size)
        }
        return .system(size: size)
    }

    private func ayahText(_ line: MushafLine) -> String {
        line.words.map(\.text).joined(separator: " ")
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
