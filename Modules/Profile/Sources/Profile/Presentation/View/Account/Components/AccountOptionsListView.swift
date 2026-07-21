//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct AccountOptionsListView: View {
    var body: some View {
        VStack(spacing: 12) {

            card {
                VStack(spacing: 14) {
                    Button {
                    } label: {
                        AccountOptionRow(title: "About the App", icon: "info.circle")
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Request a New Feature", icon: "bubble.left", tint: Color(hex: "1A9370"))
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Help Center", icon: "questionmark.circle", tint: Color(hex: "1A9370"))
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Share the App", icon: "square.and.arrow.up", tint: Color(hex: "0E5A47"))
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Rate the App", icon: "star.fill", tint: Color(hex: "D9A441"))
                    }
                    .buttonStyle(.plain)
                    
                }
            }

            card {
                VStack(spacing: 14) {
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Terms of Service", icon: "doc.text", tint: .gray)
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                    
                    Button {
                    } label: {
                        AccountOptionRow(title: "Privacy Policy", icon: "lock.shield", tint: .gray)
                    }
                    .buttonStyle(.plain)
                    
                }
            }

            Button(action: {
            }) {
                Text("Delete Account")
                    .font(.headline)
                    .foregroundColor(Color(red: 181/255, green: 72/255, blue: 77/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.gray.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}
 
#Preview {
    AccountOptionsListView()
        .padding()
        .background(Color(.systemGroupedBackground))
}
