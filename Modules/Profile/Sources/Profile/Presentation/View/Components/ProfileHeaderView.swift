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
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(Text("e").font(.title2).bold())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("esraaehab")
                    .font(.headline)
                Text("esraaehab@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("تاريخ الانضمام")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text("07/04/2026")
                    .font(.caption)
                    .bold()
            }
        }
    }
}

#Preview {
    ProfileHeaderView()
}
