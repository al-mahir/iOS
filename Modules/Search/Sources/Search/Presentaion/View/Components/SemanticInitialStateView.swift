//
//  SemanticInitialStateView.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//


//
//  SemanticInitialStateView.swift
//  Search
//
//  Created on 23/07/2026.
//

import SwiftUI
import Common

/// Engaging initial state view for the Semantic Search tab,
/// guiding the user on how to search by concepts and topics.
struct SemanticInitialStateView: View {
    @Environment(\.dsColors) private var dsColors
    @ObservedObject var viewModel: SearchViewModel

    @State private var pulsate = false
    @State private var floatAnim = false

    private let sampleQueries = [
        "Patience in times of trial",
        "Honoring parents",
        "Day of Resurrection",
        "Charity and generosity",
        "Forgiveness and repentance"
    ]

    var body: some View {
        VStack(spacing: DSSpacing.lg) {
            // Animated Header Icon
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.35))
                    .frame(width: 110, height: 110)
                    .scaleEffect(pulsate ? 1.12 : 1.0)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: pulsate)

                Circle()
                    .fill(dsColors.primaryContainer.opacity(0.6))
                    .frame(width: 82, height: 82)

                Image(systemName: "sparkles")
                    .font(.system(size: 38, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [dsColors.primary, dsColors.secondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: floatAnim ? -4 : 4)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: floatAnim)
            }
            .onAppear {
                pulsate = true
                floatAnim = true
            }
            .padding(.top, DSSpacing.md)

            // Guidance Text
            VStack(spacing: DSSpacing.xs) {
                Text("Search by Concepts & Meaning")
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Type any topic, theme, or question in plain language to find relevant Ayahs from across the Quran.")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(dsColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, DSSpacing.lg)
            }

            // Sample topics / suggestions
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Text("Try searching for:")
                    .dsFont(DSTypography.labelLarge)
                    .foregroundColor(dsColors.textPrimary)

                VStack(spacing: DSSpacing.xs) {
                    ForEach(sampleQueries, id: \.self) { query in
                        Button {
                            viewModel.searchQuery = query
                        } label: {
                            HStack(spacing: DSSpacing.sm) {
                                Image(systemName: "sparkle")
                                    .font(.system(size: 13))
                                    .foregroundColor(dsColors.primary)

                                Text(query)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundColor(dsColors.textPrimary)

                                Spacer()

                                Image(systemName: "arrow.up.backward")
                                    .font(.system(size: 12))
                                    .foregroundColor(dsColors.textHint)
                            }
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.vertical, DSSpacing.sm)
                            .background(
                                RoundedRectangle(cornerRadius: DSRadius.md)
                                    .fill(dsColors.surfaceContainerLow)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: DSRadius.md)
                                    .stroke(dsColors.outlineVariant, lineWidth: 0.5)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, DSSpacing.xs)
            .padding(.top, DSSpacing.sm)
        }
        .frame(maxWidth: .infinity)
    }
}
