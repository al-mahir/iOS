//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    var backgroundColor: Color = .clear
 
    var body: some View {
        HStack {
            Text(title.uppercased())
                .font(.custom("IBM Plex Sans Arabic", size: 12))
                .fontWeight(.semibold)
                .kerning(0.6)
                .foregroundColor(Color(hex: "#0E5A47").opacity(0.8))
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.top, 20)
        .padding(.bottom, 8)
        .background(backgroundColor)
    }
}
 
#Preview {
    SettingsSectionHeader(title: "Quran Appearance")
        .padding()
        .background(Color(hex: "#F2F2F2"))
}
