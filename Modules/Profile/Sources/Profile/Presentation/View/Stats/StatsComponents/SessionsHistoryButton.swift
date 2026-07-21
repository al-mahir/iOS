//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct SessionsHistoryButton: View {
    let primaryGreen: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Text("Session History")
                    .font(.headline)
                    .foregroundColor(.black)
                Spacer()
                Text("2")
                    .font(.headline)
                    .foregroundColor(primaryGreen)
                Image(systemName: "chevron.left")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
    }
}
