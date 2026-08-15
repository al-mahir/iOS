//
//  WordHighlightOverlay.swift
//  Taahud

import SwiftUI

public struct WordHighlightOverlay: View {
    let word: AyahWord
    let status: WordHighlightStatus
    let errors: [TajweedError]

    @State private var showErrorDetail = false

    public var body: some View {
        Text(word.glyphCodePoint.isEmpty ? word.text : word.glyphCodePoint)
            .font(.custom("QCF_P", size: 26))
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
        case .correct:
            return String(
                localized: "Recited correctly",
                comment: "Accessibility hint when word is recited correctly"
            )
        case .error:
            return String(
                localized: "Mistake detected",
                comment: "Accessibility hint when a recitation error is found"
            )
        case .hint:
            return String(
                localized: "Possible mistake, low confidence",
                comment: "Accessibility hint when a possible mistake is flagged with low confidence"
            )
        case .neutral, .none:
            return ""
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
