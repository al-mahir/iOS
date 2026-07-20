//
//  MushafTopBar.swift
//  Mushaf
//
//  Created by Alaa Ayman on 20/07/2026.
//


import SwiftUI
import Common

struct MushafTopBar: View {
    @Environment(\.dsColors) private var dsColors

    let pageNumber: Int
    let isBookmarked: Bool
    let onTapPageNumber: () -> Void
    let onTapBookmark: () -> Void
    let onTapSettings: () -> Void
    let tajweedBinding: Binding<Bool>
    let isTajweedToggleEnabled: Bool

    var body: some View {
        VStack(spacing: DSSpacing.sm) {
            HStack(spacing: DSSpacing.sm) {
                Button(action: onTapPageNumber) {
                    HStack(spacing: DSSpacing.xxs) {
                        Text("Page \(pageNumber)")
                            .dsFont(DSTypography.labelLarge)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(dsColors.textSecondary)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, DSSpacing.xs)
                    .background(
                        Capsule().fill(dsColors.surfaceContainerLow)
                    )
                }

                Spacer()

                HStack(spacing: DSSpacing.sm) {
                    Toggle(isOn: tajweedBinding) {
                        Text("Tajweed")
                            .dsFont(DSTypography.caption)
                    }
                    .toggleStyle(.switch)
                    .labelsHidden()
                    .disabled(!isTajweedToggleEnabled)
                    .tint(dsColors.primary)

                    iconButton(isBookmarked ? "bookmark-filled" : "bookmark", action: onTapBookmark)
                    iconButton("settings", action: onTapSettings)
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.top, DSSpacing.sm)
        .padding(.bottom, DSSpacing.sm)
        .background(dsColors.surfaceContainer) 
    }

    private func iconButton(_ imageName: String, action: @escaping () -> Void) -> some View {
            Button(action: action) {
          
                Image(imageName, bundle: .common)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(dsColors.textSecondary)
                    .frame(width: 24, height: 24)
                    .frame(width: 32, height: 32)
                    .background(Circle().fill(dsColors.surfaceContainerLow))
            }
        }
}
