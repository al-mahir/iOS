//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

public struct ProfileActivityView: View {
    let primaryGreen = Color(hex: "0E5A47")
    let lightGreen = Color(hex: "1A9370")
    let goldColor = Color(hex: "D9A441")
    let bgColor = Color(hex: "F8F9F9")
    
    public init(){}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                TopTabBar()
                StreakCardView(primaryGreen: primaryGreen, goldColor: goldColor)
                
                SessionsHistoryButton(primaryGreen: primaryGreen)
                
                AchievementsSection(primaryGreen: primaryGreen)
                
                PremiumBanner(primaryGreen: primaryGreen)
                
                ChartsSection(primaryGreen: primaryGreen)
                
                DetailedStatsSection(primaryGreen: primaryGreen, goldColor: goldColor)
                
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(bgColor.ignoresSafeArea())
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ProfileActivityView()
}
