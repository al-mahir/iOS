//
//  NetworkServiceProtocol.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation
import Combine

@available(iOS 13.0, *)
public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError>
    
    func requestWithoutData(_ endpoint: APIEndpoint) -> AnyPublisher<Bool, NetworkError>
}
