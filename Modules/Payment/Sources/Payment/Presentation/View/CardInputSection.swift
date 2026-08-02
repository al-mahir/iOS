//
//  CardInputSection.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import SwiftUI
import Common

struct CardInputSection: View {
    @Binding var cardNumber: String
    @Binding var expiryDate: String
    @Binding var cvv: String
    @Binding var holderName: String
    var errorMessage: String?

    @Environment(\.dsColors) private var dsColors

    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.md) {
            
            // Header
            HStack(spacing: DSSpacing.xs) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(dsColors.primary)
                Text("Card Details")
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)
            }
            
            VStack(spacing: DSSpacing.smMd) {
                // Card Number
                DSTextField(
                    label: "Card Number",
                    placeholder: "0000 0000 0000 0000",
                    text: Binding(
                        get: { cardNumber },
                        set: { cardNumber = formatCardNumber($0) }
                    ),
                    leadingIcon: detectedCardIcon(for: cardNumber),
                    errorMessage: nil,
                    keyboardType: .numberPad
                )
                
                HStack(spacing: DSSpacing.smMd) {
                    // Expiry Date
                    DSTextField(
                        label: "Expiry Date",
                        placeholder: "MM/YY",
                        text: Binding(
                            get: { expiryDate },
                            set: { expiryDate = formatExpiryDate($0) }
                        ),
                        leadingIcon: "calendar",
                        errorMessage: nil,
                        keyboardType: .numberPad
                    )
                    
                    // CVV
                    DSTextField(
                        label: "CVV",
                        placeholder: "123",
                        text: Binding(
                            get: { cvv },
                            set: { cvv = String($0.prefix(4)) }
                        ),
                        isSecure: true,
                        leadingIcon: "lock.fill",
                        errorMessage: nil,
                        keyboardType: .numberPad
                    )
                }
                
                // Holder Name
                DSTextField(
                    label: "Cardholder Name",
                    placeholder: "Name on card",
                    text: $holderName,
                    leadingIcon: "person.fill",
                    errorMessage: errorMessage, // Show overarching errors here
                    keyboardType: .default,
                    autocapitalization: .words
                )
            }
            .padding(DSSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .fill(dsColors.surfaceContainerLow.opacity(0.5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.lg)
                    .strokeBorder(dsColors.outlineVariant, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Formatting Helpers
    
    private func formatCardNumber(_ newValue: String) -> String {
        let digits = newValue.filter(\.isNumber)
        var result = ""
        for (index, character) in digits.enumerated() {
            if index != 0 && index % 4 == 0 {
                result.append(" ")
            }
            result.append(character)
        }
        return String(result.prefix(19)) // 16 digits + 3 spaces
    }
    
    private func formatExpiryDate(_ newValue: String) -> String {
        let digits = newValue.filter(\.isNumber)
        var result = ""
        for (index, character) in digits.enumerated() {
            if index == 2 {
                result.append("/")
            }
            result.append(character)
        }
        return String(result.prefix(5)) // MM/YY
    }
    
    private func detectedCardIcon(for number: String) -> String {
        let digits = number.filter(\.isNumber)
        if digits.hasPrefix("4") {
            return "creditcard.fill" // Visa-like
        } else if digits.hasPrefix("5") {
            return "creditcard.circle.fill" // MC-like
        }
        return "creditcard"
    }
}
