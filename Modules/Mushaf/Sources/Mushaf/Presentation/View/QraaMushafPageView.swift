import SwiftUI

struct QraaMushafPageView: View {
    let page: MushafPage
    let fontName: String?
    var bottomInset: CGFloat = 0
    
    @ObservedObject var qraaManager: QraaManager
    @Environment(\.dsColors) private var dsColors
    
    // Store the spoken text when error occurs
    @State private var spokenText: String = ""

    var body: some View {
        ZStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    ForEach(page.lines) { line in
                        lineView(for: line)
                    }
                }
                .padding(.bottom, bottomInset)
            }
            
            // Error overlay popup showing both what you said and the correct word
            if case .incorrect(let expectedWord) = qraaManager.status {
                VStack(spacing: 16) {
                    // Error icon
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.red)
                    
                    // Show attempt count - now accessible
                    Text("محاولة \(qraaManager.attemptCount)/3")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.secondary.opacity(0.1))
                        )
                    
                    VStack(spacing: 8) {
                        // What you said
                        VStack(spacing: 4) {
                            Text("ما قلته:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(spokenText.isEmpty ? "..." : spokenText)
                                .font(pageFont(size: 24))
                                .foregroundColor(.orange)
                                .bold()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                )
                        }
                        
                        // Arrow down
                        Image(systemName: "arrow.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // Correct word
                        VStack(spacing: 4) {
                            Text("الكلمة الصحيحة:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(expectedWord.text)
                                .font(pageFont(size: 28))
                                .foregroundColor(.green)
                                .bold()
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.green.opacity(0.1))
                                )
                        }
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
                .onAppear {
                    // Get the spoken text from the last recognition result
                    if let lastSpoken = qraaManager.lastSpokenText {
                        spokenText = lastSpoken
                    }
                }
            }
            
            // Success overlay (optional)
            if case .correct = qraaManager.status {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.green)
                    
                    Text("✓ صحيح!")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.green)
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
                .shadow(radius: 10)
                .transition(.scale.combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    private func lineView(for line: MushafLine) -> some View {
        switch line.lineType {
        case .ayah:
            HStack(spacing: 4) {
                ForEach(line.words, id: \.id) { (word: QuranWord) in
                    let isRevealed = word.id <= qraaManager.lastRevealedWordId
                    let isEndSymbol = word.wordPosition == 0
                    let isHidden = !isRevealed && !isEndSymbol
                    
                    Text(word.text)
                        .font(pageFont(size: 22))
                        .foregroundColor(dsColors.textPrimary)
                        .opacity(isHidden ? 0.0 : 1.0)
                        .overlay(
                            Group {
                                if isHidden {
                                    // Show placeholder dots for hidden words
                                    HStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            Circle()
                                                .fill(dsColors.textSecondary.opacity(0.3))
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                }
                            }
                        )
                        .animation(.easeInOut(duration: 0.3), value: isRevealed)
                }
            }
            .frame(maxWidth: .infinity)

        case .surahName:
            Text(SurahNames.name(for: line.surahNumber ?? 0))
                .font(.system(size: 16, weight: .bold))

        case .basmallah:
            Text("\u{FDFD}")
                .font(pageFont(size: 22))
        }
    }

    private func pageFont(size: CGFloat) -> Font {
        if let fontName { return .custom(fontName, size: size) }
        return .system(size: size)
    }
}
