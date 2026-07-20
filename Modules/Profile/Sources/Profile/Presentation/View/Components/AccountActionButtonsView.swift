//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct AccountActionButtonsView: View {
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "arrow.2.squarepath")
                    Text("تبديل الحساب")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            Button(action: {
            }) {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("تسجيل الخروج")
                }
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

#Preview {
    AccountActionButtonsView()
}
