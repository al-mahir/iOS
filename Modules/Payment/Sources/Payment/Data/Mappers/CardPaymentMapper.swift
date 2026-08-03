//
//  CardPaymentMapper.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation



struct CardPaymentMapper: Sendable {
    

    
    func toRequestDTO(
        package: SubscriptionPackage,
        provider: CardProvider,
        cardNumber: String,
        expiryMonth: String,
        expiryYear: String,
        cvv: String,
        holderName: String
    ) -> CardPaymentRequestDTO {
        CardPaymentRequestDTO(
            packageID: package.id,
            amount: NSDecimalNumber(decimal: package.priceEGP).doubleValue,
            currency: "EGP",
            cardNumber: cardNumber,
            expiryMonth: expiryMonth,
            expiryYear: expiryYear,
            cvv: cvv,
            holderName: holderName,
            cardProvider: provider.rawValue
        )
    }
    

    
    func toDomain(
        dto: CardPaymentResponseDTO,
        provider: CardProvider,
        maskedCardNumber: String
    ) throws -> CardPaymentResult {
        let timestamp = parseTimestamp(dto.timestamp) ?? Date()
        let amount = Decimal(dto.amount)
        
        return CardPaymentResult(
            transactionID: dto.transactionID,
            amount: amount,
            cardProvider: provider,
            packageTitle: dto.packageTitle,
            timestamp: timestamp,
            maskedCardNumber: maskedCardNumber,
            last4: dto.last4
        )
    }
    

    
    private func parseTimestamp(_ raw: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: raw) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: raw)
    }
}
