//
//  TafsirEndpoint.swift
//  Tafsir
//
//  Created by Basmala Abuzied Ahmed on 26/7/2026.
//


import Foundation
import Alamofire
import NetworkKit

enum TafsirEndpoint: APIEndpoint {
    case available
    case ayah(surah: Int, ayah: Int, lang: String, tafsirKey: String)

    var baseURL: BaseURLType { .almahir }

    var path: String {
        switch self {
        case .available:
            return "tafsir/available"
        case .ayah:
            return "tafsir"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var parameters: Parameters? {
        switch self {
        case .available:
            return nil
        case .ayah(let surah, let ayah, let lang, let tafsirKey):
            return [
                "surah": surah,
                "ayah": ayah,
                "lang": lang,
                "tafsir": tafsirKey
            ]
        }
    }

    var encoding: ParameterEncoding {
        URLEncoding.default
    }
}
