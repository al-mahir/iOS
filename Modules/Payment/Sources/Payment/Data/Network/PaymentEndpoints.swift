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
        amount: Double,
        currency: String,
        paymentMethod: String,
        phone: String?,
        packageTitle: String?
    )
    case getIntentionStatus(id: String)

    public var baseURL: BaseURLType {
        .main
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
        case .createIntention(let amount, let currency, let method, let phone, let packageTitle):
            let amountCents = Int((amount * 100).rounded())
            var params: [String: Any] = [
                "amount": amount,
                "amountCents": amountCents,
                "currency": currency,
                "paymentMethod": method,
                "payment_methods": [method]
            ]
            if let phone = phone, !phone.isEmpty {
                params["phoneNumber"] = phone
                params["phone"] = phone
                params["billing_data"] = [
                    "first_name": "Al-Mahir",
                    "last_name": "User",
                    "email": "user@almahir.app",
                    "phone_number": phone
                ]
            }
            if let packageTitle = packageTitle, !packageTitle.isEmpty {
                params["packageTitle"] = packageTitle
                params["special_reference"] = packageTitle
            }
            return params
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
