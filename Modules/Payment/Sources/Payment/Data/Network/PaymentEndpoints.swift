//
//  PaymentEndpoints.swift
//  Payment
//
//  Created by Al-Mahir.
//

import Foundation
import NetworkKit
import Alamofire

public enum PaymentEndpoints: APIEndpoint {
    case createIntention(
        packageId: String,
        method: String,
        idempotencyKey: String
    )
    case getIntentionStatus(id: String)

    public var baseURL: BaseURLType {
        .almahir
    }

    public var path: String {
        switch self {
        case .createIntention:
            return "payment/intentions"
        case .getIntentionStatus(let id):
            return "payment/intentions/\(id)/status"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .createIntention:
            return .post
        case .getIntentionStatus:
            return .get
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .createIntention(let packageId, let method, let idempotencyKey):
            return [
                "packageId": packageId,
                "method": method,
                "idempotencyKey": idempotencyKey
            ]
        case .getIntentionStatus:
            return nil
        }
    }

    public var encoding: ParameterEncoding {
        switch self {
        case .createIntention:
            return JSONEncoding.default
        case .getIntentionStatus:
            return URLEncoding.default
        }
    }

    public var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
