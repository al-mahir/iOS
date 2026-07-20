//
//  NavBarItem.swift
//  Common
//
//  Created by Alaa Ayman on 20/07/2026.
//

import SwiftUI
public struct NavBarItem: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @Environment(\.dsColors) private var dsColors
    
   public var body: some View {
        Button(action: action) {
            VStack(spacing: DSSpacing.xs) {
              
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(dsColors.secondaryContainer)
                            .frame(width: 56, height: 32)
                            .transition(.scale(scale: 0.8).combined(with: .opacity))
                    }
                    
                    
                    Image(isSelected ? tab.selectedIconName : tab.iconName)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(dsColors.primary)
                }
                .frame(height: 32) 
                
          
                Text(tab.title)
                    .dsFont(DSTypography.navigationLabel)
                    .foregroundColor(isSelected ? dsColors.primary : dsColors.onSurfaceVariant)
            }
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(PlainButtonStyle()) 
    }
}
