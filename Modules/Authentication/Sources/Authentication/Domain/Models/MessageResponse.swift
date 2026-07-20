//
//  MessageResponse.swift
//  Authentication
//
//  Created by Nadin Ahmed on 19/07/2026.
//
import Foundation

struct MessageResponse: Decodable {
    let success: Bool
    let message: String
    let timestamp: String
}
