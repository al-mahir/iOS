//
//  AgoraSession.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 28/07/2026.
//

import Foundation
import Combine
import UIKit
import AgoraRtcKit


public struct AgoraSessionConfiguration: Sendable {

    public let appId: String

    public let channelProfile: AgoraChannelProfile

    public init(appId: String = "", channelProfile: AgoraChannelProfile = .communication) {
        self.appId = appId
        self.channelProfile = channelProfile
    }
}


public final class AgoraSession: AgoraSessionManaging {

    private let configuration: AgoraSessionConfiguration
    private let delegateProxy: AgoraEngineDelegateProxy
    private var agoraEngine: AgoraRtcEngineKit?
    private let appIdProvider: AgoraAppIDProviding
    private let permissionManager: AgoraMediaPermissionManager


    public var currentConnectionState: AgoraConnectionState {
        delegateProxy.connectionStateSubject.value
    }

    public var connectionStatePublisher: AnyPublisher<AgoraConnectionState, Never> {
        delegateProxy.connectionStateSubject.eraseToAnyPublisher()
    }

    public var remoteUserEventsPublisher: AnyPublisher<AgoraRemoteUserEvent, Never> {
        delegateProxy.remoteUserEventSubject.eraseToAnyPublisher()
    }

    public var onTokenPrivilegeWillExpire: ((String) -> Void)? {
        get { delegateProxy.onTokenPrivilegeWillExpire }
        set { delegateProxy.onTokenPrivilegeWillExpire = newValue }
    }


    public init(
        configuration: AgoraSessionConfiguration = AgoraSessionConfiguration(),
        appIdProvider: AgoraAppIDProviding = AgoraAppIDProvider(),
        permissionManager: AgoraMediaPermissionManager = AgoraMediaPermissionManager()
    ) {
        self.configuration = configuration
        self.appIdProvider = appIdProvider
        self.permissionManager = permissionManager
        self.delegateProxy = AgoraEngineDelegateProxy()
    }

    public convenience init(
        appId: String,
        permissionManager: AgoraMediaPermissionManager = AgoraMediaPermissionManager()
    ) {
        self.init(
            configuration: AgoraSessionConfiguration(appId: appId),
            appIdProvider: AgoraAppIDProvider(),
            permissionManager: permissionManager
        )
    }

    deinit {
        agoraEngine?.leaveChannel(nil)
        agoraEngine = nil
    }

    // MARK: - Engine Setup

    private func getOrInitializeEngine() throws -> AgoraRtcEngineKit {
        if let existing = agoraEngine {
            return existing
        }

        let resolvedAppId: String
        let trimmedConfigId = configuration.appId.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedConfigId.isEmpty {
            resolvedAppId = trimmedConfigId
        } else {
            resolvedAppId = try appIdProvider.fetchAppID()
        }

        let engineConfig = AgoraRtcEngineConfig()
        engineConfig.appId = resolvedAppId
        engineConfig.channelProfile = configuration.channelProfile

        let engine = AgoraRtcEngineKit.sharedEngine(with: engineConfig, delegate: delegateProxy)

        engine.enableAudio()
        engine.setAudioProfile(.default)
        self.agoraEngine = engine
        return engine
    }

    // MARK: - Media Permissions

    public func requestMediaPermissions(includeVideo: Bool = false) async -> AgoraMediaPermissionResult {
        await permissionManager.requestPermissions(includeVideo: includeVideo)
    }

    // MARK: - AgoraSessionManaging Methods

    public func join(channelName: String, token: String, uid: Int) async throws {
        try await join(channelName: channelName, token: token, uid: uid, includeVideo: false)
    }

    public func join(
        channelName: String,
        token: String,
        uid: Int,
        includeVideo: Bool
    ) async throws {
        guard !channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AgoraSessionError.invalidConfiguration(reason: "Channel name cannot be empty.")
        }

        let permissionResult = await requestMediaPermissions(includeVideo: includeVideo)
        guard permissionResult.isMicrophoneGranted else {
            let error = AgoraSessionError.microphonePermissionDenied(status: permissionResult.microphoneStatus)
            delegateProxy.connectionStateSubject.send(.failed(error))
            throw error
        }

        if includeVideo, let cameraStatus = permissionResult.cameraStatus, !cameraStatus.isGranted {
            let error = AgoraSessionError.cameraPermissionDenied(status: cameraStatus)
            delegateProxy.connectionStateSubject.send(.failed(error))
            throw error
        }

        let engine = try getOrInitializeEngine()

        let options = AgoraRtcChannelMediaOptions()
        options.clientRoleType = .broadcaster
        options.channelProfile = configuration.channelProfile

        delegateProxy.connectionStateSubject.send(.connecting)

        let result = engine.joinChannel(
            byToken: token.isEmpty ? nil : token,
            channelId: channelName,
            uid: UInt(uid),
            mediaOptions: options
        )

        if result != 0 {
            let error = AgoraSessionError.sdkError(code: Int(result))
            delegateProxy.connectionStateSubject.send(.failed(error))
            throw error
        }
    }

    public func join(
        channelName: String,
        token: String,
        userAccount: String
    ) async throws {
        guard !channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AgoraSessionError.invalidConfiguration(reason: "Channel name cannot be empty.")
        }
        guard !userAccount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AgoraSessionError.invalidConfiguration(reason: "User account cannot be empty.")
        }

        let permissionResult = await requestMediaPermissions(includeVideo: false)
        guard permissionResult.isMicrophoneGranted else {
            let error = AgoraSessionError.microphonePermissionDenied(
                status: permissionResult.microphoneStatus
            )
            delegateProxy.connectionStateSubject.send(.failed(error))
            throw error
        }

        let engine = try getOrInitializeEngine()
        let options = AgoraRtcChannelMediaOptions()
        options.clientRoleType = .broadcaster
        options.channelProfile = configuration.channelProfile

        delegateProxy.connectionStateSubject.send(.connecting)

        let result = engine.joinChannel(
            byToken: token.isEmpty ? nil : token,
            channelId: channelName,
            userAccount: userAccount,
            mediaOptions: options,
            joinSuccess: nil
        )

        if result != 0 {
            let error = AgoraSessionError.sdkError(code: Int(result))
            delegateProxy.connectionStateSubject.send(.failed(error))
            throw error
        }
    }

    public func leave() async throws {
        guard let engine = agoraEngine else { return }
        engine.stopPreview()
        let result = engine.leaveChannel(nil)
        if result == 0 {
            delegateProxy.connectionStateSubject.send(.disconnected)
        } else {
            throw AgoraSessionError.sdkError(code: Int(result))
        }
    }

    public func renewToken(_ token: String) {
        agoraEngine?.renewToken(token)
    }

    public func muteLocalAudio(_ muted: Bool) {
        agoraEngine?.muteLocalAudioStream(muted)
    }

    public func enableLocalVideo(_ enabled: Bool) {
        if enabled {
            agoraEngine?.enableVideo()
            agoraEngine?.enableLocalVideo(true)
        } else {
            agoraEngine?.enableLocalVideo(false)
        }
    }

    @discardableResult
    public func setupLocalVideoCanvas(_ view: UIView) -> Bool {
        guard let engine = agoraEngine else { return false }
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = 0
        canvas.view = view
        canvas.renderMode = .hidden
        let result = engine.setupLocalVideo(canvas)
        if result == 0 {
            engine.startPreview()
            return true
        }
        return false
    }

    @discardableResult
    public func setupRemoteVideoCanvas(_ view: UIView, forUid uid: Int) -> Bool {
        guard let engine = agoraEngine else { return false }
        let canvas = AgoraRtcVideoCanvas()
        canvas.uid = UInt(uid)
        canvas.view = view
        canvas.renderMode = .hidden
        return engine.setupRemoteVideo(canvas) == 0
    }
}
