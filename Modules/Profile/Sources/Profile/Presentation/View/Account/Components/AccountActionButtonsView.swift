//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct AccountActionButtonsView: View {
    var body: some View {
        HStack(spacing: 12) {
 
            actionButton(
                icon: "arrow.2.squarepath",
                title: "Switch Account",
                tint: Color(hex: "0E5A47")
            )
 
            actionButton(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Logout",
                tint: Color(hex: "B5484D")
            )
        }
    }
 
    private func actionButton(icon: String, title: String, tint: Color) -> some View {
        Button(action: {
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(tint)
 
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.gray.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }
}
 
#Preview {
    AccountActionButtonsView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
