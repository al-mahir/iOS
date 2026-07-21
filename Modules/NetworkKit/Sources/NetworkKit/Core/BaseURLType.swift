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
     
    public var urlString: String {
        switch self {
        case .main:
            return "https://virtserver.swaggerhub.com/iti-ff4/AuthN-AuthZ-API/1.4.0/"
        case .ai:
            return ""
        case .quranCom:
            return "https://api.quran.com/api/v4/"
                }
        
    }
}
