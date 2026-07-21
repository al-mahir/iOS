//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct StreakCardView: View {
    let primaryGreen: Color
    let goldColor: Color

    let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: "bell")
                        .foregroundColor(.gray)

                    Image(systemName: "plus")
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(goldColor)
                        .font(.title2)

                    Text("1 Day")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(goldColor)
                }
            }

            HStack(spacing: 0) {
                ForEach(0..<7) { index in
                    VStack(spacing: 8) {
                        Text(days[index])
                            .font(.caption)
                            .foregroundColor(.gray)

                        ZStack {
                            if index == 3 {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(primaryGreen)
                                    .frame(width: 28, height: 28)
                                    .rotationEffect(.degrees(45))

                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            } else {
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    .frame(width: 28, height: 28)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                    }

                    if index != 6 {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 8)

            Text("Longest Streak: 1 Day")
                .font(.footnote)
                .foregroundColor(primaryGreen)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
    }
}
