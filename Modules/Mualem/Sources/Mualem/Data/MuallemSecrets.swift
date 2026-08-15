// MuallemSecrets.swift
// Mualem

import Foundation

public struct MuallemSecrets {
    /// Reads AI Base URL strictly from Info.plist / ProcessInfo (configured via Secrets.xcconfig)
    public static var baseURL: String {
        var path: String = ""
        if let p = Bundle.main.object(forInfoDictionaryKey: "AI_BASE_URL") as? String, !p.isEmpty {
            path = p
        } else if let env = ProcessInfo.processInfo.environment["AI_BASE_URL"], !env.isEmpty {
            path = env
        }
        
        // Fix single-slash expansion issue from xcconfig (e.g. "https:/foo" -> "https://foo")
        if path.contains(":/") && !path.contains("://") {
            path = path.replacingOccurrences(of: ":/", with: "://")
        }
        
        return path
    }
    
    /// Reads AI WebSocket URL derived strictly from baseURL
    public static var webSocketURL: URL {
        let base = baseURL
        guard !base.isEmpty else { return URL(string: "wss://invalid")! }
        let wsScheme = base.replacingOccurrences(of: "https://", with: "wss://").replacingOccurrences(of: "http://", with: "ws://")
        let fullPath = wsScheme.hasSuffix("/") ? "\(wsScheme)ws/session" : "\(wsScheme)/ws/session"
        return URL(string: fullPath) ?? URL(string: "wss://invalid")!
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
