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
    let tealColor = Color(hex: "#1A9370")
    let goldColor = Color(hex: "#D9A441")
    let blueColor = Color(hex: "#3E7CB1")
    let purpleColor = Color(hex: "#7B61A8")
    let mistakeRed = Color(hex: "#B5484D")
 
    public init() {}
 
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
 
                VStack(alignment: .leading, spacing: 4) {
 
                    SettingsSectionHeader(title: "Quran Appearance")
                    card {
                        SettingsRow(icon: "book", title: "Mushaf Layout", iconColor: emeraldColor) { viewModel.openMushafLayout() }
                        rowDivider
                        SettingsRow(icon: "eye.slash", title: "Hidden Ayahs", iconColor: emeraldColor) { viewModel.openHiddenAyahs() }
                        rowDivider
                        SettingsRow(icon: "highlighter", title: "Highlighting", iconColor: emeraldColor) { viewModel.openHighlighting() }
                    }
 
                    SettingsSectionHeader(title: "App Appearance")
                    card {
                        SettingsRow(icon: "globe", title: "Language", iconColor: tealColor) { viewModel.openLanguageSettings() }
                        rowDivider
                        SettingsRow(icon: "sun.max", title: "Theme", iconColor: tealColor) { viewModel.openThemeSettings() }
                    }
 
                    SettingsSectionHeader(title: "Notifications")
                    card {
                        SettingsRow(icon: "bell", title: "Reminders", iconColor: blueColor) { viewModel.openReminders() }
                    }
 
                    SettingsSectionHeader(title: "Sounds & Haptics")
                    card {
                        SettingsRow(icon: "info.circle", title: "Mistakes", iconColor: purpleColor) { viewModel.openMistakesSettings() }
                        rowDivider
                        SettingsRow(icon: "mic", title: "Start & Stop Session", iconColor: purpleColor) { viewModel.openSessionControls() }
                        rowDivider
                        SettingsRow(icon: "wifi.slash", title: "Connection Loss", iconColor: purpleColor) { viewModel.openConnectionLoss() }
                    }
 
                    SettingsSectionHeader(title: "Downloads")
                    card {
                        SettingsRow(icon: "headphones", title: "Reciters", iconColor: goldColor) { viewModel.openReciters() }
                        rowDivider
                        SettingsRow(icon: "textformat.alt", title: "Translation", iconColor: goldColor) { viewModel.openTranslations() }
                        rowDivider
                        SettingsRow(icon: "book.closed", title: "Tafsir", iconColor: goldColor) { viewModel.openTafsir() }
                    }
 
                    SettingsSectionHeader(title: "Privacy")
                    card {
                        SettingsRow(icon: "lock", title: "Data Usage", iconColor: .gray) { viewModel.openDataUsage() }
                        rowDivider
                        SettingsRow(
                            icon: "minus",
                            title: "Delete All Recordings",
                            titleColor: mistakeRed,
                            iconColor: mistakeRed
                        ) {
                            viewModel.requestDeleteAllRecordings()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
 
                footer
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
  
    private var header: some View {
        ZStack {
            Text("Settings")
                .font(.custom("IBM Plex Sans Arabic", size: 20))
                .fontWeight(.bold)
                .foregroundColor(inkColor)
                .frame(maxWidth: .infinity)
 
            HStack {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 38, height: 38)
                        .overlay(
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(inkColor)
                        )
                        .overlay(
                            Circle().stroke(Color.gray.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                }
 
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .background(Color.white)
        .overlay(
            Rectangle()
                .fill(Color.gray.opacity(0.08))
                .frame(height: 1),
            alignment: .bottom
        )
    }
 
 
    private var footer: some View {
        VStack(spacing: 6) {
            Image(systemName: "book.closed.fill")
                .font(.footnote)
                .foregroundColor(emeraldColor.opacity(0.5))
 
            Text("Al-Mahir · Version 1.0.0")
                .font(.footnote)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
  
    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
 
    private var rowDivider: some View {
        Divider().padding(.leading, 64)
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
