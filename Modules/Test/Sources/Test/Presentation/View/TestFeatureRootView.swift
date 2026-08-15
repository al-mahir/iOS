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

    public init(resolver: Resolver = DIContainer.shared.resolve(Resolver.self)) {
        self.viewModel = resolver.resolve(TestSetupViewModel?.self) ?? nil
        self.wordsDAO = resolver.resolve(WordsDAO?.self) ?? nil
        self.layoutDAO = resolver.resolve(LayoutDAO?.self) ?? nil
        self.searchRepository = resolver.resolve(QuranSearchRepository.self)

        print("viewModel:", resolver.resolve(TestSetupViewModel?.self) as Any)
        print("wordsDAO:", resolver.resolve(WordsDAO?.self) as Any)
        print("layoutDAO:", resolver.resolve(LayoutDAO?.self) as Any)
        print("searchRepository:", resolver.resolve(QuranSearchRepository.self) as Any)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationDestination(item: $session) { session in
                    TestSessionHostView(session: session)
                }
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
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text("Test unavailable")
                .font(.headline)
            Text("Couldn't load the Quran database. Please restart the app.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
