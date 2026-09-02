//
//  TafsirEndpoint.swift
//  Search
//
//  Created by Alaa Ayman on 10/02/1448 AH.
//
//
//  TafsirEndpoint.swift
//  Search
//

import Foundation
import Alamofire
import NetworkKit

enum TafsirEndpoint: APIEndpoint {
    case tafsir(surah: Int, ayah: Int, lang: String, tafsirSource: String)

    var baseURL: BaseURLType { .almahir }

    var path: String { "tafsir" }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {
        case .tafsir(let surah, let ayah, let lang, let tafsirSource):
            return [
                "surah": surah,
                "ayah": ayah,
                "lang": lang,
                "tafsir": tafsirSource
            ]
        }
    }

    var encoding: ParameterEncoding { URLEncoding.queryString }

    var headers: HTTPHeaders? { nil }
}
