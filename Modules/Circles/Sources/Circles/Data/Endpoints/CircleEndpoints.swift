//
//  CircleEndpoints.swift
//  Circles
//
//  Created by Nadin Ahmed on 24/07/2026.
//

import Alamofire
import Foundation
import NetworkKit

// MARK: - Request body structs (internal, Encodable)

struct CircleCreateBody: Encodable {
    let name: String
    let startDate: String  // ISO-8601
    let endDate: String  // ISO-8601
    let type: String  // "PRIVATE" always from client
    let requiresApproval: Bool
    let maxParticipants: Int
    let password: String?

    private enum CodingKeys: String, CodingKey {
        case name, startDate, endDate, type, requiresApproval, maxParticipants,
            password
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(startDate, forKey: .startDate)
        try container.encode(endDate, forKey: .endDate)
        try container.encode(type, forKey: .type)
        try container.encode(requiresApproval, forKey: .requiresApproval)
        try container.encode(maxParticipants, forKey: .maxParticipants)
        try container.encodeIfPresent(password, forKey: .password)
    }
}

struct CircleUpdateBody: Encodable {
    let name: String?
    let startDate: String?
    let endDate: String?
}

struct JoinCircleBody: Encodable {
    let password: String?
}

// MARK: - ISO-8601 encoder helper

private let iso8601Formatter: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

private func encode(_ date: Date) -> String {
    iso8601Formatter.string(from: date)
}

// MARK: - CircleEndpoints

enum CircleEndpoints: APIEndpoint {

    // Circle CRUD
    case list(status: String?, sort: String, page: Int, size: Int)
    case create(body: CircleCreateBody)
    case detail(circleId: String)
    case update(circleId: String, body: CircleUpdateBody)
    case cancel(circleId: String)

    // Lifecycle
    case start(circleId: String)
    case end(circleId: String)

    // Membership
    case join(circleId: String, body: JoinCircleBody)
    case leave(circleId: String)
    case approve(circleId: String, userId: String)
    case reject(circleId: String, userId: String)
    case removeMember(circleId: String, userId: String)

    // Lists
    case members(circleId: String, page: Int, size: Int)
    case pendingRequests(circleId: String, page: Int, size: Int)
    case mine(page: Int, size: Int)

    // Agora token
    case agoraToken(circleId: String)

    // MARK: - APIEndpoint

    var baseURL: BaseURLType { .almahir }

    var path: String {
        switch self {
        case .list:
            return "circles"
        case .create:
            return "circles"
        case .detail(let id):
            return "circles/\(id)"
        case .update(let id, _):
            return "circles/\(id)"
        case .cancel(let id):
            return "circles/\(id)"
        case .start(let id):
            return "circles/\(id)/start"
        case .end(let id):
            return "circles/\(id)/end"
        case .join(let id, _):
            return "circles/\(id)/join"
        case .leave(let id):
            return "circles/\(id)/leave"
        case .approve(let circleId, let userId):
            return "circles/\(circleId)/approve/\(userId)"
        case .reject(let circleId, let userId):
            return "circles/\(circleId)/reject/\(userId)"
        case .removeMember(let circleId, let userId):
            return "circles/\(circleId)/members/\(userId)"
        case .members(let id, _, _):
            return "circles/\(id)/members"
        case .pendingRequests(let id, _, _):
            return "circles/\(id)/pending-requests"
        case .mine:
            return "circles/mine"
        case .agoraToken(let id):
            return "circles/\(id)/token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .detail, .members, .pendingRequests, .mine, .agoraToken:
            return .get
        case .create, .join, .leave, .approve, .reject, .start, .end:
            return .post
        case .update:
            return .patch
        case .cancel, .removeMember:
            return .delete
        }
    }

    var parameters: Parameters? {
        switch self {
        case .list(let status, let sort, let page, let size):
            var params: Parameters = ["sort": sort, "page": page, "size": size]
            if let status { params["status"] = status }
            return params

        case .create(let body):
            return try? body.asDictionary()

        case .update(_, let body):
            return try? body.asDictionary()

        case .join(_, let body):
            if let pw = body.password {
                return ["password": pw]
            }
            return nil

        case .members(_, let page, let size),
            .pendingRequests(_, let page, let size):
            return ["page": page, "size": size]

        case .mine(let page, let size):
            return ["page": page, "size": size, "sort": "startDate,ASC"]

        case .detail, .cancel, .start, .end, .leave,
            .approve, .reject, .removeMember, .agoraToken:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .list, .detail, .members, .pendingRequests, .mine, .agoraToken,
            .cancel, .removeMember:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}

// MARK: - Factory helpers (used by CircleRemoteDataSource)

extension CircleEndpoints {

    static func makeList(
        params: ListCirclesParams,
        page: CirclePageRequest
    ) -> CircleEndpoints {
        .list(
            status: params.status?.rawValue,
            sort: params.sort,
            page: page.page,
            size: page.size
        )
    }

    static func makeCreate(_ params: CreateCircleParams) -> CircleEndpoints {
        .create(
            body: CircleCreateBody(
                name: params.name,
                startDate: encode(params.startDate),
                endDate: encode(params.endDate),
                type: params.type.rawValue,
                requiresApproval: params.requiresApproval,
                maxParticipants: params.maxParticipants,
                password: params.password
            )
        )
    }

    static func makeUpdate(circleId: String, params: UpdateCircleParams)
        -> CircleEndpoints
    {
        .update(
            circleId: circleId,
            body: CircleUpdateBody(
                name: params.name,
                startDate: params.startDate.map { encode($0) },
                endDate: params.endDate.map { encode($0) }
            )
        )
    }
}

// MARK: - Encodable → Parameters helper

extension Encodable {
    fileprivate func asDictionary() throws -> Parameters {
        let data = try JSONEncoder().encode(self)
        guard
            let dict = try JSONSerialization.jsonObject(with: data)
                as? [String: Any]
        else {
            throw EncodingError.invalidValue(
                self,
                .init(
                    codingPath: [],
                    debugDescription: "Cannot convert to dict"
                )
            )
        }
        return dict
    }
}
