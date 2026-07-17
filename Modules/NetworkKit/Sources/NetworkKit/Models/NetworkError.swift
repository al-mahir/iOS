//
//  NetworkError.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation

public enum NetworkError: Error, LocalizedError{
    case invalidURL
    case noInternetConnection
    case decodingFailed
    case timeout
    case cancelled
    case unauthorized(message: String)
    case notFound(message: String)
    case validationFailed(message: String, fieldErrors: [String: String])
    case serverError(statusCode: Int, message: String)
    case unknown(message: String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noInternetConnection:
            return "Please check your internet connection."
        case .decodingFailed:
            return "An error occurred while processing the data."
        case .timeout:
            return "The request timed out. Please try again."
        case .cancelled:
            return "The request was cancelled."
        case .unauthorized(let message),
             .notFound(let message),
             .validationFailed(let message, _),
             .unknown(let message):
            return message
        case .serverError(_, let message):
            return message
        }
    }
}
