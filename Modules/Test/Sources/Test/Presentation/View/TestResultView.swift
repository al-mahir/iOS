//
//  TestResultView.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//

import SwiftUI
import Common

public struct TestResultView: View {
    let result: TestSessionResult
    let onDone: () -> Void

    @Environment(\.dsColors) private var dsColors
    @Environment(\.tabBarVisibility) private var tabBarVisibility

    public init(result: TestSessionResult, onDone: @escaping () -> Void) {
        self.result = result
        self.onDone = onDone
    }

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DSSpacing.lg) {
                scoreHero
                statsRow
                questionBreakdown
            }
            .padding(DSSpacing.md)
            .padding(.bottom, DSSpacing.xl)
        }
        .background(dsColors.background.ignoresSafeArea())
        .navigationTitle(Text("Test Results", bundle: .module))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    onDone()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
        }
        .onAppear {
            tabBarVisibility.isVisible = false
        }
    }

    // MARK: - Score hero

    private var scoreHero: some View {
        VStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 10)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: min(max(result.scorePercentage / 100, 0), 1))
                    .stroke(Color.white, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.6), value: result.scorePercentage)

                VStack(spacing: 2) {
                    Text("\(Int(result.scorePercentage))%")
                        .dsFont(DSTypography.headlineLarge)
                        .foregroundColor(.white)
                    Text("Score", bundle: .module)
                        .dsFont(DSTypography.labelMedium)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.top, DSSpacing.sm)

            Text("\(result.correctQuestions) of \(result.totalQuestions) questions recited perfectly", bundle: .module)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DSSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.xl)
        .padding(.horizontal, DSSpacing.md)
        .background(heroGradient)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.xl2))
        .dsElevation(DSElevation.level3)
        .padding(.top, DSSpacing.sm)
    }

    private var heroGradient: LinearGradient {
        result.scorePercentage >= 70 ? DSGradients.success : DSGradients.hero
    }

    // MARK: - Stats

    private var statsRow: some View {
        HStack(spacing: DSSpacing.sm) {
            statCard(icon: "checkmark.seal.fill", value: "\(result.correctQuestions)/\(result.totalQuestions)", label: "Perfect", tint: dsColors.success)
            statCard(icon: "exclamationmark.triangle.fill", value: "\(result.totalMistakes)", label: "Mistakes", tint: dsColors.warning)
            statCard(icon: "text.word.spacing", value: "\(result.totalWordsRecited)", label: "Words", tint: dsColors.info)
        }
    }

    private func statCard(icon: String, value: String, label: LocalizedStringKey, tint: Color) -> some View {
        VStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(tint)
            Text(value)
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
            Text(label, bundle: .module)
                .dsFont(DSTypography.labelSmall)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DSSpacing.smMd)
        .background(dsColors.surfaceContainerLowest)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
        .dsElevation(DSElevation.level1)
    }

    // MARK: - Question breakdown

    private var questionBreakdown: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("Question breakdown", bundle: .module)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textSecondary)
                .padding(.horizontal, DSSpacing.xs)

            VStack(spacing: DSSpacing.sm) {
                ForEach(result.questionResults.indices, id: \.self) { i in
                    let questionResult = result.questionResults[i]

                    HStack(spacing: DSSpacing.smMd) {
                        ZStack {
                            Circle()
                                .fill(questionResult.isFullyCorrect ? dsColors.successContainer : dsColors.errorContainer)
                                .frame(width: 36, height: 36)
                            Image(systemName: questionResult.isFullyCorrect ? "checkmark" : "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(questionResult.isFullyCorrect ? dsColors.onSuccessContainer : dsColors.onErrorContainer)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Question \(questionResult.question.index)", bundle: .module)
                                .dsFont(DSTypography.titleSmall)
                                .foregroundColor(dsColors.textPrimary)
                            Text("Surah \(questionResult.question.surah) · Ayah \(questionResult.question.startAyah)–\(questionResult.question.endAyah)", bundle: .module)
                                .dsFont(DSTypography.bodySmall)
                                .foregroundColor(dsColors.textSecondary)
                        }

                        Spacer()

                        if questionResult.mistakeCount > 0 {
                            Text("\(questionResult.mistakeCount) mistake(s)", bundle: .module)
                                .dsFont(DSTypography.labelSmall)
                                .foregroundColor(dsColors.error)
                                .padding(.horizontal, DSSpacing.sm)
                                .padding(.vertical, DSSpacing.xxs)
                                .background(dsColors.errorContainer)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(DSSpacing.smMd)
                    .background(dsColors.surfaceContainerLowest)
                    .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg))
                }
            }
        }
    }
}
