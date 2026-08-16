//
//  LiveSessionRepositoryProtocol.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine
import UIKit
import AgoraKit

public protocol LiveSessionRepositoryProtocol: AnyObject, Sendable {
    var participantsPublisher: AnyPublisher<[SessionParticipant], Never> { get }
    var sessionEndedPublisher: AnyPublisher<Void, Never> { get }
    var connectionStatePublisher: AnyPublisher<AgoraConnectionState, Never> { get }

    func joinSession(
        circleId: String,
        channelName: String,
        agoraToken: String,
        uid: Int,
        userAccount: String?
    ) async throws
    func leaveSession(circleId: String) async throws
    func endSession(circleId: String, isHost: Bool) async throws
    func refreshParticipants(circleId: String) async throws
    func renewToken(circleId: String) async throws -> String

    func muteLocalAudio(_ muted: Bool)
    func enableLocalVideo(_ enabled: Bool)
    func setupLocalVideoCanvas(_ view: UIView) -> Bool
    func setupRemoteVideoCanvas(_ view: UIView, forUid uid: Int) -> Bool
}

public extension LiveSessionRepositoryProtocol {
    func joinSession(
        circleId: String,
        channelName: String,
        agoraToken: String,
        uid: Int
    ) async throws {
        try await joinSession(
            circleId: circleId,
            channelName: channelName,
            agoraToken: agoraToken,
            uid: uid,
            userAccount: nil
        )
    }
}
