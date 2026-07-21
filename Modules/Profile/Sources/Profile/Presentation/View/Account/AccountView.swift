//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

public struct AccountView: View {
    public init() {}
 
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
 
                ProfileHeaderView()
 
                PremiumButtonView()
 
                AccountActionButtonsView()
 
                SocialMediaLinksView()
 
                AccountOptionsListView()
 
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}
 
#Preview {
    NavigationStack {
        AccountView()
    }
}
