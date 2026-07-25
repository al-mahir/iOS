//
//  HomeView.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import SwiftUI
import Common
import Mushaf
import Sheikh
import Search
import Circles

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @Environment(\.dsColors) private var dsColors

    @State private var isSearchPresented = false
    @State private var navigateToSheikhs = false
    @State private var isMushafPresented = false
    @State private var targetMushafPage: Int? = nil
    @State private var targetAyahNumber: Int? = nil

    @State private var navigateToActiveCircles = false
    @State private var navigateToCreateCircle = false
    @State private var selectedJoinCircle: CircleModel? = nil

    let onSearchTap: () -> Void
    let onResumeReading: () -> Void
    let onJoinCircle: (ActiveCircleEntity) -> Void
    let onSeeAllSheikhs: (() -> Void)?
    let onSeeAllCircles: () -> Void

    public init(
        viewModel: HomeViewModel = DIContainer.shared.resolve(HomeViewModel.self),
        onSearchTap: @escaping () -> Void = {},
        onResumeReading: @escaping () -> Void = {},
        onJoinCircle: @escaping (ActiveCircleEntity) -> Void = { _ in },
        onSeeAllSheikhs: (() -> Void)? = nil,
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
        NavigationStack {
            VStack(spacing: 0) {

                header
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.xs)
                    .padding(.bottom, DSSpacing.xs)

                ScrollView {
                    VStack(alignment: .leading, spacing: DSSpacing.lg) {

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
                                HomeSectionHeader(
                                    title: "Learn with a Sheikh",
                                    action: {
                                
                                        onSeeAllSheikhs?()
                                        navigateToSheikhs = true
                                    }
                                )
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
                                HomeSectionHeader(
                                    title: "Active Circles",
                                    action: {
                                        onSeeAllCircles()
                                        navigateToActiveCircles = true
                                    }
                                )
                                VStack(spacing: DSSpacing.sm) {
                                    ForEach(viewModel.circles) { circle in
                                        ActiveCircleRow(circle: circle) {
                                            onJoinCircle(circle)
                                            selectedJoinCircle = CircleModel(
                                                id: circle.id.uuidString,
                                                name: circle.title,
                                                topic: circle.title,
                                                sheikhName: circle.host,
                                                sheikhInitials: String(circle.host.prefix(2)).uppercased()
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        if let ayahEntity = viewModel.ayahOfTheDay {
                            Button {
                                targetMushafPage = ayahEntity.pageNumber
                                targetAyahNumber = ayahEntity.ayahNumber
                                isMushafPresented = true
                            } label: {
                                AyahOfTheDayCard(entity: ayahEntity)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.top, DSSpacing.sm)
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 110)
                }
            }
            .background(dsColors.background)
            .toolbar(.hidden, for: .navigationBar)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $isSearchPresented) {
                SearchView()
            }
            .navigationDestination(isPresented: $navigateToSheikhs) {
                SheikhListView()
                    .dsTheme()
            }
            .navigationDestination(isPresented: $isMushafPresented) {
                if let page = targetMushafPage {
                    MushafRootView(
                        startPage: page,
                        targetAyahNumber: targetAyahNumber,
                        showBackButton: true
                    )
                }
            }
            .navigationDestination(isPresented: $navigateToActiveCircles) {
                ActiveCirclesView(
                    onBack: { navigateToActiveCircles = false },
                    onNavigateToCreateCircle: { navigateToCreateCircle = true },
                    onJoinCircle: { circle in selectedJoinCircle = circle }
                )
                .dsTheme()
            }
            .navigationDestination(isPresented: $navigateToCreateCircle) {
                CreateCircleView(
                    onDismiss: { navigateToCreateCircle = false },
                    onCircleCreated: { _ in navigateToCreateCircle = false }
                )
                .dsTheme()
            }
            .sheet(item: $selectedJoinCircle) { circle in
                JoinCircleView(
                    circle: circle,
                    onDismiss: { selectedJoinCircle = nil }
                )
                .dsTheme()
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Al-Māhir")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.primary)

            Spacer()

            HStack(spacing: DSSpacing.sm) {
                Button(action: {
                    onSearchTap()
                    isSearchPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(dsColors.surfaceContainerLow)
                            .frame(width: 48, height: 48)

                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(dsColors.primary)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if let initials = viewModel.greeting?.initials {
                    Circle()
                        .fill(dsColors.primary)
                        .frame(width: 44, height: 44)
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
