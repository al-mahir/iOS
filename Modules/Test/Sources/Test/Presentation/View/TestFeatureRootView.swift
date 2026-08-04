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
    private let searchRepository: QuranSearchRepository?

    @State private var session: TestSessionManager?

    public init(resolver: Resolver = DIContainer.shared.resolve(Resolver.self)) {
        self.viewModel = resolver.resolve(TestSetupViewModel?.self) ?? nil
        self.wordsDAO = resolver.resolve(WordsDAO?.self) ?? nil
        self.searchRepository = resolver.resolve(QuranSearchRepository.self)
        
        print("viewModel:", resolver.resolve(TestSetupViewModel?.self) as Any)
        print("wordsDAO:", resolver.resolve(WordsDAO?.self) as Any)
        print("searchRepository:", resolver.resolve(QuranSearchRepository.self) as Any)
    }

    public var body: some View {
        NavigationView {
            content
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder
    private var content: some View {
        if let viewModel, let wordsDAO, let searchRepository {
            TestSetupView(
                viewModel: viewModel,
                wordsDAO: wordsDAO,
                searchRepository: searchRepository,
                onStart: { session = $0 }
            )
            .background(sessionLink)
        } else {
            
            unavailableView
        }
    }

    // MARK: - Programmatic navigation (iOS 15 pattern)

    private var sessionLink: some View {
        NavigationLink(
            destination: Group {
                if let session {
                    TestSessionHostView(session: session)
                } else {
                    EmptyView()
                }
            },
            isActive: Binding(
                get: { session != nil },
                set: { isActive in if !isActive { session = nil } }
            ),
            label: { EmptyView() }
        )
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
        .background(
            NavigationLink(
                destination: Group {
                    if let result {
                        TestResultView(result: result)
                    } else {
                        EmptyView()
                    }
                },
                isActive: Binding(
                    get: { result != nil },
                    set: { isActive in if !isActive { result = nil } }
                ),
                label: { EmptyView() }
            )
        )
    }
}
