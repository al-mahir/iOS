//
//  PaymobNetworkService.swift
//  Payment
//
//  Created by Al-Mahir on 31/07/2026.
//

import Foundation

private final class PaymentBundleToken {}

// MARK: - PaymobNetworkError

enum PaymobNetworkError: LocalizedError {
    case invalidURL
    case httpError(statusCode: Int, body: String)
    case decodingFailed(Error)
    case noData
    case underlying(Error)

    private static var bundle: Bundle {
        #if SWIFTPM
        return Bundle.module
        #else
        return Bundle(for: PaymentBundleToken.self)
        #endif
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString(
                "paymob_error_invalid_url",
                bundle: Self.bundle,
                value: "Invalid Paymob API URL.",
                comment: "Error description when Paymob API URL is invalid"
            )
        case .httpError(let code, let body):
            let format = NSLocalizedString(
                "paymob_error_http_format",
                bundle: Self.bundle,
                value: "Paymob API error %d: %@",
                comment: "Error description format for Paymob HTTP errors containing status code and response body"
            )
            return String(format: format, code, body)
        case .decodingFailed(let error):
            let format = NSLocalizedString(
                "paymob_error_decoding_format",
                bundle: Self.bundle,
                value: "Failed to decode Paymob response: %@",
                comment: "Error description format when Paymob response decoding fails"
            )
            return String(format: format, error.localizedDescription)
        case .noData:
            return NSLocalizedString(
                "paymob_error_no_data",
                bundle: Self.bundle,
                value: "Paymob returned empty response.",
                comment: "Error description when Paymob API returns no data"
            )
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}

// MARK: - PaymobNetworkService

/// Lightweight URLSession-based HTTP client for Paymob API calls.
/// Self-contained — does not depend on the app's NetworkKit/Alamofire stack.
final class PaymobNetworkService: Sendable {

    private let baseURL: String   // e.g. "https://accept.paymob.com/api"
    private let session: URLSession

    init(baseURL: URL, session: URLSession = .shared) {
        // Store as string, strip trailing slash for clean concatenation
        var s = baseURL.absoluteString
        while s.hasSuffix("/") { s.removeLast() }
        self.baseURL = s
        self.session = session
    }

    // MARK: POST

    /// Sends a JSON POST request and decodes the response into `T`.
    func post<Body: Encodable, Response: Decodable>(
        path: String,
        body: Body,
        headers: [String: String] = [:]
    ) async throws -> Response {

        // Build URL via simple string concatenation — no component encoding
        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: "\(baseURL)\(cleanPath)") else {
            throw PaymobNetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        // 🔍 Debug: log outgoing request
        print("🔵 [Paymob] POST \(url.absoluteString)")
        print("🔵 [Paymob] Headers: \(request.allHTTPHeaderFields ?? [:])")
        if let bodyData = request.httpBody, let bodyStr = String(data: bodyData, encoding: .utf8) {
            print("🔵 [Paymob] Body: \(bodyStr.prefix(500))")
        }

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse {
            print("🔵 [Paymob] Response status: \(http.statusCode)")
            if !(200...299).contains(http.statusCode) {
                let body = String(data: data, encoding: .utf8) ?? "(no body)"
                print("🔴 [Paymob] Error body: \(body)")
                throw PaymobNetworkError.httpError(statusCode: http.statusCode, body: body)
            }
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            if let raw = String(data: data, encoding: .utf8) {
                print("🔴 [Paymob] Decode failed. Raw: \(raw.prefix(500))")
            }
            throw PaymobNetworkError.decodingFailed(error)
        }
    }

    // MARK: GET

    /// Sends a GET request and decodes the response into `T`.
    func get<Response: Decodable>(
        path: String,
        headers: [String: String] = [:]
    ) async throws -> Response {

        let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
        guard let url = URL(string: "\(baseURL)\(cleanPath)") else {
            throw PaymobNetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        print("🔵 [Paymob] GET \(url.absoluteString)")

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse,
           !(200...299).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "(no body)"
            print("🔴 [Paymob] Error: \(http.statusCode) \(body)")
            throw PaymobNetworkError.httpError(statusCode: http.statusCode, body: body)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw PaymobNetworkError.decodingFailed(error)
        }
    }
}
