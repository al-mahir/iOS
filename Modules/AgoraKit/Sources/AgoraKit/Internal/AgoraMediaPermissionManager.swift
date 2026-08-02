//
//  AgoraMediaPermissionManager.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import AVFoundation

public protocol AVCaptureDeviceProviding: Sendable {
    func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus
    func requestAccess(for mediaType: AVMediaType) async -> Bool
}

public struct SystemAVCaptureDeviceProvider: AVCaptureDeviceProviding {
    public init() {}

    public func authorizationStatus(for mediaType: AVMediaType) -> AVAuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: mediaType)
    }

    public func requestAccess(for mediaType: AVMediaType) async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}

public struct AgoraMediaPermissionManager: Sendable {
    private let captureDeviceProvider: AVCaptureDeviceProviding

    public init(captureDeviceProvider: AVCaptureDeviceProviding = SystemAVCaptureDeviceProvider()) {
        self.captureDeviceProvider = captureDeviceProvider
    }

    public func requestPermissions(includeVideo: Bool) async -> AgoraMediaPermissionResult {
        let micStatus = await resolvePermission(for: .audio)
        let cameraStatus: AgoraMediaPermissionStatus? = includeVideo ? await resolvePermission(for: .video) : nil

        return AgoraMediaPermissionResult(
            microphoneStatus: micStatus,
            cameraStatus: cameraStatus
        )
    }

    private func resolvePermission(for mediaType: AVMediaType) async -> AgoraMediaPermissionStatus {
        let currentStatus = captureDeviceProvider.authorizationStatus(for: mediaType)
        switch currentStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            _ = await captureDeviceProvider.requestAccess(for: mediaType)
            let updatedStatus = captureDeviceProvider.authorizationStatus(for: mediaType)
            return mapStatus(updatedStatus)
        @unknown default:
            return .denied
        }
    }

    private func mapStatus(_ status: AVAuthorizationStatus) -> AgoraMediaPermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .denied
        }
    }
}
