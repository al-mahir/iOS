//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let surfaceSand = Color(hex: "#F2F2F2")
    let inkColor = Color(hex: "#1A2421")
    let emeraldColor = Color(hex: "#0E5A47")
    let mistakeRed = Color(hex: "#B5484D")
 
    public init() {}
 
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    Text("Settings")
                        .font(.custom("IBM Plex Sans Arabic", size: 24))
                        .fontWeight(.bold)
                        .foregroundColor(inkColor)
                        .frame(maxWidth: .infinity)
 
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Image(systemName: "chevron.left") // Changed for English LTR
                                        .foregroundColor(inkColor)
                                )
                        }
 
                        Spacer()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .background(Color.white)
 
                VStack(spacing: 0) {
                    
                    SettingsSectionHeader(title: "Quran Appearance", backgroundColor: surfaceSand)
                    SettingsRow(icon: "book", title: "Mushaf Layout") { viewModel.openMushafLayout() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "eye.slash", title: "Hidden Ayahs") { viewModel.openHiddenAyahs() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "highlighter", title: "Highlighting") { viewModel.openHighlighting() }
 
                    SettingsSectionHeader(title: "App Appearance", backgroundColor: surfaceSand)
                    SettingsRow(icon: "globe", title: "Language") { viewModel.openLanguageSettings() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "sun.max", title: "Theme") { viewModel.openThemeSettings() }
 
                    SettingsSectionHeader(title: "Notifications", backgroundColor: surfaceSand)
                    SettingsRow(icon: "bell", title: "Reminders") { viewModel.openReminders() }
 
                    SettingsSectionHeader(title: "Sounds & Haptics", backgroundColor: surfaceSand)
                    SettingsRow(icon: "info.circle", title: "Mistakes") { viewModel.openMistakesSettings() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "mic", title: "Start & Stop Session") { viewModel.openSessionControls() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "wifi.slash", title: "Connection Loss") { viewModel.openConnectionLoss() }
 
                    SettingsSectionHeader(title: "Downloads", backgroundColor: surfaceSand)
                    SettingsRow(icon: "headphones", title: "Reciters") { viewModel.openReciters() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "textformat.alt", title: "Translation") { viewModel.openTranslations() }
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "book.closed", title: "Tafsir") { viewModel.openTafsir() }
 
                    SettingsSectionHeader(title: "Privacy", backgroundColor: surfaceSand)
                    SettingsRow(icon: "lock", title: "Data Usage") { viewModel.openDataUsage() }
                    Divider().padding(.leading, 50)
                    SettingsRow(
                        icon: "minus",
                        title: "Delete All Recordings",
                        titleColor: mistakeRed,
                        iconColor: mistakeRed
                    ) {
                        viewModel.requestDeleteAllRecordings()
                    }
                }
                .background(Color.white)
                
                VStack {
                    Text("Al-Mahir Version 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 30)
                }
                .frame(maxWidth: .infinity)
                .background(surfaceSand)
            }
        }
        .background(surfaceSand.ignoresSafeArea())
        .navigationBarHidden(true)
        .alert(isPresented: $viewModel.showDeleteRecordingsAlert) {
            Alert(
                title: Text("Delete Recordings"),
                message: Text("Are you sure you want to delete all recordings? This action cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    viewModel.executeDeleteAllRecordings()
                },
                secondaryButton: .cancel(Text("Cancel"))
            )
        }
    }
}
 
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
 
#Preview {
    SettingsView()
}
