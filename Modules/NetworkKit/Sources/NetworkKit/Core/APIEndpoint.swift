//
//  APIEndpoint.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation
import Alamofire

public protocol APIEndpoint {
    var baseURL: BaseURLType { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: Parameters? { get }
    var encoding: ParameterEncoding { get }
    var headers: HTTPHeaders? { get }
    var multipartBody: MultipartBody? { get }
}

extension APIEndpoint {
    var fullURL: String {
        baseURL.urlString + path
    }

    public var headers: HTTPHeaders? { nil }
    
    public var multipartBody: MultipartBody? { nil }
}
