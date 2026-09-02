//
//  AgoraSessionError.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation

public enum AgoraSessionError: Error, Equatable {
    /// Failed to initialize the underlying Agora RTC engine.
    case engineInitializationFailed

    /// Joining the specified channel failed with an underlying error.
    case joinFailed(message: String)

    /// Operation requested while not joined in an active channel.
    case notJoined

    /// The Agora RTC token has expired or is invalid.
    case tokenExpired

    /// Invalid configuration provided to the Agora session.
    case invalidConfiguration(reason: String)

    /// Underlying SDK error code returned by Agora RTC Engine.
    case sdkError(code: Int)

    /// Agora App ID is missing or empty in the app's Info.plist.
    case missingAppID

    /// Microphone permission was denied or restricted at the OS level.
    case microphonePermissionDenied(status: AgoraMediaPermissionStatus)

    /// Camera permission was denied or restricted at the OS level.
    case cameraPermissionDenied(status: AgoraMediaPermissionStatus)

    public static func == (lhs: AgoraSessionError, rhs: AgoraSessionError) -> Bool {
        switch (lhs, rhs) {
        case (.engineInitializationFailed, .engineInitializationFailed):
            return true
        case (.joinFailed(let msg1), .joinFailed(let msg2)):
            return msg1 == msg2
        case (.notJoined, .notJoined):
            return true
        case (.tokenExpired, .tokenExpired):
            return true
        case (.invalidConfiguration(let r1), .invalidConfiguration(let r2)):
            return r1 == r2
        case (.sdkError(let c1), .sdkError(let c2)):
            return c1 == c2
        case (.missingAppID, .missingAppID):
            return true
        case (.microphonePermissionDenied(let s1), .microphonePermissionDenied(let s2)):
            return s1 == s2
        case (.cameraPermissionDenied(let s1), .cameraPermissionDenied(let s2)):
            return s1 == s2
        default:
            return false
        }
    }
}
