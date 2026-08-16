//
//  TestFeatureRootView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI
import Swinject
import Common

public struct TestFeatureRootView: View {
    private let viewModel: TestSetupViewModel?
    private let wordsDAO: WordsDAO?
    private let layoutDAO: LayoutDAO?
    private let searchRepository: QuranSearchRepository?

    @State private var session: TestSessionManager?
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    public init(resolver: Resolver = DIContainer.shared.resolve(Resolver.self)) {
        self.viewModel = resolver.resolve(TestSetupViewModel?.self) ?? nil
        self.wordsDAO = resolver.resolve(WordsDAO?.self) ?? nil
        self.layoutDAO = resolver.resolve(LayoutDAO?.self) ?? nil
        self.searchRepository = resolver.resolve(QuranSearchRepository.self)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationDestination(item: $session) { session in
                    TestSessionHostView(session: session)
                }
        }
        // Re-asserted on every appear (rather than relying on onDisappear
        // elsewhere) since NavigationStack fires onDisappear on whatever
        // was pushed *from* the moment this is pushed on top — self-healing
        // here means the bar can't sneak back regardless of push order.
        .onAppear {
            tabBarVisibility.isVisible = false
        }
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel, let wordsDAO, let layoutDAO, let searchRepository {
            TestSetupView(
                viewModel: viewModel,
                wordsDAO: wordsDAO,
                layoutDAO: layoutDAO,
                searchRepository: searchRepository,
                onStart: { session = $0 }
            )
        } else {
            unavailableView
        }
    }

    // MARK: - Fallback

    private var unavailableView: some View {
        UnavailableTestView()
    }
}

private struct UnavailableTestView: View {
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(dsColors.warningContainer)
                    .frame(width: 72, height: 72)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(dsColors.warning)
            }

            Text("Test unavailable", bundle: .module, comment: "Title displayed when the test feature cannot load dependencies")
                .dsFont(DSTypography.headlineSmall)
                .foregroundColor(dsColors.textPrimary)

            Text("Couldn't load the Quran database. Please restart the app.", bundle: .module, comment: "Error message when test setup dependencies are missing")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(dsColors.background.ignoresSafeArea())
    }
}

private struct TestSessionHostView: View {
    let session: TestSessionManager
    @State private var result: TestSessionResult?

    var body: some View {
        TestSessionView(
            session: session,
            onFinished: { result = $0 }
        )
        .navigationDestination(isPresented: Binding(
            get: { result != nil },
            set: { isPresented in if !isPresented { result = nil } }
        )) {
            if let result {
                TestResultView(result: result)
            }
        }
    }
}
