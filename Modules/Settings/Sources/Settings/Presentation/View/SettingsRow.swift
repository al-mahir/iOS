//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    var titleColor: Color = Color(hex: "#1A2421")
    var iconColor: Color = Color(hex: "#0E5A47")
    var action: () -> Void
 
    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 34, height: 34)
 
                    Image(systemName: icon)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(iconColor)
                }
 
                Text(title)
                    .font(.custom("IBM Plex Sans Arabic", size: 16))
                    .foregroundColor(titleColor)
 
                Spacer()
 
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.gray.opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(RowPressStyle())
    }
}

private struct RowPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.black.opacity(0.03) : Color.clear)
    }
}
 
#Preview {
    VStack(spacing: 0) {
        SettingsRow(icon: "book", title: "Mushaf Layout") {}
        Divider().padding(.leading, 64)
        SettingsRow(icon: "minus", title: "Delete All Recordings", titleColor: Color(hex: "#B5484D"), iconColor: Color(hex: "#B5484D")) {}
    }
    .background(Color.white)
    .cornerRadius(16)
    .padding()
    .background(Color(hex: "#F2F2F2"))
}
