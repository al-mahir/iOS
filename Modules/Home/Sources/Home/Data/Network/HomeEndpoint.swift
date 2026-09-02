//
//  HomeEndpoint.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//


import Alamofire
import NetworkKit

enum HomeEndpoint: APIEndpoint {
    case randomAyah

    var baseURL: BaseURLType {
        return .quranCom
    }

    var path: String {
        return "verses/random"
    }

    var method: HTTPMethod {
        return .get
    }

    var parameters: Parameters? {
        return [
            "language": "en",
            "translations": "131",
            "fields": "text_uthmani"
        ]
    }

    var encoding: ParameterEncoding {
        return URLEncoding.queryString
    }

    var headers: HTTPHeaders? {
        return nil
    }
}
