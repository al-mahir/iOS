import SwiftUI
import Common

public struct MuallimActiveControlBar: View {
    @ObservedObject var viewModel: MuallimViewModel
    @Environment(\.dsColors) private var dsColors
    
    @State private var waveAnimation = false
    @State private var waveHeights: [CGFloat] = [8, 12, 16, 10]
    @State private var showExitConfirmation = false
    
    public init(viewModel: MuallimViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            
            if case .feedback = viewModel.currentState {
                Button(action: {
                    viewModel.showMistakesSheet = true
                }) {
                    HStack {
                        Image(systemName: "exclamationmark.magnifyingglass")
                        Text("View Mistakes")
                    }
                    .dsFont(DSTypography.labelMedium)
                    .foregroundColor(dsColors.error)
                    .padding(DSSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(dsColors.error.opacity(0.1))
                    .cornerRadius(DSRadius.sm)
                }
                .padding(.horizontal, DSSpacing.md)
            }
            
            HStack {
                HStack(spacing: DSSpacing.sm) {
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(statusColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Group {
                                    if viewModel.currentState == .evaluating {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: statusColor))
                                    } else if viewModel.currentState == .recording {
                                        waveformAnimation
                                    } else {
                                        Image(systemName: statusIcon)
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(statusColor)
                                    }
                                }
                            )
                        
                        Circle()
                            .fill(viewModel.isServerConnected ? dsColors.success : dsColors.warning)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().stroke(dsColors.background, lineWidth: 2))
                            .offset(x: 2, y: 2)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusText)
                            .dsFont(DSTypography.labelLarge)
                            .foregroundColor(dsColors.textPrimary)
                        
                        if viewModel.currentState == .recording {
                            Text("Ayah \(viewModel.currentAyahToProcess)")
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textSecondary)
                        } else {
                            Text("Repeat: \(viewModel.currentRepetition) / \(viewModel.config?.repetitions ?? 1)")
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textSecondary)
                        }
                    }
                }
                
                Spacer()
                
                HStack(spacing: DSSpacing.sm) {
                    if viewModel.currentState == .recording {
                        Button(action: {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            viewModel.finishRecording()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .bold))
                                Text("Done")
                                    .dsFont(DSTypography.labelMedium)
                            }
                            .foregroundColor(dsColors.onPrimary)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, 8)
                            .background(dsColors.primary, in: Capsule())
                        }
                    }
                    
                    Button(action: {
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        showExitConfirmation = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 13, weight: .bold))
                            Text("Exit")
                                .dsFont(DSTypography.labelMedium)
                        }
                        .foregroundColor(dsColors.error)
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, 8)
                        .background(dsColors.error.opacity(0.1), in: Capsule())
                    }
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.xl)
                    .fill(dsColors.background)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.bottom, DSSpacing.md)
        }
        .confirmationDialog(
            "End Session?",
            isPresented: $showExitConfirmation,
            titleVisibility: .visible
        ) {
            Button("End Session", role: .destructive) {
                viewModel.stopSession()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to stop this practice session?")
        }
        .onAppear {
            startWaveAnimation()
        }
        .onChange(of: viewModel.currentState) { _ in
            startWaveAnimation()
        }
    }
    
    private var waveformAnimation: some View {
        HStack(spacing: 3) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(statusColor)
                    .frame(width: 3, height: waveAnimation ? (CGFloat.random(in: 6...18)) : 8)
                    .animation(.easeInOut(duration: 0.3).repeatForever().delay(0.1 * Double(index)), value: waveAnimation)
            }
        }
    }
    
    private func startWaveAnimation() {
        if viewModel.currentState == .recording {
            waveAnimation = true
        } else {
            waveAnimation = false
        }
    }
    
    private var statusIcon: String {
        switch viewModel.currentState {
        case .listening: return "speaker.wave.2.fill"
        case .recording: return "mic.fill"
        case .evaluating: return "arrow.triangle.2.circlepath"
        case .feedback(let result): return result.overallStatus == .correct ? "checkmark" : "exclamationmark.triangle.fill"
        case .completed: return "flag.checkered"
        default: return "ellipsis"
        }
    }
    
    private var statusText: String {
        switch viewModel.currentState {
        case .listening: return "Listening..."
        case .recording: return "Your turn..."
        case .evaluating: return "Evaluating..."
        case .feedback(let result): return result.overallStatus == .correct ? "Excellent!" : "Needs work"
        case .completed: return "Session Complete!"
        default: return "Ready"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.currentState {
        case .listening: return dsColors.info
        case .recording: return dsColors.error
        case .evaluating: return dsColors.primary
        case .feedback(let result): return result.overallStatus == .correct ? dsColors.success : dsColors.warning
        case .completed: return dsColors.primary
        default: return dsColors.textSecondary
        }
    }
}
