import Common
//
//  SheikhListView.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import SwiftUI

public struct SheikhListView: View {

    @StateObject private var viewModel = SheikhListViewModel()
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSheikh: Sheikh? = nil
    @State private var navigateToDetail: Bool = false

    public init() {}

    public var body: some View {
        VStack(spacing: DSSpacing.none) {

            SheikhHeaderBanner(
                title: "Sheikhs",
                onLeadingTap: {
                    dismiss()
                }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.none) {
                    // Search bar
                    searchBar
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.top, DSSpacing.md)

                    // Filter chips
                    SheikhFilterChips(selected: $viewModel.selectedFilter)
                        .padding(.top, DSSpacing.smMd)

                    // Count label
                    if !viewModel.isLoading {
                        Text(
                            "\(viewModel.displayedSheikhs.count) sheikhs available"
                        )
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.top, DSSpacing.sm)
                    }

                    // Error banner
                    if let error = viewModel.errorMessage {
                        errorBanner(message: error)
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.top, DSSpacing.sm)
                            .transition(
                                .opacity.combined(with: .move(edge: .top))
                            )
                    }

                    // Loading skeleton / list
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
                    } else {
                        sheikhList
                    }
                }
            }
            .background(dsColors.background)
        }
        .background(dsColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .animation(.easeInOut(duration: 0.25), value: viewModel.errorMessage)
        .animation(.easeInOut(duration: 0.2), value: viewModel.isLoading)
        .navigationDestination(isPresented: $navigateToDetail) {
            if let sheikh = selectedSheikh {
                SheikhDetailView(sheikh: sheikh)
                    .dsTheme()
            }
        }
        .onAppear {
            viewModel.loadSheikhs()
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
                .font(.system(size: 16))

            TextField("Search here...", text: $viewModel.searchText)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
    }

    // MARK: - Sheikh List

    private var sheikhList: some View {
        LazyVStack(spacing: DSSpacing.none) {
            ForEach(viewModel.displayedSheikhs) { sheikh in
                Button {
                    selectedSheikh = sheikh
                    navigateToDetail = true
                } label: {
                    SheikhListRow(sheikh: sheikh)
                }
                .buttonStyle(.plain)

                if sheikh.id != viewModel.displayedSheikhs.last?.id {
                    Divider()
                        .padding(.horizontal, DSSpacing.md)
                        .foregroundColor(dsColors.outlineVariant)
                }
            }

            if viewModel.displayedSheikhs.isEmpty && !viewModel.isLoading {
                emptyState
                    .padding(.top, DSSpacing.xl2)
            }
        }
        .padding(.top, DSSpacing.sm)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: DSSpacing.sm) {
            Image(systemName: "person.slash")
                .font(.system(size: 40))
                .foregroundColor(dsColors.textHint)

            Text("No sheikhs found")
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error Banner

    private func errorBanner(message: String) -> some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(dsColors.error)

            Text(message)
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.error)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                viewModel.clearError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(dsColors.error)
            }
        }
        .padding(DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(dsColors.errorContainer)
        )
    }
}
