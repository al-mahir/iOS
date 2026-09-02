//
//  APISuccessResponse.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation

public struct APISuccessResponse<T: Decodable>: Decodable {
    public let success: Bool
    public let message: String
    public let data: T
    public let timestamp: String?
}
