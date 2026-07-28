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

    public init(appId: String, channelProfile: AgoraChannelProfile = .communication) {
        self.appId = appId
        self.channelProfile = channelProfile
    }
}


public final class AgoraSession: AgoraSessionManaging {

    private let configuration: AgoraSessionConfiguration
    private let delegateProxy: AgoraEngineDelegateProxy
    private var agoraEngine: AgoraRtcEngineKit?


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


    public init(configuration: AgoraSessionConfiguration) {
        self.configuration = configuration
        self.delegateProxy = AgoraEngineDelegateProxy()
    }

    public convenience init(appId: String) {
        self.init(configuration: AgoraSessionConfiguration(appId: appId))
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

        guard !configuration.appId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AgoraSessionError.invalidConfiguration(reason: "Agora App ID cannot be empty.")
        }

        let engineConfig = AgoraRtcEngineConfig()
        engineConfig.appId = configuration.appId
        engineConfig.channelProfile = configuration.channelProfile

        let engine = AgoraRtcEngineKit.sharedEngine(with: engineConfig, delegate: delegateProxy)

        engine.enableAudio()
        engine.setAudioProfile(.default)
        self.agoraEngine = engine
        return engine
    }

    // MARK: - AgoraSessionManaging Methods

    public func join(channelName: String, token: String, uid: Int) async throws {
        guard !channelName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AgoraSessionError.invalidConfiguration(reason: "Channel name cannot be empty.")
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
