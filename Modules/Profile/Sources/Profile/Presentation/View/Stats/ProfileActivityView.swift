//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

public struct ProfileActivityView: View {
    @EnvironmentObject private var router: ProfileRouter
    @StateObject private var viewModel: ProfileStatsViewModel
    
    let primaryGreen = Color(hex: "0E5A47")
    let lightGreen = Color(hex: "1A9370")
    let goldColor = Color(hex: "D9A441")
    let bgColor = Color(hex: "F8F9F9")
    
    public init(viewModel: ProfileStatsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Statistics Loading......")
                    .tint(primaryGreen)
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                    
                    Button("try again") {
                        Task {
                            await viewModel.loadStats()
                        }
                    }
                    .padding(.top, 10)
                }
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        headerView
                        
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
                    .padding(.bottom, 90)
                }
            }
        }
        .task {
            await viewModel.loadStats()
        }
    }
    
    private var headerView: some View {
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
    }
}
