//
//  HomeView.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import SwiftUI
import Common

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.dsColors) private var dsColors
    
    let onSearchTap: () -> Void
    let onResumeReading: () -> Void
    let onJoinCircle: (ActiveCircleEntity) -> Void
    let onSeeAllSheikhs: () -> Void
    let onSeeAllCircles: () -> Void

    public init(
        viewModel: HomeViewModel = DIContainer.shared.resolve(HomeViewModel.self),
        onSearchTap: @escaping () -> Void = {},
        onResumeReading: @escaping () -> Void = {},
        onJoinCircle: @escaping (ActiveCircleEntity) -> Void = { _ in },
        onSeeAllSheikhs: @escaping () -> Void = {},
        onSeeAllCircles: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSearchTap = onSearchTap
        self.onResumeReading = onResumeReading
        self.onJoinCircle = onJoinCircle
        self.onSeeAllSheikhs = onSeeAllSheikhs
        self.onSeeAllCircles = onSeeAllCircles
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {
                
                header
                
                if let greeting = viewModel.greeting {
                    greetingView(name: greeting.firstName)
                }
                
                if let lastRead = viewModel.lastRead {
                    LastReadCard(
                        lastRead: LastReadPreview(
                            surahName: lastRead.surahName,
                            ayahNumber: lastRead.ayahNumber,
                            juzNumber: lastRead.juzNumber,
                            progress: lastRead.progress
                        ),
                        onResume: onResumeReading
                    )
                }

                if !viewModel.sheikhs.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.smMd) {
                        HomeSectionHeader(title: "Learn with a Sheikh", action: onSeeAllSheikhs)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DSSpacing.sm) {
                                ForEach(viewModel.sheikhs) { sheikh in
                                    SheikhCard(sheikh: sheikh)
                                }
                            }
                        }
                    }
                }

            

                if !viewModel.circles.isEmpty {
                    VStack(alignment: .leading, spacing: DSSpacing.smMd) {
                        HomeSectionHeader(title: "Active Circles", action: onSeeAllCircles)
                        VStack(spacing: DSSpacing.sm) {
                            ForEach(viewModel.circles) { circle in
                                ActiveCircleRow(circle: circle) {
                                    onJoinCircle(circle)
                                }
                            }
                        }
                    }
                }
                if let ayah = viewModel.ayahOfTheDay {
                    AyahOfTheDayCard(entity: ayah)
                }
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.md)
          
        }.safeAreaInset(edge: .bottom) {
      
            Color.clear.frame(height: 110)
        }
        .background(dsColors.background)
    }

    private var header: some View {
        HStack {
            Text("Al-Māhir")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.primary)

            Spacer()

            HStack(spacing: DSSpacing.sm) {
                Button(action: onSearchTap) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(dsColors.textSecondary)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(dsColors.surfaceContainerLow))
                }
                .buttonStyle(.plain)

                if let initials = viewModel.greeting?.initials {
                    Circle()
                        .fill(dsColors.primary)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(initials)
                                .dsFont(DSTypography.labelLarge)
                                .foregroundColor(dsColors.onPrimary)
                        )
                }
            }
        }
    }

    private func greetingView(name: String) -> some View {
        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
            Text("Assalamu Alaikum, \(name)")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)
            Text("Continue your journey with the light of guidance.")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
    }
}
