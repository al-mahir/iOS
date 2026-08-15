//
//  BaseURLType.swift
//  NetworkKit
//
//  Created by Nadin Ahmed on 16/07/2026.
//
import Foundation

public enum BaseURLType {
    case main
    case ai
    case quranCom
    case almahir
    case socketUrl

    public var urlString: String {
        switch self {
        case .main:
            return "https://almahir-production.up.railway.app/api/"
        case .ai:
            return ""
        case .quranCom:
            return "https://api.quran.com/api/v4/"
        case .almahir:
            return "https://almahir-production.up.railway.app/api/"
        case .socketUrl:
            return "wss://almahir-production.up.railway.app/ws/websocket"
        }
    }
}

