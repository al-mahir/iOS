import SwiftUI
import Common

public struct MuallimSetupView: View {
    @ObservedObject var viewModel: MuallimViewModel
    @Environment(\.dsColors) private var dsColors
    @Environment(\.layoutDirection) private var layoutDirection
    
    @State private var selectedSurah = 1
    @State private var selectedSurahName = "Al-Fatihah"
    @State private var selectedSurahArabicName = "الفاتحة"
    @State private var selectedSurahAyahCount = 7
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
            Text("Teacher Mode Setup", bundle: .module, comment: "Header title for setup view")
                .dsFont(DSTypography.headlineMedium)
                .foregroundColor(dsColors.textPrimary)
                .padding(.top, DSSpacing.lg)
            
            VStack(spacing: DSSpacing.lg) {
                // 1. Surah Selection
                setupSection("Surah Selection") {
                    Button(action: { showSurahPicker = true }) {
                        HStack {
                            let surahDisplayName = layoutDirection == .rightToLeft ? selectedSurahArabicName : selectedSurahName
                            
                            Text("Surah \(surahDisplayName)", bundle: .module, comment: "Selected Surah format string")
                                .dsFont(DSTypography.bodyLarge)
                                .foregroundColor(dsColors.textPrimary)
                            
                            Spacer()
                            
                            if layoutDirection != .rightToLeft {
                                Text(selectedSurahArabicName)
                                    .dsArabicFont(DSTypography.titleMedium)
                                    .foregroundColor(dsColors.primary)
                            }
                            
                            Image(systemName: layoutDirection == .rightToLeft ? "chevron.backward" : "chevron.forward")
                                .foregroundColor(dsColors.textSecondary)
                        }
                        .padding(DSSpacing.md)
                        .background(dsColors.surfaceContainerLow)
                        .cornerRadius(DSRadius.md)
                    }
                    .buttonStyle(.plain)
                }
                
                // 2. Verse Range
                setupSection("Verse Range") {
                    HStack(spacing: DSSpacing.md) {
                        VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: DSSpacing.xs) {
                            Text("From Ayah", bundle: .module, comment: "Label for starting Ayah stepper")
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
                        
                        VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: DSSpacing.xs) {
                            Text("To Ayah", bundle: .module, comment: "Label for ending Ayah stepper")
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
                
                // 3. Repetitions
                setupSection("Repetitions") {
                    Picker("Repetitions", selection: $repetitions) {
                        Text("1x", bundle: .module, comment: "Repetition count 1x").tag(1)
                        Text("3x", bundle: .module, comment: "Repetition count 3x").tag(3)
                        Text("5x", bundle: .module, comment: "Repetition count 5x").tag(5)
                        Text("10x", bundle: .module, comment: "Repetition count 10x").tag(10)
                    }
                    .pickerStyle(.segmented)
                }
                
                // 4. Strictness
                setupSection("Strictness") {
                    Picker("Strictness", selection: $viewModel.selectedStrictness) {
                        Text("Lenient", bundle: .module, comment: "Strictness option lenient").tag(RecitationStrictness.lenient)
                        Text("Normal", bundle: .module, comment: "Strictness option normal").tag(RecitationStrictness.normal)
                        Text("Strict", bundle: .module, comment: "Strictness option strict").tag(RecitationStrictness.strict)
                    }
                    .pickerStyle(.segmented)
                }
                
                // 5. Server Connection Status
                setupSection("Server Status") {
                    HStack(spacing: DSSpacing.sm) {
                        Circle()
                            .fill(viewModel.isServerConnected ? dsColors.success : dsColors.error)
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: 2) {
                            if viewModel.isServerConnected {
                                Text("Connected", bundle: .module, comment: "Server status connected")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)
                            } else {
                                Text("Disconnected", bundle: .module, comment: "Server status disconnected")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)
                            }
                            
                            if let engine = viewModel.healthInfo?.defaultEngine {
                                Text("Engine: \(engine)", bundle: .module, comment: "Server engine name label")
                                    .dsFont(DSTypography.labelSmall)
                                    .foregroundColor(dsColors.textSecondary)
                            }
                        }
                    }
                    .padding(DSSpacing.md)
                    .frame(maxWidth: .infinity, alignment: layoutDirection == .rightToLeft ? .trailing : .leading)
                    .background(dsColors.surfaceContainerLow)
                    .cornerRadius(DSRadius.sm)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            
            AppButton(title: String(localized: "Start Session", bundle: .module, comment: "Button title to start practice session")) {
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
                .cornerRadius(DSRadius.xl)
                .shadow(color: Color.black.opacity(0.15), radius: 20, y: -5)
                .ignoresSafeArea()
        )
        .sheet(isPresented: $showSurahPicker) {
            MuallimSurahPickerSheet(
                selectedSurah: $selectedSurah,
                selectedSurahName: $selectedSurahName,
                selectedSurahArabicName: $selectedSurahArabicName,
                selectedSurahAyahCount: $selectedSurahAyahCount
            )
        }
        .onChange(of: selectedSurah) { _ in
            startAyah = 1
            let maxDefaultAyah = min(7, selectedSurahAyahCount)
            endAyah = maxDefaultAyah
        }
    }
    
    private func setupSection<Content: View>(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: layoutDirection == .rightToLeft ? .trailing : .leading, spacing: DSSpacing.sm) {
            Text(titleKey, bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
            
            content()
        }
    }
}
