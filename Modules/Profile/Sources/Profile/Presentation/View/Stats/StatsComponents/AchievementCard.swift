//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct AchievementCard: View {
    let title: String
    let icon: String
    let iconBgColor: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Circle()
                .fill(iconBgColor)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(icon == "book.closed.fill" ? .yellow : .pink)
                        .font(.title2)
                )
            
            Text(title)
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }
}
