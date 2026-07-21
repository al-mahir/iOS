//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

import SwiftUI

public struct ProfileActivityView: View {
    @EnvironmentObject private var router: ProfileRouter
    
    let primaryGreen = Color(hex: "0E5A47")
    let lightGreen = Color(hex: "1A9370")
    let goldColor = Color(hex: "D9A441")
    let bgColor = Color(hex: "F8F9F9")
    
    public init(){}
    
    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                
                HStack {
                    Button(action: {
                        router.push(.account)
                    }) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                            .foregroundColor(primaryGreen)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        router.push(.settings)
                    }) {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                            .foregroundColor(primaryGreen)
                            .padding(8) 
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 5)
                
                
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
    }
}

#Preview {
    ProfileActivityView()
}
