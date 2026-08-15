// MuallemSecrets.swift
// Mualem

import Foundation

public struct MuallemSecrets {
    /// Reads AI Base URL strictly from Info.plist / ProcessInfo (configured via Secrets.xcconfig)
    public static var baseURL: String {
        if let path = Bundle.main.object(forInfoDictionaryKey: "AI_BASE_URL") as? String, !path.isEmpty {
            return path
        }
        if let env = ProcessInfo.processInfo.environment["AI_BASE_URL"], !env.isEmpty {
            return env
        }
        return ""
    }
    
    /// Reads AI WebSocket URL derived strictly from baseURL
    public static var webSocketURL: URL {
        let base = baseURL
        let wsScheme = base.replacingOccurrences(of: "https://", with: "wss://").replacingOccurrences(of: "http://", with: "ws://")
        return URL(string: "\(wsScheme)/ws/session") ?? URL(string: "wss://invalid")!
    }
    
    /// Reads AI Bearer Token strictly from Info.plist / ProcessInfo (configured via Secrets.xcconfig)
    public static var bearerToken: String {
        if let token = Bundle.main.object(forInfoDictionaryKey: "AI_BEARER_TOKEN") as? String, !token.isEmpty {
            return token
        }
        if let env = ProcessInfo.processInfo.environment["AI_BEARER_TOKEN"], !env.isEmpty {
            return env
        }
        return ""
    }
}
