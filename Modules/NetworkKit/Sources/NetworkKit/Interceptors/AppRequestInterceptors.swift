//
//  AppRequestInterceptors.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation
import Alamofire

public final class AppRequestInterceptors: RequestInterceptor, @unchecked
    Sendable
{

    public static let shared = AppRequestInterceptors()

    public var tokenProvider: (() -> String?)?
    public var onRefreshNeeded: ((@escaping @Sendable (Bool) -> Void) -> Void)?

    private init() {}


    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        if let token = tokenProvider?() {
            request.setValue(
                "Bearer \(token)",
                forHTTPHeaderField: "Authorization"
            )
        }
        completion(.success(request))
    }

    // MARK: - Retry: 401 → refresh → retry once

    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping @Sendable (RetryResult) -> Void
    ) {
        guard
            let response = request.task?.response as? HTTPURLResponse,
            response.statusCode == 401,
            request.retryCount == 0,
            let onRefreshNeeded
        else {
            completion(.doNotRetry)
            return
        }

        onRefreshNeeded { success in
            completion(success ? .retry : .doNotRetry)
        }
    }
}
