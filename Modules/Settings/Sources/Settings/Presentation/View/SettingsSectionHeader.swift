//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import SwiftUI

struct SettingsSectionHeader: View {
    let title: String
    let backgroundColor: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("IBM Plex Sans Arabic", size: 14))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#0E5A47"))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(backgroundColor)
    }
}
#Preview {
    SettingsSectionHeader(title: "settings", backgroundColor:.white)
}
