//
//  CardPaymentRequestDTO.swift
//  Payment
//
//  Created by Alaa Ayman on 19/02/1448 AH.
//


import Foundation

struct CardPaymentRequestDTO: Encodable, Sendable {
    let packageID: String
    let amount: Double
    let currency: String
    let cardNumber: String
    let expiryMonth: String
    let expiryYear: String
    let cvv: String
    let holderName: String
    let cardProvider: String
}
