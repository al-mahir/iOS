//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct ChartCard: View {
    let title: String
    let primaryGreen: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(title)
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 4) {
                    Text("Last 7 days")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            HStack(alignment: .bottom, spacing: 12) {
                VStack(spacing: 10) {
                    ForEach(["0","10","20","30"], id: \.self) { val in
                        Text(val).font(.caption2).foregroundColor(.gray)
                    }
                }
                
                HStack(alignment: .bottom, spacing: 8) {
                    BarView(height: 80, label: "7 - 11", color: primaryGreen)
                    BarView(height: 10, label: "7 - 12", color: primaryGreen.opacity(0.3))
                    BarView(height: 5, label: "7 - 13", color: primaryGreen.opacity(0.3))
                    BarView(height: 5, label: "7 - 14", color: primaryGreen.opacity(0.3))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.15), lineWidth: 1))
    }
}

struct BarView: View {
    let height: CGFloat
    let label: String
    let color: Color
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 40, height: height)
            Text(label)
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}
