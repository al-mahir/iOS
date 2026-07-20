//
//  AppSurahCard.swift
//  Common
//
//  Created by Alaa Ayman on 20/07/2026.
//


import SwiftUI


public struct AppSurahCard: View {
    @Environment(\.dsColors) private var dsColors
    
    public let arabicName: String
    public let englishName: String
    public let ayahCount: Int
    public let page: Int
    public let action: () -> Void
    
    public init(arabicName: String, englishName: String, ayahCount: Int, page: Int, action: @escaping () -> Void) {
        self.arabicName = arabicName
        self.englishName = englishName
        self.ayahCount = ayahCount
        self.page = page
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                    Text(arabicName)
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.primary)
                    
                    Text("\(englishName) • \(ayahCount) Ayahs • Page \(page)")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.md)
                    .fill(dsColors.surfaceContainerLow)
            )
        }
        .buttonStyle(.plain)
    }
}
