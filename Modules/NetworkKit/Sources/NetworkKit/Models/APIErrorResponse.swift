//
//  APIErrorResponse.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation

public struct APIErrorResponse: Decodable {
    public let success: Bool
    public let message: String
    public let fieldErrors: [String: String]?
    public let timestamp: String?
}
