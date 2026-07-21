//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct PremiumBanner: View {
    let primaryGreen: Color
    
    var body: some View {
        Text("Get those features with the Premium download")
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundColor(primaryGreen)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }
}

