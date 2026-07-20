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
            VStack(spacing: 24) {
                
                ProfileHeaderView()
                
                PremiumButtonView()
                
                AccountActionButtonsView()
                
                SocialMediaLinksView()
                
                Divider()
                
                AccountOptionsListView()
                
            }
            .padding(.horizontal)
        }
        .navigationTitle("حساب")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AccountView()
}
