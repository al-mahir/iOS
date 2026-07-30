//
//  MuallimSetupView.swift
//  Mualem
//

import SwiftUI
import Common

public struct MuallimSetupView: View {
    @ObservedObject var viewModel: MuallimViewModel
    @Environment(\.dsColors) private var dsColors
    
    @State private var selectedSurah = 2
    @State private var selectedSurahName = "Al-Baqarah"
    @State private var selectedSurahAyahCount = 286
    @State private var showSurahPicker = false
    @State private var startAyah = 1
    @State private var endAyah = 7
    @State private var repetitions = 3
    @State private var waitTimeMode: MuallimSessionConfig.WaitTimeMode = .qariPace
    
    public init(viewModel: MuallimViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: DSSpacing.xl) {
            
            // Header
            VStack(spacing: DSSpacing.sm) {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(dsColors.outlineVariant)
                    .frame(width: 40, height: 4)
                    .padding(.top, DSSpacing.sm)
                
                Text("Teacher Mode Setup")
                    .dsFont(DSTypography.headlineMedium)
                    .foregroundColor(dsColors.textPrimary)
                    .padding(.top, DSSpacing.sm)
            }
            
            VStack(spacing: DSSpacing.lg) {
                // Surah Selection
                setupSection(title: "Surah Selection") {
                    Button(action: { showSurahPicker = true }) {
                        HStack {
                            Text("Surah \(selectedSurahName)")
                                .dsFont(DSTypography.bodyLarge)
                                .foregroundColor(dsColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(dsColors.textSecondary)
                        }
                        .padding(DSSpacing.md)
                        .background(dsColors.surfaceContainerLow)
                        .cornerRadius(DSRadius.md)
                    }
                    .buttonStyle(.plain)
                }
                
                // Verse Range
                setupSection(title: "Verse Range") {
                    HStack(spacing: DSSpacing.md) {
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("From Ayah")
                                .dsFont(DSTypography.labelMedium)
                                .foregroundColor(dsColors.textSecondary)
                            Stepper("\(startAyah)", value: $startAyah, in: 1...selectedSurahAyahCount)
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(dsColors.surfaceContainerLow)
                                .cornerRadius(DSRadius.sm)
                                .onChange(of: startAyah) { newValue in
                                    if endAyah < newValue {
                                        endAyah = newValue
                                    }
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                            Text("To Ayah")
                                .dsFont(DSTypography.labelMedium)
                                .foregroundColor(dsColors.textSecondary)
                            Stepper("\(endAyah)", value: $endAyah, in: startAyah...selectedSurahAyahCount)
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xs)
                                .background(dsColors.surfaceContainerLow)
                                .cornerRadius(DSRadius.sm)
                        }
                    }
                }
                
                // Repetitions
                setupSection(title: "Repetitions") {
                    Picker("Repetitions", selection: $repetitions) {
                        Text("1x").tag(1)
                        Text("3x").tag(3)
                        Text("5x").tag(5)
                        Text("10x").tag(10)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .padding(.horizontal, DSSpacing.md)
            
            AppButton(title: "Start Session") {
                let config = MuallimSessionConfig(
                    surah: selectedSurah,
                    startAyah: startAyah,
                    endAyah: endAyah,
                    repetitions: repetitions,
                    qariId: "default",
                    waitTime: waitTimeMode
                )
                viewModel.startSession(config: config)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.bottom, DSSpacing.xl)
        }
        .background(
            dsColors.surface
                .cornerRadius(DSRadius.xl, corners: [.topLeft, .topRight])
                .shadow(color: Color.black.opacity(0.15), radius: 20, y: -5)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showSurahPicker) {
            MuallimSurahPickerSheet(selectedSurah: $selectedSurah, selectedSurahName: $selectedSurahName, selectedSurahAyahCount: $selectedSurahAyahCount)
        }
        .onChange(of: selectedSurah) { _ in
            startAyah = 1
            let maxDefaultAyah = min(7, selectedSurahAyahCount)
            endAyah = maxDefaultAyah
        }
    }
    
    private func setupSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text(title)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
            
            content()
        }
    }
}

// Helper for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
