//
//  SheikhEndpoints.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation
import NetworkKit
import Alamofire

enum SheikhEndpoints: APIEndpoint {

    case getAllSheikhs

    case getSheikhByID(id: String)

    case searchSheikhs(name: String?)

    // MARK: - APIEndpoint

    var baseURL: BaseURLType { .main }

    var path: String {
        switch self {
        case .getAllSheikhs:
            return "api/sheikh"
        case .getSheikhByID(let id):
            return "api/sheikh/\(id)"
        case .searchSheikhs:
            return "api/sheikh/search"
        }
    }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {
        case .searchSheikhs(let name):
            return ["name": name ?? ""]
        case .getAllSheikhs, .getSheikhByID:
            return nil
        }
    }

    var encoding: ParameterEncoding { URLEncoding.default }
}
