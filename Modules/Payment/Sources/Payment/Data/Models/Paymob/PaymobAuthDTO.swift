//
//  PaymobAuthDTO.swift
//  Payment — Step 1: Authentication
//
//  POST https://accept.paymob.com/api/auth/tokens
//  Body:  { "api_key": "..." }
//  Returns: { "token": "...", "profile": {...} }
//

import Foundation

// MARK: - Request

struct PaymobAuthRequestDTO: Encodable {
    let api_key: String
}

// MARK: - Response

struct PaymobAuthResponseDTO: Decodable {
    /// Short-lived auth token used in subsequent calls.
    let token: String
}
