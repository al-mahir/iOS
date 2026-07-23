//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct AchievementsSection: View {
    let primaryGreen: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("Show all")
                    .font(.footnote)
                    .foregroundColor(primaryGreen)
            }
            
            HStack(spacing: 16) {
                AchievementCard(title: "Start memorizing.", icon: "brain.head.profile", iconBgColor: Color.blue.opacity(0.1))
                AchievementCard(title: "Curriculum 1", icon: "book.closed.fill", iconBgColor: Color.yellow.opacity(0.2))
            }
        }
    }
}
