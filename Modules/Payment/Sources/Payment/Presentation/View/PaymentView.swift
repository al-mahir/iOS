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
    @State private var showCheckout = false
    @State private var checkoutClientSecret = ""
    @State private var checkoutPublicKey = ""
    @State private var checkoutIntentionId = ""

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
                    Text(LocalizedStringKey("checkout.title"), bundle: .paymentBundle)
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
            .sheet(isPresented: $showCheckout) {
                NavigationStack {
                    PaymobCheckoutWebView(
                        clientSecret: checkoutClientSecret,
                        publicKey: checkoutPublicKey,
                        onComplete: { success in
                            showCheckout = false
                            if success {
                                viewModel.confirmPaymentManually(transactionID: checkoutIntentionId)
                            } else {
                                viewModel.resetState()
                            }
                        }
                    )
                    .navigationTitle(Text(LocalizedStringKey("paymob.checkout.title"), bundle: .paymentBundle))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(String(localized: "close.button", bundle: .paymentBundle)) {
                                showCheckout = false
                                viewModel.resetState()
                            }
                        }
                    }
                }
            }
            .onChange(of: viewModel.viewState) { _, newState in
                switch newState {
                case .success(let result):
                    successResult = result
                    showSuccess = true
                case .cardSuccess(let result):
                    // Persist to shared store so Profile/MySubscriptions shows it immediately
                    let pkg = viewModel.package
                    SubscriptionStore.shared.add(ActiveSubscription(
                        transactionID: result.transactionID,
                        packageTitle: pkg.title,
                        packageSubtitle: pkg.subtitle,
                        price: pkg.priceEGP,
                        currencyCode: "EGP",
                        reciterName: pkg.reciterName,
                        startDate: Date(),
                        endDate: Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
                    ))
                    cardSuccessResult = result
                    showCardSuccess = true
                case .awaitingConfirmation(let txnID):
                    awaitingTransactionID = txnID
                    showAwaiting = true
                case .checkout(let cs, let pk, let id):
                    checkoutClientSecret = cs
                    checkoutPublicKey = pk
                    checkoutIntentionId = id
                    showCheckout = true
                default:
                    break
                }
            }
            .alert(Text(LocalizedStringKey("payment.failed.title"), bundle: .paymentBundle), isPresented: .constant({
                if case .error = viewModel.viewState { return true }
                return false
            }())) {
                Button(String(localized: "try.again.button", bundle: .paymentBundle)) { viewModel.resetState() }
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
                Text(LocalizedStringKey("header.secured.by"), bundle: .paymentBundle)
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
            methodTab(titleKey: "method.wallet", method: .wallet)
            methodTab(titleKey: "method.card", method: .card)
        }
        .background(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .fill(dsColors.surfaceContainerLow)
        )
        .padding(.vertical, DSSpacing.sm)
    }

    private func methodTab(titleKey: LocalizedStringKey, method: PaymentMethod) -> some View {
        let isSelected = viewModel.selectedPaymentMethod == method
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                viewModel.selectedPaymentMethod = method
            }
        } label: {
            Text(titleKey, bundle: .paymentBundle)
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
                titleKey: "section.select.payment.method",
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
                titleKey: "section.wallet.number.title",
                icon: "iphone.radiowaves.left.and.right"
            )

            DSTextField(
                label: nil,
                placeholder: String(localized: "wallet.number.placeholder", bundle: .paymentBundle),
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
                    Text(String(format: String(localized: "wallet.number.enter.hint", bundle: .paymentBundle), provider.displayName))
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
                titleKey: "section.select.card.brand",
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

            Text(LocalizedStringKey("security.note"), bundle: .paymentBundle)
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
                    Text(String(format: String(localized: "pay.button.title", bundle: .paymentBundle), viewModel.package.formattedPrice))
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
                    Text(LocalizedStringKey("hint.select.wallet"), bundle: .paymentBundle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                } else if !viewModel.canPay {
                    Text(LocalizedStringKey("hint.enter.valid.phone"), bundle: .paymentBundle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                }
            } else {
                if viewModel.selectedCardProvider == nil {
                    Text(LocalizedStringKey("hint.select.card"), bundle: .paymentBundle)
                        .dsFont(DSTypography.bodySmall)
                        .foregroundColor(dsColors.textHint)
                        .transition(.opacity)
                } else if !viewModel.canPayCard {
                    Text(LocalizedStringKey("hint.enter.valid.card"), bundle: .paymentBundle)
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

                Text(LocalizedStringKey("loading.processing.payment"), bundle: .paymentBundle)
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
    let titleKey: LocalizedStringKey
    let icon: String
    @Environment(\.dsColors) private var dsColors

    var body: some View {
        HStack(spacing: DSSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(dsColors.primary)

            Text(titleKey, bundle: .paymentBundle)
                .dsFont(DSTypography.titleSmall)
                .foregroundColor(dsColors.textPrimary)
        }
    }
}
