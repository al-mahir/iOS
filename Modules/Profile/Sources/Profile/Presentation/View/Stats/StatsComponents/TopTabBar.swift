//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct TopTabBar: View {
    let tabs = ["Community", "Activity", "Memorization", "Goals", "Dashboard"]

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                Text(tab)
                    .font(.system(size: 12, weight: tab == "Activity" ? .bold : .medium))
                    .foregroundColor(tab == "Activity" ? Color(hex: "0E5A47") : .gray.opacity(0.6))
                    .padding(.bottom, 8)
                    .overlay(
                        Rectangle()
                            .fill(tab == "Activity" ? Color(hex: "0E5A47") : Color.clear)
                            .frame(height: 3)
                            .cornerRadius(1.5),
                        alignment: .bottom
                    )

                if tab != tabs.last {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    TopTabBar()
}
