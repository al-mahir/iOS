//
//  AppButton.swift
//  Common
//
//  Created by Alaa Ayman on 20/07/2026.
//



import SwiftUI

public struct AppButton: View {
    public let title: String
    public let action: () -> Void
    
    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
            
                .dsFont(DSTypography.labelLarge)
                .padding(.vertical, DSSpacing.sm)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(DSPrimaryButtonStyle())
    }
}
