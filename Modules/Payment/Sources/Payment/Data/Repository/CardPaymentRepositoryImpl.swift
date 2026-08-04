//
//  CardPaymentRepositoryImpl.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//
import Foundation




final class CardPaymentRepositoryImpl: CardPaymentRepositoryProtocol, Sendable {
    
    
    private let dataSource: CardPaymentDataSourceProtocol
    private let mapper: CardPaymentMapper

    
    init(dataSource: CardPaymentDataSourceProtocol, mapper: CardPaymentMapper = CardPaymentMapper()) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
   
    
    func processCardPayment(
        package: SubscriptionPackage,
        provider: CardProvider,
        cardNumber: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        holderName: String
    ) async throws -> CardPaymentResult {
        
     
        let requestDTO = mapper.toRequestDTO(
            package: package,
            provider: provider,
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvv: cvv,
            holderName: holderName
        )
        
    
        let responseDTO = try await dataSource.processPayment(requestDTO)
        

        let maskedCardNumber = maskCardNumber(cardNumber)
        return try mapper.toDomain(
            dto: responseDTO,
            provider: provider,
            maskedCardNumber: maskedCardNumber
        )
    }

    
    private func maskCardNumber(_ number: String) -> String {
        let digits = number.filter(\.isNumber)
        guard digits.count >= 4 else { return number }
        let last4 = String(digits.suffix(4))
        // Assuming 16 digits format for Visa/Mastercard
        return "**** **** **** \(last4)"
    }
}
