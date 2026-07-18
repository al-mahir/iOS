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
    var iconColor: Color = Color.gray
    
    var body: some View {
        Button(action: {
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                Text(title)
                    .font(.custom("IBM Plex Sans Arabic", size: 16))
                    .foregroundColor(titleColor)
                
                Spacer()
                
                Image(systemName: "chevron.left") 
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(Color.white)
        }
    }
}
