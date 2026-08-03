//
//  ProcessCardPaymentUseCase.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation

// MARK: - ProcessCardPaymentUseCase Protocol

public protocol ProcessCardPaymentUseCase: Sendable {
    func execute(
        package: SubscriptionPackage,
        provider: CardProvider,
        cardNumber: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        holderName: String
    ) async throws -> CardPaymentResult
}

// MARK: - Implementation

/// Validates the card details then delegates to the `CardPaymentRepositoryProtocol`.
public final class ProcessCardPaymentUseCaseImpl: ProcessCardPaymentUseCase {
    
    // MARK: Init
    
    private let repository: CardPaymentRepositoryProtocol
    
    public init(repository: CardPaymentRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: Execute
    
    public func execute(
        package: SubscriptionPackage,
        provider: CardProvider,
        cardNumber: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        holderName: String
    ) async throws -> CardPaymentResult {
        
        // Validate card details
        try validateCardNumber(cardNumber)
        try validateExpiryDate(month: expiryMonth, year: expiryYear)
        try validateCVV(cvv)
        try validateHolderName(holderName)
        
        // Delegate to repository
        return try await repository.processCardPayment(
            package: package,
            provider: provider,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvv: cvv,
            holderName: holderName
        )
    }
    
    // MARK: Validation
    
    private func validateCardNumber(_ number: String) throws {
        let digits = number.filter(\.isNumber)
        guard !digits.isEmpty else {
            throw CardPaymentError.invalidCardNumber
        }
        
        var sum = 0
        let reversedCharacters = digits.reversed().map { String($0) }
        
        for (index, element) in reversedCharacters.enumerated() {
            guard let digit = Int(element) else {
                throw CardPaymentError.invalidCardNumber
            }
            if index % 2 != 0 {
                var modifiedDigit = digit * 2
                if modifiedDigit > 9 {
                    modifiedDigit -= 9
                }
                sum += modifiedDigit
            } else {
                sum += digit
            }
        }
        
        guard sum % 10 == 0 else {
            throw CardPaymentError.invalidCardNumber
        }
    }
    
    private func validateExpiryDate(month: String, year: String) throws {
        guard let monthInt = Int(month), let yearInt = Int(year),
              (1...12).contains(monthInt) else {
            throw CardPaymentError.invalidExpiryDate
        }
        
        let currentYear = Calendar.current.component(.year, from: Date()) % 100
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if yearInt < currentYear || (yearInt == currentYear && monthInt < currentMonth) {
            throw CardPaymentError.invalidExpiryDate
        }
    }
    
    private func validateCVV(_ cvv: String) throws {
        let digits = cvv.filter(\.isNumber)
        guard digits.count == 3 || digits.count == 4 else {
            throw CardPaymentError.invalidCVV
        }
    }
    
    private func validateHolderName(_ name: String) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CardPaymentError.invalidHolderName
        }
    }
}
