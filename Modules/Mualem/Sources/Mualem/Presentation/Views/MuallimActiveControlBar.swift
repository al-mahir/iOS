//
//  MuallimActiveControlBar.swift
//  Mualem
//

import SwiftUI
import Common

public struct MuallimActiveControlBar: View {
    @ObservedObject var viewModel: MuallimViewModel
    @Environment(\.dsColors) private var dsColors
    
    public init(viewModel: MuallimViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.sm) {
            
            // Mistake feedback banner
            if case .feedback(let mistakes) = viewModel.currentState, !mistakes.isEmpty {
                VStack(alignment: .leading, spacing: DSSpacing.xs) {
                    Text("Mistakes Detected")
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(dsColors.error)
                    
                    ForEach(mistakes, id: \.id) { mistake in
                        Text("• \(mistake.description)")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.error)
                    }
                }
                .padding(DSSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(dsColors.error.opacity(0.1))
                .cornerRadius(DSRadius.sm)
                .padding(.horizontal, DSSpacing.md)
            }
            
            HStack {
                // Status icon and text
                HStack(spacing: DSSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(statusColor.opacity(0.2))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: statusIcon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(statusColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(statusText)
                            .dsFont(DSTypography.labelLarge)
                            .foregroundColor(dsColors.textPrimary)
                        
                        Text("Repeat: \(viewModel.currentRepetition) / \(viewModel.config?.repetitions ?? 1)")
                            .dsFont(DSTypography.bodySmall)
                            .foregroundColor(dsColors.textSecondary)
                    }
                }
                
                Spacer()
                
                // Stop Button
                Button(action: {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    viewModel.stopSession()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(dsColors.error)
                        .frame(width: 44, height: 44)
                        .background(dsColors.error.opacity(0.1), in: Circle())
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.vertical, DSSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(dsColors.background)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, y: 4)
            )
            .padding(.horizontal, DSSpacing.md)
            .padding(.bottom, DSSpacing.md)
        }
    }
    
    // MARK: - Computed Properties for Status
    
    private var statusIcon: String {
        switch viewModel.currentState {
        case .listening: return "speaker.wave.2.fill"
        case .recording: return "mic.fill"
        case .feedback(let mistakes): return mistakes.isEmpty ? "checkmark" : "exclamationmark.triangle.fill"
        case .completed: return "flag.checkered"
        default: return "ellipsis"
        }
    }
    
    private var statusText: String {
        switch viewModel.currentState {
        case .listening: return "Listening..."
        case .recording: return "Your turn..."
        case .feedback(let mistakes): return mistakes.isEmpty ? "Excellent!" : "Needs work"
        case .completed: return "Session Complete!"
        default: return "Ready"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.currentState {
        case .listening: return dsColors.info
        case .recording: return dsColors.error
        case .feedback(let mistakes): return mistakes.isEmpty ? dsColors.success : dsColors.warning
        case .completed: return dsColors.primary
        default: return dsColors.textSecondary
        }
    }
}
