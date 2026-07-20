//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct ProfileHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
 
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "0E5A47"), Color(hex: "1A9370")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: Color(hex: "0E5A47").opacity(0.35), radius: 8, x: 0, y: 4)
 
                Text("e")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
 
            VStack(alignment: .leading, spacing: 4) {
                Text("esraaehab")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("esraaehab@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
 
            Spacer()
 
            VStack(alignment: .trailing, spacing: 4) {
                Text("تاريخ الانضمام")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("07/04/2026")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(hex: "0E5A47"))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}
 
#Preview {
    ProfileHeaderView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
