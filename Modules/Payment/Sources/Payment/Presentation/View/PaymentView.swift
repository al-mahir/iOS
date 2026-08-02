//
//  PaymentView.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import SwiftUI
import Common

// MARK: - PaymentView

/// The primary payment screen.
/// Presents the subscription summary, wallet provider selection grid,
/// mobile number entry field, and a "Pay Now" CTA.
public struct PaymentView: View {

    // MARK: Dependencies

    @StateObject private var viewModel: PaymentViewModel

    // MARK: Local State

    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @State private var showSuccess = false
    @State private var successResult: PaymentResult?
    @State private var showCardSuccess = false
    @State private var cardSuccessResult: CardPaymentResult?
    @State private var showAwaiting = false
    @State private var awaitingTransactionID = ""

    // MARK: Init

    public init(viewModel: PaymentViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: Body

    public var body: some View {
        NavigationStack {
            ZStack {
                // Background
                dsColors.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: DSSpacing.lg) {

                        // ── 1. Header ──────────────────────────────────────
                        headerSection

                        // ── 2. Package summary ────────────────────────────
                        SubscriptionSummaryCard(package: viewModel.package)
                            .padding(.horizontal, DSSpacing.md)

                        // ── 3. Payment method selector ──────────────────────
                        methodSelector
                            .padding(.horizontal, DSSpacing.md)

                        if viewModel.selectedPaymentMethod == .wallet {
                            // ── 4a. Wallet Provider Grid ───────────────────────────
                            walletSection
                                .padding(.horizontal, DSSpacing.md)

                            // ── 5a. Wallet number input ─────────────────────────
                            numberInputSection
                                .padding(.horizontal, DSSpacing.md)
                        } else {
                            // ── 4b. Card Provider Grid ───────────────────────────
                            cardSection
                                .padding(.horizontal, DSSpacing.md)
                                
                            // ── 5b. Card details input ─────────────────────────
                            cardInputSection
                                .padding(.horizontal, DSSpacing.md)
                        }

                        // ── 5. Security note ───────────────────────────────
                        securityNote
                            .padding(.horizontal, DSSpacing.md)

                        // ── 6. Pay button ──────────────────────────────────
                        payButton
                            .padding(.horizontal, DSSpacing.md)
                            .padding(.bottom, DSSpacing.xl2)
                    }
                    .padding(.top, DSSpacing.sm)
                }

                // Loading overlay
                if viewModel.viewState == .loading {
                    loadingOverlay
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(dsColors.textPrimary)
                            .padding(DSSpacing.sm)
                            .background(
                                Circle()
                                    .fill(dsColors.surfaceContainerLow)
                            )
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Checkout")
                        .dsFont(DSTypography.titleMedium)
                        .foregroundColor(dsColors.textPrimary)
                }
            }
            .navigationDestination(isPresented: $showSuccess) {
                if let result = successResult {
                    PaymentSuccessView(result: result, onDone: {
                        showSuccess = false
                        dismiss()
                    })
                }
            }
            .navigationDestination(isPresented: $showCardSuccess) {
                if let result = cardSuccessResult {
                    CardSuccessView(result: result, onDone: {
                        showCardSuccess = false
                        dismiss()
                    })
                }
            }
            .navigationDestination(isPresented: $showAwaiting) {
                PaymentAwaitingView(
                    transactionID: awaitingTransactionID,
                    provider: viewModel.selectedProvider ?? .vodafoneCash,
                    maskedPhone: viewModel.walletNumber,
                    onConfirmed: {
                        viewModel.confirmPaymentManually(transactionID: awaitingTransactionID)
                        showAwaiting = false
                    },
                    onCancel: {
                        showAwaiting = false
                        viewModel.resetState()
                    }
                )
            }
            .onChange(of: viewModel.viewState) { _, newState in
                switch newState {
                case .success(let result):
                    successResult = result
                    showSuccess = true
                case .cardSuccess(let result):
                    cardSuccessResult = result
                    showCardSuccess = true
                case .awaitingConfirmation(let txnID):
                    awaitingTransactionID = txnID
                    showAwaiting = true
                default:
                    break
                }
            }
            .alert("Payment Failed", isPresented: .constant({
                if case .error = viewModel.viewState { return true }
                return false
            }())) {
                Button("Try Again") { viewModel.resetState() }
            } message: {
                if case .error(let msg) = viewModel.viewState {
                    Text(msg)
                }
            }
        }
        .dsTheme()
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: DSSpacing.xs) {
            // Paymob badge
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 12))
                    .foregroundColor(dsColors.success)
                Text("Secured by Paymob")
                    .dsFont(DSTypography.labelSmall)
                    .foregroundColor(dsColors.textSecondary)
            }
            .padding(.horizontal, DSSpacing.smMd)
            .padding(.vertical, DSSpacing.xs)
            .background(
                Capsule()
                    .fill(dsColors.successContainer.opacity(0.5))
            )
        }
        .padding(.top, DSSpacing.sm)
    }

    // MARK: Method Selector

    private var methodSelector: some View {
        HStack(spacing: DSSpacing.none) {
            methodTab(title: "Mobile Wallet", method: .wallet)
            methodTab(title: "Credit/Debit Card", method: .card)
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
        .padding(.vertical, DSSpacing.sm)
    }

    private func methodTab(title: String, method: PaymentMethod) -> some View {
        let isSelected = viewModel.selectedPaymentMethod == method
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedPaymentMethod = method
            }
        } label: {
            Text(title)
                .dsFont(DSTypography.labelMedium)
                .foregroundColor(isSelected ? .white : dsColors.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DSSpacing.smMd)
                .background(
                    RoundedRectangle(cornerRadius: DSRadius.md)
                        .fill(isSelected ? dsColors.primary : Color.clear)
                        .padding(DSSpacing.xs)
                )
        }
    }

    // MARK: Wallet Provider Grid

    private var walletSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.smMd) {

            SectionHeader(
                title: "Select Payment Method",
                icon: "wallet.pass.fill"
            )

            // 2×2 grid
            let columns = [
                GridItem(.flexible(), spacing: DSSpacing.smMd),
                GridItem(.flexible(), spacing: DSSpacing.smMd)
            ]

            LazyVGrid(columns: columns, spacing: DSSpacing.smMd) {
                ForEach(WalletProvider.allCases) { provider in
                    WalletProviderCard(
                        provider: provider,
                        isSelected: viewModel.selectedProvider == provider,
                        onTap: { viewModel.selectProvider(provider) }
                    )
                }
            }

            // Provider hint
            if let provider = viewModel.selectedProvider {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(dsColors.info)
                    Text(provider.tagline)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedProvider)
            }
        }
    }

    // MARK: Phone Number Input

    private var numberInputSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.smMd) {

            SectionHeader(
                title: "Mobile Wallet Number",
                icon: "iphone.radiowaves.left.and.right"
            )

            DSTextField(
                label: nil,
                placeholder: "e.g. 01012345678",
                text: $viewModel.walletNumber,
                leadingIcon: "phone.fill",
                errorMessage: viewModel.phoneError,
                keyboardType: .phonePad,
                autocapitalization: .never,
                autocorrectionDisabled: true
            )

            if let provider = viewModel.selectedProvider {
                HStack(spacing: DSSpacing.xs) {
                    Circle()
                        .fill(Color(hex: provider.brandPrimaryHex))
                        .frame(width: 6, height: 6)
                    Text("Enter your \(provider.displayName) number")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedProvider)
            }
        }
    }

    // MARK: Card Section

    private var cardSection: some View {
        VStack(alignment: .leading, spacing: DSSpacing.smMd) {
            SectionHeader(
                title: "Select Card Brand",
                icon: "creditcard.fill"
            )

            let columns = [
                GridItem(.flexible(), spacing: DSSpacing.smMd),
                GridItem(.flexible(), spacing: DSSpacing.smMd)
            ]

            LazyVGrid(columns: columns, spacing: DSSpacing.smMd) {
                ForEach(CardProvider.allCases) { provider in
                    CardProviderCard(
                        provider: provider,
                        isSelected: viewModel.selectedCardProvider == provider,
                        onTap: { viewModel.selectCardProvider(provider) }
                    )
                }
            }

            if let provider = viewModel.selectedCardProvider {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(dsColors.info)
                    Text(provider.tagline)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textSecondary)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.2), value: viewModel.selectedCardProvider)
            }
        }
    }

    // MARK: Card Input Section

    private var cardInputSection: some View {
        CardInputSection(
            cardNumber: $viewModel.cardNumber,
            expiryDate: $viewModel.expiryDate,
            cvv: $viewModel.cvv,
            holderName: $viewModel.holderName,
            errorMessage: viewModel.cardError
        )
    }

    // MARK: Security Note

    private var securityNote: some View {
        HStack(alignment: .top, spacing: DSSpacing.sm) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundColor(dsColors.textSecondary)
                .padding(.top, 1)

            Text("Your payment is processed securely. We never store your wallet credentials.")
                .dsFont(DSTypography.bodySmall)
                .foregroundColor(dsColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DSSpacing.smMd)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.sm)
                .fill(dsColors.surfaceContainerLow)
        )
    }

    // MARK: Pay Button

    private var payButton: some View {
        VStack(spacing: DSSpacing.sm) {
            Button {
                if viewModel.selectedPaymentMethod == .wallet {
                    viewModel.pay()
                } else {
                    viewModel.payWithCard()
                }
            } label: {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16))
                    Text("Pay \(viewModel.package.formattedPrice)")
                        .dsFont(DSTypography.buttonText)
                }
                .padding(.vertical, DSSpacing.smMd)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(DSPrimaryButtonStyle())
            .disabled(viewModel.selectedPaymentMethod == .wallet ? (!viewModel.canPay || viewModel.viewState == .loading) : (!viewModel.canPayCard || viewModel.viewState == .loading))

            // Hint under button
            if viewModel.selectedPaymentMethod == .wallet {
                if viewModel.selectedProvider == nil {
                    Text("Select a wallet provider to continue")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                } else if !viewModel.canPay {
                    Text("Enter a valid 11-digit mobile number")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                }
            } else {
                if viewModel.selectedCardProvider == nil {
                    Text("Select a card brand to continue")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                } else if !viewModel.canPayCard {
                    Text("Enter valid card details")
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedPaymentMethod == .wallet ? viewModel.canPay : viewModel.canPayCard)
    }

    // MARK: Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .transition(.opacity)

            VStack(spacing: DSSpacing.md) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)

                Text("Processing payment…")
                    .dsFont(DSTypography.bodyMedium)
                    .foregroundColor(.white)
            }
            .padding(DSSpacing.xl)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.xl)
                    .fill(Color(hex: "#014F39").opacity(0.9))
                    .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 8)
            )
        }
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.25), value: viewModel.viewState == .loading)
    }
}

// MARK: - SectionHeader

private struct SectionHeader: View {
    let title: String
    let icon: String
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(dsColors.primary)

            Text(title)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
        }
    }
}
