//
//  CardPaymentResponseDTO.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//

import Foundation


struct CardPaymentResponseDTO: Decodable, Sendable {
    let transactionID: String
    let status: String
    let amount: Double
    let cardProvider: String
    let last4: String
    let packageTitle: String
    let timestamp: String
    let message: String
}
