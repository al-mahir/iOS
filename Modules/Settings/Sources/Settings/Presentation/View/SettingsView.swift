//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI

public struct SettingsView: View {
    let surfaceSand = Color(hex: "#F2F2F2")
    let inkColor = Color(hex: "#1A2421")
    let emeraldColor = Color(hex: "#0E5A47")
    let mistakeRed = Color(hex: "#B5484D")

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                    }) {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Image(systemName: "chevron.right")
                                    .foregroundColor(inkColor)
                            )
                    }
                    
                    Spacer()
                    
                    Text("الإعدادات")
                        .font(.custom("IBM Plex Sans Arabic", size: 24)) 
                        .fontWeight(.bold)
                        .foregroundColor(inkColor)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .background(Color.white)

                VStack(spacing: 0) {
                    
                    SettingsSectionHeader(title: "مظهر القرآن", backgroundColor: surfaceSand)
                    SettingsRow(icon: "book", title: "هيئة المصحف")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "eye.slash", title: "الآيات المخفية")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "highlighter", title: "تحديد")

                    SettingsSectionHeader(title: "مظهر التطبيق", backgroundColor: surfaceSand)
                    SettingsRow(icon: "globe", title: "اللغة")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "sun.max", title: "المظهر")

                    SettingsSectionHeader(title: "إشعارات", backgroundColor: surfaceSand)
                    SettingsRow(icon: "bell", title: "تذكيرات")

                    SettingsSectionHeader(title: "الأصوات والتفاعل الحسي", backgroundColor: surfaceSand)
                    SettingsRow(icon: "info.circle", title: "الأخطاء")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "mic", title: "بدء وإيقاف الجلسة")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "wifi.slash", title: "انقطاع الاتصال")

                    SettingsSectionHeader(title: "التنزيلات", backgroundColor: surfaceSand)
                    SettingsRow(icon: "headphones", title: "القراء")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "textformat.alt", title: "ترجمة")
                    Divider().padding(.leading, 50)
                    SettingsRow(icon: "book.closed", title: "تفسير")

                    SettingsSectionHeader(title: "الخصوصية", backgroundColor: surfaceSand)
                    SettingsRow(icon: "lock", title: "استخدام البيانات")
                    Divider().padding(.leading, 50)
                    SettingsRow(
                        icon: "minus",
                        title: "حذف جميع التسجيلات",
                        titleColor: mistakeRed, 
                        iconColor: mistakeRed
                    )
                }
                .background(Color.white)
                
                VStack {
                    Text("الإصدار Al-Mahir 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.vertical, 30)
                }
                .frame(maxWidth: .infinity)
                .background(surfaceSand) 
            }
        }
        .background(surfaceSand.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
        .navigationBarHidden(true)
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
