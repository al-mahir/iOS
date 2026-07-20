//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct SocialMediaLinksView: View {
    let platforms = ["GH", "DC", "X", "TK", "▶", "IG"]
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(platforms, id: \.self) { platform in
                Button(action: {
                }) {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(platform)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        )
                }
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SocialMediaLinksView()
}
