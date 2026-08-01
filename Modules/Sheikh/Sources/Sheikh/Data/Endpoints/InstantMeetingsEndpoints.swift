//
//  InstantMeetingsEndpoints.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation
import Alamofire
import NetworkKit

public enum InstantMeetingsEndpoints: APIEndpoint {
    case createRequest(sheikhId: String)
    case cancelRequest(requestId: String)
    case getAvailability(sheikhId: String)
    case getStudentHistory(page: Int, size: Int)
    case getToken(requestId: String)

    public var baseURL: BaseURLType {
        .main
    }

    public var path: String {
        switch self {
        case .createRequest(let sheikhId):
            return "api/instant-meetings/sheikh/\(sheikhId)/request"
        case .cancelRequest(let requestId):
            return "api/instant-meetings/\(requestId)/cancel"
        case .getAvailability(let sheikhId):
            return "api/instant-meetings/sheikh/\(sheikhId)/availability"
        case .getStudentHistory:
            return "api/instant-meetings/student/history"
        case .getToken(let requestId):
            return "api/instant-meetings/\(requestId)/token"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .createRequest, .cancelRequest:
            return .post
        case .getAvailability, .getStudentHistory, .getToken:
            return .get
        }
    }

    public var parameters: Parameters? {
        switch self {
        case .getStudentHistory(let page, let size):
            return ["page": page, "size": size]
        case .createRequest, .cancelRequest, .getAvailability, .getToken:
            return nil
        }
    }

    public var encoding: ParameterEncoding {
        URLEncoding.default
    }

    public var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
