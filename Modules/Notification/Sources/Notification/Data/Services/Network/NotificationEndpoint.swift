//
//  NotificationEndpoint.swift
//  Notification
//
//  Created by Basmala Abuzied Ahmed on 29/07/2026.
//

import Foundation
import Alamofire
import NetworkKit

enum NotificationEndpoint: APIEndpoint {
    case list(userId: String)
    case create(Notification)
    case markAsRead(id: String)
    case markAllAsRead(userId: String)
    case delete(id: String)

    var baseURL: BaseURLType { .almahir }

    var path: String {
        switch self {
        case .list, .create:
            return "notifications"
        case .markAsRead(let id):
            return "notifications/\(id)/read"
        case .markAllAsRead:
            return "notifications/read-all"
        case .delete(let id):
            return "notifications/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list:
            return .get
        case .create:
            return .post
        case .markAsRead, .markAllAsRead:
            return .patch
        case .delete:
            return .delete
        }
    }

    var parameters: Parameters? {
        switch self {
        case .list(let userId):
            return ["userId": userId]
        case .markAllAsRead(let userId):
            return ["userId": userId]
        case .create(let notification):
            var body: Parameters = [
                "userId": notification.userId,
                "title": notification.title,
                "body": notification.body,
                "type": notification.type.rawValue
            ]
            if let actionURL = notification.actionURL {
                body["actionURL"] = actionURL
            }
            return body
        case .markAsRead, .delete:
            return nil
        }
    }

    var encoding: ParameterEncoding {
        switch method {
        case .get, .delete:
            return URLEncoding.default
        default:
            return JSONEncoding.default
        }
    }
}
