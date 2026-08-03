//
//  WordHighlightOverlay.swift
//  Reading
//
//  Renders one glyph-rendered muṣḥaf word plus its live recitation status.
//  Business rules encoded here (see API.md §3):
//   - .hint (`almost`) gets a soft dotted underline only — never the solid
//     red used for a real error.
//   - .neutral (`trimmed`) gets no color treatment at all.
//

import SwiftUI

public struct WordHighlightOverlay: View {
    let word: AyahWord
    let status: WordHighlightStatus
    let errors: [TajweedError]

    @State private var showErrorDetail = false
    
    public init(word: AyahWord, status: WordHighlightStatus, errors: [TajweedError], showErrorDetail: Bool = false) {
        self.word = word
        self.status = status
        self.errors = errors
        self.showErrorDetail = showErrorDetail
    }
    public var body: some View {
        Text(word.glyphCodePoint.isEmpty ? word.text : word.glyphCodePoint)
            .font(.custom("QCF_P" /* page-specific QPC v4 font family */, size: 26))
            .foregroundStyle(foregroundColor)
            .overlay(underline, alignment: .bottom)
            .padding(.horizontal, 2)
            .contentShape(Rectangle())
            .onTapGesture {
                guard !errors.isEmpty else { return }
                showErrorDetail.toggle()
            }
            .popover(isPresented: $showErrorDetail) {
                errorDetailList
                    .padding()
                    .frame(minWidth: 200)
            }
            .accessibilityLabel(word.text)
            .accessibilityHint(accessibilityHint)
    }

    private var foregroundColor: Color {
        switch status {
        case .none, .neutral, .hint:
            return .primary
        case .correct:
            return .green
        case .error:
            return .red
        }
    }

    @ViewBuilder
    private var underline: some View {
        switch status {
        case .hint:
            // Soft hint: a dotted underline, distinct from the solid error
            // treatment, per the "never a hard error" rule.
            Rectangle()
                .fill(Color.orange.opacity(0.7))
                .frame(height: 2)
                .mask(
                    HStack(spacing: 2) {
                        ForEach(0..<6, id: \.self) { _ in
                            Rectangle().frame(width: 2)
                        }
                    }
                )
        case .error:
            Rectangle().fill(Color.red).frame(height: 2)
        default:
            EmptyView()
        }
    }

    private var accessibilityHint: String {
        switch status {
        case .correct: return "Recited correctly"
        case .error: return "Mistake detected"
        case .hint: return "Possible mistake, low confidence"
        case .neutral, .none: return ""
        }
    }

    private var errorDetailList: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(errors) { error in
                Text(error.message)
                    .font(.footnote)
            }
        }
    }
}
