//
//  NetworkService.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 17/07/2026.
//
import Foundation
import Alamofire
import Combine

@available(iOS 13.0, *)
public final class NetworkService: NetworkServiceProtocol, @unchecked Sendable {
    
    public static let shared = NetworkService()
    private let session: Session
    
    public init(session: Session = NetworkService.buildDefaultSession()) {
        self.session = session
    }
    
    public static func buildDefaultSession(
        interceptor: RequestInterceptor? = nil
    ) -> Session {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        
        return Session(configuration: config, interceptor: interceptor)
    }
    
    public func request<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: endpoint.fullURL) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        let dataRequest = session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers
        )
        
        return
        dataRequest
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { [weak self] response -> T in
                guard let self else {
                    throw NetworkError.unknown(message: "Service deallocated")
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(
                            APISuccessResponse<T>.self,
                            from: data
                        )
                        return decoded.data
                    } catch {
                        throw NetworkError.decodingFailed
                    }
                case .failure(let error):
                    throw self.mapError(
                        error,
                        data: response.data,
                        statusCode: response.response?.statusCode
                    )
                }
            }
            .mapError { error in
                (error as? NetworkError)
                ?? .unknown(message: error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    public func requestWithoutData(_ endpoint: APIEndpoint) -> AnyPublisher<Bool, NetworkError> {
        guard let url = URL(string: endpoint.fullURL) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }
        
        let dataRequest = session.request(
            url,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers
        )
        
        return
        dataRequest
            .validate(statusCode: 200..<300)
            .publishData()
            .tryMap { [weak self] response -> Bool in
                guard let self else {
                    throw NetworkError.unknown(message: "Service deallocated")
                }
                
                switch response.result {
                case .success:
                    return true
                case .failure(let afError):
                    throw self.mapError(
                        afError,
                        data: response.data,
                        statusCode: response.response?.statusCode
                    )
                }
            }
            .mapError { error in
                (error as? NetworkError)
                ?? .unknown(message: error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    
    private func mapError(_ error: AFError, data: Data?, statusCode: Int?) -> NetworkError{
        
        if let data,
           let apiError = try? JSONDecoder().decode(
            APIErrorResponse.self,
            from: data
           )
        {
            if let fieldErrors = apiError.fieldErrors, !fieldErrors.isEmpty {
                return .validationFailed(
                    message: apiError.message,
                    fieldErrors: fieldErrors
                )
            }
            switch statusCode {
            case 401:
                return .unauthorized(message: apiError.message)
            case 404:
                return .notFound(message: apiError.message)
            default:
                return .serverError(
                    statusCode: statusCode ?? -1,
                    message: apiError.message
                )
            }
        }
        
        if let urlError = error.underlyingError as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .noInternetConnection
            case .timedOut:
                return .timeout
            case .cancelled:
                return .cancelled
            default:
                return .unknown(message: urlError.localizedDescription)
            }
        }
        
        if error.isResponseSerializationError {
            return .decodingFailed
        }
        
        return .unknown(message: error.localizedDescription)
    }
    
    public func requestExternal<T: Decodable>(_ endpoint: APIEndpoint) -> AnyPublisher<T, NetworkError> {
        return AF.request(
            endpoint.fullURL,
            method: endpoint.method,
            parameters: endpoint.parameters,
            encoding: endpoint.encoding,
            headers: endpoint.headers,
            interceptor: AppRequestInterceptors.shared
        )
        .validate()
        .publishDecodable(type: T.self)
        .value()
        .mapError { error in
           
            if let afError = error as? AFError {
                if case .responseSerializationFailed = afError {
                    return .decodingFailed
                }
                return .unknown(message: afError.localizedDescription)
            }
            return .unknown(message: error.localizedDescription)
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
