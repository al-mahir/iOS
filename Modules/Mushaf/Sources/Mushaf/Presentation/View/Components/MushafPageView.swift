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

    @State private var calibratedFontSize: CGFloat?

    private let horizontalPadding: CGFloat = 4
    private let verticalPadding: CGFloat = 8

    var body: some View {
        GeometryReader { geometry in
            let containerSize = CGSize(
                width: geometry.size.width - horizontalPadding * 2,
                height: geometry.size.height - verticalPadding * 2
            )
            let fontSize = calibratedFontSize ?? 24
            let lineSpacing = -(fontSize * 0.1)

            VStack(spacing: lineSpacing) {
                ForEach(page.lines) { line in
                    lineView(for: line, fontSize: fontSize)
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .onAppear {
                if calibratedFontSize == nil {
                    calibratedFontSize = calculateFontSize(containerSize: containerSize)
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
                .minimumScaleFactor(0.97) // rounding safety net only
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

        case .surahName:
            Text(SurahNames.name(for: line.surahNumber ?? 0))
                .font(.system(size: fontSize * 0.4, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
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

    private func calculateFontSize(
        containerSize: CGSize,
        referenceSize: CGFloat = 100,
        minSize: CGFloat = 8,
        maxSize: CGFloat = 60
    ) -> CGFloat {
        let ctFont: CTFont = CTFontCreateWithName((fontName ?? "Helvetica") as CFString, referenceSize, nil)

        let ayahLines = page.lines.filter { $0.lineType == .ayah && !$0.words.isEmpty }
        var widestWidth: CGFloat = 0
        for line in ayahLines {
            widestWidth = max(widestWidth, measureWidth(of: ayahText(line), font: ctFont))
        }
        let widthScale = widestWidth > 0 ? containerSize.width / widestWidth : .greatestFiniteMagnitude

    
        let referenceLineHeight = CTFontGetAscent(ctFont) + CTFontGetDescent(ctFont) + CTFontGetLeading(ctFont)
        let referenceLineSpacing = referenceSize * 0.1
        let lineCount = CGFloat(max(page.lines.count, 1))

        let totalHeightAtReference = (lineCount * referenceLineHeight - (lineCount - 1) * referenceLineSpacing) * 1.05
        let heightScale = totalHeightAtReference > 0 ? containerSize.height / totalHeightAtReference : .greatestFiniteMagnitude

        let scale = min(widthScale, heightScale)
        return min(max(referenceSize * scale, minSize), maxSize)
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
