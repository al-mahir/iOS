//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct DetailedStatsSection: View {
    let primaryGreen: Color
    let goldColor: Color
    
    let filters = ["Day", "Week", "Month", "Year", "Lifetime"]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Statistics")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            // Filters
            HStack {
                ForEach(filters, id: \.self) { filter in
                    Text(filter)
                        .font(.caption)
                        .fontWeight(filter == "Lifetime" ? .bold : .regular)
                        .foregroundColor(filter == "Lifetime" ? .white : .gray)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(filter == "Lifetime" ? primaryGreen : Color.clear)
                        .cornerRadius(16)
                }
            }
            .padding(4)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(20)
            
            // Stats Grid
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    StatGridItem(icon: "clock", value: "0h 3m", title: "Total Reading Time", iconColor: .gray)
                    Divider()
                    StatGridItem(icon: "book", value: "0", title: "Quran Completions", iconColor: .gray)
                }
                Divider()
                HStack(spacing: 0) {
                    StatGridItem(icon: "calendar", value: "0", title: "Days Recited", iconColor: .gray)
                    Divider()
                    StatGridItem(icon: "text.alignleft", value: "0", title: "Verses Recited", iconColor: .gray)
                }
                Divider()
                HStack(spacing: 0) {
                    StatGridItem(icon: "medal", value: "3", title: "Pages Earned", iconColor: .purple)
                    Divider()
                    StatGridItem(icon: "star.fill", value: "2.86K", title: "Hasanat Earned", iconColor: goldColor)
                }
                Divider()
                HStack(spacing: 0) {
                    StatGridItem(icon: "magnifyingglass", value: "1", title: "Searches Used", iconColor: .gray)
                    Divider()
                    StatGridItem(icon: "square.and.arrow.up", value: "19", title: "Verses Shared", iconColor: .gray)
                }
            }
            .background(Color.white)
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.15), lineWidth: 1))
        }
    }
}

struct StatGridItem: View {
    let icon: String
    let value: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .font(.footnote)
                    Text(value)
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}
