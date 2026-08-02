//
//  AgoraMediaPermissionResult.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public enum AgoraMediaPermissionStatus: String, Sendable, Equatable {

    case authorized

    case denied

    case restricted

    case notDetermined

    public var isGranted: Bool {
        self == .authorized
    }
}

public struct AgoraMediaPermissionResult: Sendable, Equatable {

    public let microphoneStatus: AgoraMediaPermissionStatus

    public let cameraStatus: AgoraMediaPermissionStatus?

    public var isMicrophoneGranted: Bool {
        microphoneStatus.isGranted
    }

    public var isCameraGranted: Bool {
        cameraStatus?.isGranted ?? false
    }

    public init(
        microphoneStatus: AgoraMediaPermissionStatus,
        cameraStatus: AgoraMediaPermissionStatus? = nil
    ) {
        self.microphoneStatus = microphoneStatus
        self.cameraStatus = cameraStatus
    }
}
