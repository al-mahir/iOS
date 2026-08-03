//
//  TestSetupView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI
import Common

struct TestSetupView: View {
    @ObservedObject var viewModel: TestSetupViewModel
    let wordsDAO: WordsDAO
    let searchRepository: QuranSearchRepository
    let onStart: (TestSessionManager) -> Void
    
    init(
        viewModel: TestSetupViewModel,
        wordsDAO: WordsDAO,
        searchRepository: QuranSearchRepository,
        onStart: @escaping (TestSessionManager) -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.wordsDAO = wordsDAO
        self.searchRepository = searchRepository
        self.onStart = onStart
    }
    public var body: some View {
        Form {
            Section("What do you want to be tested on?") {
                Picker("Scope", selection: $viewModel.scopeKind) {
                    ForEach(TestSetupViewModel.ScopeKind.allCases) { kind in
                        Text(kind.rawValue).tag(kind)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: viewModel.scopeKind) { _ in viewModel.recomputeAllowedQuestionRange() }

                scopeFields
            }

            if let range = viewModel.allowedQuestionRange {
                Section("Number of questions") {
                    Stepper(value: $viewModel.questionCount, in: range) {
                        Text("\(viewModel.questionCount) questions")
                    }
                    Text("Choose between \(range.lowerBound) and \(range.upperBound) for this range.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.errorMessage {
                Section {
                    Text(error).foregroundStyle(.red)
                }
            }

            Section {
                Button("Start Test") {
                    if let session = viewModel.makeSession(wordsDAO: wordsDAO, searchRepository: searchRepository) {
                        onStart(session)
                    }
                }
                .disabled(viewModel.allowedQuestionRange == nil || viewModel.isResolving)
            }
        }
        .navigationTitle("New Test")
        .onAppear { viewModel.recomputeAllowedQuestionRange() }
    }

    @ViewBuilder
    private var scopeFields: some View {
        switch viewModel.scopeKind {
        case .juz:
            Stepper(value: $viewModel.selectedJuz, in: 1...30) {
                Text("Juz' \(viewModel.selectedJuz)")
            }
            .onChange(of: viewModel.selectedJuz) { _ in viewModel.recomputeAllowedQuestionRange() }

        case .surahRange:
            Stepper(value: $viewModel.fromSurah, in: 1...114) {
                Text("From Surah \(viewModel.fromSurah)")
            }
            .onChange(of: viewModel.fromSurah) { _ in viewModel.recomputeAllowedQuestionRange() }

            Stepper(value: $viewModel.toSurah, in: 1...114) {
                Text("To Surah \(viewModel.toSurah)")
            }
            .onChange(of: viewModel.toSurah) { _ in viewModel.recomputeAllowedQuestionRange() }

        case .ayahRange:
            Stepper(value: $viewModel.ayahSurah, in: 1...114) {
                Text("Surah \(viewModel.ayahSurah)")
            }
            .onChange(of: viewModel.ayahSurah) { _ in viewModel.recomputeAllowedQuestionRange() }

            Stepper(value: $viewModel.fromAyah, in: 1...300) {
                Text("From Ayah \(viewModel.fromAyah)")
            }
            .onChange(of: viewModel.fromAyah) { _ in viewModel.recomputeAllowedQuestionRange() }

            Stepper(value: $viewModel.toAyah, in: 1...300) {
                Text("To Ayah \(viewModel.toAyah)")
            }
            .onChange(of: viewModel.toAyah) { _ in viewModel.recomputeAllowedQuestionRange() }
        }
    }
}
