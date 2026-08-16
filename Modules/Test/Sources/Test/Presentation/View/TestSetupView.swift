//
//  TestSetupView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI
import Common

struct TestSetupView: View {
    @Environment(\.dsColors) private var dsColors
    @ObservedObject var viewModel: TestSetupViewModel
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    let wordsDAO: WordsDAO
    let layoutDAO: LayoutDAO
    let searchRepository: QuranSearchRepository
    let onStart: (TestSessionManager) -> Void

    init(
        viewModel: TestSetupViewModel,
        wordsDAO: WordsDAO,
        layoutDAO: LayoutDAO,
        searchRepository: QuranSearchRepository,
        onStart: @escaping (TestSessionManager) -> Void
    ) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        self.wordsDAO = wordsDAO
        self.layoutDAO = layoutDAO
        self.searchRepository = searchRepository
        self.onStart = onStart
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.lg) {

                // MARK: - Scope Card
                VStack(alignment: .leading, spacing: DSSpacing.md) {
                    Text("What do you want to be tested on?", bundle: .module)
                        .dsFont(DSTypography.titleSmall)
                        .foregroundStyle(dsColors.textSecondary)

                    // Segmented Control
                    HStack(spacing: DSSpacing.xs) {
                        ForEach(TestSetupViewModel.ScopeKind.allCases) { kind in
                            let isSelected = viewModel.scopeKind == kind
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.scopeKind = kind
                                    viewModel.recomputeAllowedQuestionRange()
                                }
                            } label: {
                                Text(LocalizedStringKey(kind.rawValue), bundle: .module)
                                    .dsFont(DSTypography.labelLarge)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, DSSpacing.sm)
                                    .background(isSelected ? dsColors.primary : Color.clear)
                                    .foregroundStyle(isSelected ? dsColors.onPrimary : dsColors.textSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                            }
                        }
                    }
                    .padding(DSSpacing.xxs)
                    .background(dsColors.surfaceContainerHigh)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl))

                    Divider()
                        .background(dsColors.divider)

                    scopeFields
                }
                .padding(DSSpacing.md)
                .background(dsColors.surfaceContainerLowest)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl))
                .dsElevation(DSElevation.level1)

                // MARK: - Questions Card
                if let range = viewModel.allowedQuestionRange {
                    VStack(alignment: .leading, spacing: DSSpacing.sm) {
                        Text("Number of questions", bundle: .module)
                            .dsFont(DSTypography.titleSmall)
                            .foregroundStyle(dsColors.textSecondary)

                        HStack {
                            Text("\(viewModel.questionCount) questions", bundle: .module)
                                .dsFont(DSTypography.bodyMedium)
                                .foregroundStyle(dsColors.textPrimary)

                            Spacer()

                            HStack(spacing: DSSpacing.md) {
                                Button {
                                    if viewModel.questionCount > range.lowerBound {
                                        viewModel.questionCount -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus")
                                        .dsFont(DSTypography.labelLarge)
                                        .foregroundStyle(viewModel.questionCount > range.lowerBound ? dsColors.textPrimary : dsColors.textDisabled)
                                }
                                .disabled(viewModel.questionCount <= range.lowerBound)

                                Divider()
                                    .frame(height: 16)
                                    .background(dsColors.divider)

                                Button {
                                    if viewModel.questionCount < range.upperBound {
                                        viewModel.questionCount += 1
                                    }
                                } label: {
                                    Image(systemName: "plus")
                                        .dsFont(DSTypography.labelLarge)
                                        .foregroundStyle(viewModel.questionCount < range.upperBound ? dsColors.textPrimary : dsColors.textDisabled)
                                }
                                .disabled(viewModel.questionCount >= range.upperBound)
                            }
                            .padding(.horizontal, DSSpacing.smMd)
                            .padding(.vertical, DSSpacing.xs)
                            .background(dsColors.surfaceContainerHigh)
                            .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                        }

                        Divider()
                            .background(dsColors.divider)

                        Text("Choose between \(range.lowerBound) and \(range.upperBound) for this range.", bundle: .module)
                            .dsFont(DSTypography.caption)
                            .foregroundStyle(dsColors.textSecondary)
                    }
                    .padding(DSSpacing.md)
                    .background(dsColors.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl))
                    .dsElevation(DSElevation.level1)
                }

                if let error = viewModel.errorMessage {
                    Text(LocalizedStringKey(error), bundle: .module)
                        .dsFont(DSTypography.inputError)
                        .foregroundStyle(dsColors.error)
                        .padding(.horizontal, DSSpacing.xs)
                }

                Spacer(minLength: DSSpacing.lg)

                Button {
                    if let session = viewModel.makeSession(wordsDAO: wordsDAO, layoutDAO: layoutDAO, searchRepository: searchRepository) {
                        onStart(session)
                    }
                } label: {
                    Text("Start Test", bundle: .module)
                }
                .buttonStyle(DSPrimaryButtonStyle())
                .disabled(viewModel.allowedQuestionRange == nil || viewModel.isResolving)
            }
            .padding(.horizontal, DSSpacing.md)
            .padding(.top, DSSpacing.md)
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationTitle(Text("New Test", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.recomputeAllowedQuestionRange()
            tabBarVisibility.isVisible = false
        }
    }

    // MARK: - Scope Fields
    @ViewBuilder
    private var scopeFields: some View {
        switch viewModel.scopeKind {
        case .juz:
            HStack {
                Text("Juz'", bundle: .module)
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundStyle(dsColors.textPrimary)
                Spacer()
                Picker("", selection: $viewModel.selectedJuz) {
                    ForEach(1...30, id: \.self) { juz in
                        Text("Juz' \(juz)", bundle: .module)
                            .tag(juz)
                    }
                }
                .pickerStyle(.menu)
                .tint(dsColors.primary)
                .onChange(of: viewModel.selectedJuz) { _ in viewModel.recomputeAllowedQuestionRange() }
            }

        case .surahRange:
            VStack(spacing: DSSpacing.sm) {
                // From Surah
                HStack(spacing: DSSpacing.sm) {
                    Text("From Surah", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer(minLength: DSSpacing.sm)

                    Menu {
                        ForEach(viewModel.availableSurahs, id: \.id) { surah in
                            Button {
                                viewModel.fromSurah = surah.id
                                viewModel.recomputeAllowedQuestionRange()
                            } label: {
                                Text("\(surah.id). \(surah.englishName) (\(surah.arabicName))")
                            }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            if let selected = viewModel.availableSurahs.first(where: { $0.id == viewModel.fromSurah }) {
                                Text("\(selected.id). \(selected.englishName)")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else {
                                Text("Select", bundle: .module)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.textHint)
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(dsColors.primary)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: 190, alignment: .trailing)
                        .background(dsColors.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }

                Divider()
                    .background(dsColors.divider)

                // To Surah
                HStack(spacing: DSSpacing.sm) {
                    Text("To Surah", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer(minLength: DSSpacing.sm)

                    Menu {
                        ForEach(viewModel.availableSurahs.filter { $0.id >= viewModel.fromSurah }, id: \.id) { surah in
                            Button {
                                viewModel.toSurah = surah.id
                                viewModel.recomputeAllowedQuestionRange()
                            } label: {
                                Text("\(surah.id). \(surah.englishName) (\(surah.arabicName))")
                            }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            if let selected = viewModel.availableSurahs.first(where: { $0.id == viewModel.toSurah }) {
                                Text("\(selected.id). \(selected.englishName)")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else {
                                Text("Select", bundle: .module)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.textHint)
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(dsColors.primary)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: 190, alignment: .trailing)
                        .background(dsColors.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }
            }

        case .ayahRange:
            VStack(spacing: DSSpacing.sm) {
                // Surah
                HStack(spacing: DSSpacing.sm) {
                    Text("Surah", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer(minLength: DSSpacing.sm)

                    Menu {
                        ForEach(viewModel.availableSurahs, id: \.id) { surah in
                            Button {
                                viewModel.ayahSurah = surah.id
                                viewModel.recomputeAllowedQuestionRange()
                            } label: {
                                Text("\(surah.id). \(surah.englishName) (\(surah.arabicName))")
                            }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            if let selected = viewModel.availableSurahs.first(where: { $0.id == viewModel.ayahSurah }) {
                                Text("\(selected.id). \(selected.englishName)")
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.primary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            } else {
                                Text("Select", bundle: .module)
                                    .dsFont(DSTypography.bodyMedium)
                                    .foregroundStyle(dsColors.textHint)
                            }
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(dsColors.primary)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: 190, alignment: .trailing)
                        .background(dsColors.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }

                Divider()
                    .background(dsColors.divider)

                // From Ayah
                HStack(spacing: DSSpacing.sm) {
                    Text("From Ayah", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer(minLength: DSSpacing.sm)

                    Menu {
                        ForEach(1...viewModel.maxAyahsForSelectedSurah, id: \.self) { ayah in
                            Button {
                                viewModel.fromAyah = ayah
                                viewModel.recomputeAllowedQuestionRange()
                            } label: {
                                Text("Ayah \(ayah)", bundle: .module)
                            }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Ayah \(viewModel.fromAyah)", bundle: .module)
                                .dsFont(DSTypography.bodyMedium)
                                .foregroundStyle(dsColors.primary)
                                .lineLimit(1)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(dsColors.primary)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: 190, alignment: .trailing)
                        .background(dsColors.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }

                Divider()
                    .background(dsColors.divider)

                // To Ayah
                HStack(spacing: DSSpacing.sm) {
                    Text("To Ayah", bundle: .module)
                        .dsFont(DSTypography.bodyMedium)
                        .foregroundStyle(dsColors.textPrimary)

                    Spacer(minLength: DSSpacing.sm)

                    Menu {
                        ForEach(viewModel.fromAyah...viewModel.maxAyahsForSelectedSurah, id: \.self) { ayah in
                            Button {
                                viewModel.toAyah = ayah
                                viewModel.recomputeAllowedQuestionRange()
                            } label: {
                                Text("Ayah \(ayah)", bundle: .module)
                            }
                        }
                    } label: {
                        HStack(spacing: DSSpacing.xxs) {
                            Text("Ayah \(viewModel.toAyah)", bundle: .module)
                                .dsFont(DSTypography.bodyMedium)
                                .foregroundStyle(dsColors.primary)
                                .lineLimit(1)
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(dsColors.primary)
                        }
                        .padding(.horizontal, DSSpacing.sm)
                        .padding(.vertical, DSSpacing.xs)
                        .frame(maxWidth: 190, alignment: .trailing)
                        .background(dsColors.primaryContainer)
                        .clipShape(RoundedRectangle(cornerRadius: DSRadius.sm))
                    }
                }
            }
        }
    }
}
