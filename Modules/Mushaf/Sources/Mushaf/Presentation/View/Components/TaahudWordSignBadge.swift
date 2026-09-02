//
//  TaahudWordSignBadge.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 05/08/2026.
//

import SwiftUI
import Taahud

struct TaahudWordSignBadge: View {
    let status: WordHighlightStatus
    let errors: [TajweedError]

    var body: some View {
        switch status {
        case .error:
            badge(systemImage: symbol, color: .red)
        case .hint:
            badge(systemImage: symbol, color: .orange)
        case .correct, .neutral, .none:
            EmptyView()
        }
    }

    private func badge(systemImage: String, color: Color) -> some View {
        Image(systemName: systemImage)
            .font(.system(size: 8, weight: .bold))
            .foregroundColor(.white)
            .padding(3)
            .background(Circle().fill(color))
            .overlay(Circle().stroke(Color.white, lineWidth: 1))
            .shadow(color: .black.opacity(0.15), radius: 1, y: 0.5)
    }

    private var symbol: String {
        guard let rule = errors.first?.rule.lowercased() else {
            return status == .error ? "xmark" : "questionmark"
        }
        if rule.contains("madd") {
            return "arrow.left.and.right"
        }
        if rule.contains("ghonna") || rule.contains("ikhfa") || rule.contains("idgham") || rule.contains("idghaam") {
            return "waveform"
        }
        if rule.contains("qalqalah") {
            return "bolt.fill"
        }
        return status == .error ? "xmark" : "questionmark"
    }
}
