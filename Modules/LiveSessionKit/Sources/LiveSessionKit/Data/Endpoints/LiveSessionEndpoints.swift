//
//  LiveSessionEndpoints.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Alamofire
import NetworkKit

public enum LiveSessionEndpoints: APIEndpoint {
    case leave(circleId: String)
    case end(circleId: String)
    case getParticipants(circleId: String)
    case getCircleDetail(circleId: String)

    public var baseURL: BaseURLType {
        .main
    }

    public var path: String {
        switch self {
        case .leave(let circleId):
            return "api/v1/circles/\(circleId)/leave"
        case .end(let circleId):
            return "api/v1/circles/\(circleId)/end"
        case .getParticipants(let circleId):
            return "api/v1/circles/\(circleId)/participants"
        case .getCircleDetail(let circleId):
            return "api/v1/circles/\(circleId)"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .leave, .end:
            return .post
        case .getParticipants, .getCircleDetail:
            return .get
        }
    }

    public var parameters: Parameters? {
        nil
    }

    public var encoding: ParameterEncoding {
        URLEncoding.default
    }

    public var headers: HTTPHeaders? {
        ["Accept": "application/json"]
    }
}
