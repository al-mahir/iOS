//
//  WalletPaymentMapper.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Foundation


struct WalletPaymentMapper {

   

    func toRequestDTO(
        package: SubscriptionPackage,
        provider: WalletProvider,
        phoneNumber: String
    ) -> WalletPaymentRequestDTO {
        WalletPaymentRequestDTO(
            packageID: package.id,
            walletProvider: provider.rawValue,
            phoneNumber: phoneNumber,
            amount: NSDecimalNumber(decimal: package.priceEGP).doubleValue,
            currency: "EGP"
        )
    }

    func toDomain(
        dto: WalletPaymentResponseDTO,
        provider: WalletProvider
    ) throws -> PaymentResult {
        let timestamp = parseTimestamp(dto.timestamp) ?? Date()
        let masked    = maskPhoneNumber(dto.phoneNumber)
        let amount    = Decimal(dto.amount)

        return PaymentResult(
            transactionID: dto.transactionID,
            amount: amount,
            walletProvider: provider,
            packageTitle: dto.packageTitle,
            timestamp: timestamp,
            maskedPhoneNumber: masked
        )
    }



    private func parseTimestamp(_ raw: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: raw) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: raw)
    }

    /// Masks the middle digits of a phone number.
    /// "01012345678" → "010*****678"
    private func maskPhoneNumber(_ number: String) -> String {
        let digits = number.filter(\.isNumber)
        guard digits.count >= 7 else { return number }
        let prefix = String(digits.prefix(3))
        let suffix = String(digits.suffix(3))
        let maskCount = digits.count - 6
        let mask = String(repeating: "*", count: maskCount)
        return "\(prefix)\(mask)\(suffix)"
    }
}
