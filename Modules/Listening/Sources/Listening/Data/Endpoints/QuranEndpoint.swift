//
//  QuranEndpoint.swift
//  Listening
//

import Foundation
import NetworkKit
import Alamofire

// MARK: - Quran.com API Endpoints

enum QuranEndpoint: APIEndpoint {

    /// Fetch the list of all available reciters
    case reciters

    /// Fetch the audio file metadata for a specific reciter + chapter
    case chapterAudio(reciterId: Int, chapterNumber: Int)

    /// Fetch per-word timestamps for a specific reciter + chapter
    case wordTimings(reciterId: Int, chapterNumber: Int)

    // MARK: APIEndpoint conformance

    var baseURL: BaseURLType { .quranCom }

    var path: String {
        switch self {
        case .reciters:
            return "resources/recitations"
        case .chapterAudio(let reciterId, let chapterNumber):
            return "chapter_recitations/\(reciterId)/\(chapterNumber)"
        case .wordTimings(let reciterId, let chapterNumber):
            return "recitations/\(reciterId)/by_chapter/\(chapterNumber)"
        }
    }

    var method: HTTPMethod { .get }

    var parameters: Parameters? {
        switch self {
        case .chapterAudio, .wordTimings:
            // segments=true returns per-word timestamps alongside the chapter audio URL
            return ["segments": "true"]
        default:
            return nil
        }
    }

    var encoding: ParameterEncoding { URLEncoding.default }

    var headers: HTTPHeaders? {
        return HTTPHeaders([
            HTTPHeader(name: "Accept", value: "application/json")
        ])
    }
}
