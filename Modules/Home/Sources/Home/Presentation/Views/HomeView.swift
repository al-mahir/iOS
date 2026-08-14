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
import Notification

public struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @StateObject private var notificationService: NotificationService
    @Environment(\.dsColors) private var dsColors
    
    @ObservedObject private var sessionManager = SessionManager.shared

    @State private var isSearchPresented = false
    @State private var navigateToSheikhs = false
    @State private var isMushafPresented = false
    @State private var targetMushafPage: Int? = nil
    @State private var targetAyahNumber: Int? = nil
    @State private var isNotificationsPresented = false

    @State private var navigateToActiveCircles = false
    @State private var selectedJoinCircle: CircleModel? = nil
    @State private var selectedSheikh: Sheikh? = nil

    let onSearchTap: () -> Void
    let onResumeReading: () -> Void
    let onJoinCircle: (CircleModel) -> Void
    let onSeeAllSheikhs: (() -> Void)?
    let onSeeAllCircles: () -> Void

    @MainActor
    public init(
        viewModel: HomeViewModel = DIContainer.shared.resolve(HomeViewModel.self),
        notificationService: NotificationService? = nil,
        onSearchTap: @escaping () -> Void = {},
        onResumeReading: @escaping () -> Void = {},
        onJoinCircle: @escaping (CircleModel) -> Void = { _ in },
        onSeeAllSheikhs: (() -> Void)? = nil,
        onSeeAllCircles: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _notificationService = StateObject(
            wrappedValue: notificationService ?? NotificationDIContainer.shared.resolve(NotificationService.self)
        )
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

                        if let name = sessionManager.currentUser?.fullName ?? sessionManager.currentUser?.username ?? viewModel.greeting?.firstName {
                            greetingView(name: name)
                        }

                        if let lastRead = viewModel.lastRead {
                            LastReadCard(
                                lastRead: LastReadPreview(
                                    surahName: lastRead.surahName,
                                    ayahNumber: lastRead.ayahNumber,
                                    juzNumber: lastRead.juzNumber,
                                    progress: lastRead.progress
                                ),
                                onResume: {
                                    targetMushafPage = lastRead.pageNumber
                                    targetAyahNumber = nil
                                    isMushafPresented = true
                                    onResumeReading()
                                }
                            )
                        } else {
                            StartExploringCard(
                                onStartExploring: {
                                    targetMushafPage = 1
                                    targetAyahNumber = nil
                                    isMushafPresented = true
                                }
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
                                            Button {
                                                selectedSheikh = sheikh
                                            } label: {
                                                SheikhCard(sheikh: sheikh)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                }
                            }
                        }

                        VStack(alignment: .leading, spacing: DSSpacing.smMd) {
                            HomeSectionHeader(
                                title: "Active Circles",
                                action: {
                                    onSeeAllCircles()
                                    navigateToActiveCircles = true
                                }
                            )

                            if viewModel.isLoadingCircles && viewModel.circles.isEmpty {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                        .padding(.vertical, DSSpacing.md)
                                    Spacer()
                                }
                            } else if !viewModel.circles.isEmpty {
                                VStack(spacing: DSSpacing.sm) {
                                    ForEach(Array(viewModel.circles.prefix(5))) { circle in
                                        CircleCardView(circle: circle) {
                                            onJoinCircle(circle)
                                            selectedJoinCircle = circle
                                        }
                                    }
                                }
                            } else {
                                Button(action: {
                                    onSeeAllCircles()
                                    navigateToActiveCircles = true
                                }) {
                                    HStack(spacing: DSSpacing.md) {
                                        ZStack {
                                            Circle()
                                                .fill(dsColors.primaryContainer)
                                                .frame(width: 44, height: 44)
                                            Image(systemName: "person.3.fill")
                                                .foregroundColor(dsColors.primary)
                                        }

                                        VStack(alignment: .leading, spacing: DSSpacing.xxs) {
                                            Text("Explore Study Circles")
                                                .dsFont(DSTypography.titleMedium)
                                                .foregroundColor(dsColors.textPrimary)
                                            Text("Join live sessions or create your own circle")
                                                .dsFont(DSTypography.bodySmall)
                                                .foregroundColor(dsColors.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(dsColors.textHint)
                                    }
                                    .padding(DSSpacing.md)
                                    .background(dsColors.surfaceContainerLow)
                                    .cornerRadius(DSRadius.lg)
                                }
                                .buttonStyle(PlainButtonStyle())
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
            .navigationDestination(isPresented: $isNotificationsPresented) {
                NotificationsView(viewModel: notificationService)
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
            .navigationDestination(item: $selectedSheikh) { sheikh in
                SheikhDetailView(sheikh: sheikh)
                    .dsTheme()
            }
            .navigationDestination(item: $selectedJoinCircle) { circle in
                JoinCircleView(
                    circle: circle,
                    restoreTabBarOnDisappear: false,
                    onDismiss: {
                        selectedJoinCircle = nil
                        viewModel.loadDashboard()
                    }
                )
                .dsTheme()
            }
            .navigationDestination(isPresented: $navigateToActiveCircles) {
                ActiveCirclesView(
                    onBack: { navigateToActiveCircles = false }
                )
                .dsTheme()
            }
        }
        .onAppear {
            viewModel.loadDashboard()
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
                    isNotificationsPresented = true
                }) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Circle()
                                .fill(dsColors.surfaceContainerLow)
                                .frame(width: 48, height: 48)

                            Image(systemName: "bell")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(dsColors.primary)
                        }

                        if notificationService.unreadCount > 0 {
                            Circle()
                                .fill(dsColors.error)
                                .frame(width: 10, height: 10)
                                .overlay(Circle().stroke(dsColors.background, lineWidth: 2))
                                .offset(x: -2, y: 2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

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

//                ZStack {
//                    Circle()
//                        .stroke(dsColors.primary, lineWidth: 2)
//                        .background(Circle().fill(dsColors.surfaceContainerLowest))
//                        .frame(width: 44, height: 44)
//
//                    Text(initials)
//                        .dsFont(DSTypography.labelLarge)
//                        .foregroundColor(dsColors.primary)
//                }
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

    private var initials: String {
        let nameToUse = sessionManager.currentUser?.fullName ?? sessionManager.currentUser?.username ?? viewModel.greeting?.firstName ?? "Guest"
        let components = nameToUse.components(separatedBy: " ")
        if components.count >= 2, let first = components[0].first, let second = components[1].first {
            return "\(first)\(second)".lowercased()
        } else if let first = nameToUse.first {
            if nameToUse.count >= 2 {
                let second = nameToUse[nameToUse.index(nameToUse.startIndex, offsetBy: 1)]
                return "\(first)\(second)".lowercased()
            }
            return String(first).lowercased()
        }
        return "gu"
    }
}
