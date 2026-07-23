//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct AccountOptionRow: View {
    let title: String
    let icon: String
    var tint: Color = Color(hex: "0E5A47")
 
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(tint.opacity(0.12))
                    .frame(width: 34, height: 34)
 
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(tint)
            }
 
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
 
            Spacer()
 
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary.opacity(0.6))
                .font(.footnote.weight(.semibold))
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }
}
 
#Preview {
    AccountOptionRow(title: "About App", icon: "info.circle")
        .padding()
}
