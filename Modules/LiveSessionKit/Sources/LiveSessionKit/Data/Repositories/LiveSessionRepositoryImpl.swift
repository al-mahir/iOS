//
//  LiveSessionRepositoryImpl.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation
import Combine
import UIKit
import AgoraKit
import RealtimeKit
import NetworkKit

public final class LiveSessionRepositoryImpl: LiveSessionRepositoryProtocol, @unchecked Sendable {
    private let agoraManager: AgoraSessionManaging
    private let socketDataSource: LiveSessionSocketDataSourceProtocol
    private let remoteDataSource: LiveSessionRemoteDataSourceProtocol
    private let tokenRefreshProvider: AgoraTokenRefreshProvider?

    private let participantsSubject = CurrentValueSubject<[SessionParticipant], Never>([])
    private let sessionEndedSubject = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()

    private var participantsMap: [Int: SessionParticipant] = [:]
    private let lock = NSLock()
    private var activeCircleId: String?

    public var participantsPublisher: AnyPublisher<[SessionParticipant], Never> {
        participantsSubject.eraseToAnyPublisher()
    }

    public var sessionEndedPublisher: AnyPublisher<Void, Never> {
        sessionEndedSubject.eraseToAnyPublisher()
    }

    public var connectionStatePublisher: AnyPublisher<AgoraConnectionState, Never> {
        agoraManager.connectionStatePublisher
    }

    public init(
        agoraManager: AgoraSessionManaging,
        socketDataSource: LiveSessionSocketDataSourceProtocol,
        remoteDataSource: LiveSessionRemoteDataSourceProtocol,
        tokenRefreshProvider: AgoraTokenRefreshProvider? = nil
    ) {
        self.agoraManager = agoraManager
        self.socketDataSource = socketDataSource
        self.remoteDataSource = remoteDataSource
        self.tokenRefreshProvider = tokenRefreshProvider

        setupReconnectionListener()
        setupTokenRenewal()
    }

    // MARK: - Join

    public func joinSession(
        circleId: String,
        channelName: String,
        agoraToken: String,
        uid: Int,
        userAccount: String?
    ) async throws {
        activeCircleId = circleId

        // Add local user to participant map
        lock.withLock {
            let localUser = SessionParticipant(
                uid: uid,
                name: "You",
                isHost: false, // will be updated if host
                isMediaConnected: true,
                isBackendConfirmed: true
            )
            participantsMap[uid] = localUser
            publishParticipantsLocked()
        }

        // STEP 1: Subscribe to socket topic FIRST (Decision #1 & #2)
        let topicPublisher = socketDataSource.subscribeToCircleTopic(circleId: circleId)
        
        // Setup socket event observation
        topicPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] envelope in
                self?.handleSocketEnvelope(envelope)
            }
            .store(in: &cancellables)

        // Setup Agora remote user events observation
        agoraManager.remoteUserEventsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                self?.handleAgoraRemoteUserEvent(event)
            }
            .store(in: &cancellables)

        // STEP 2: Join Agora channel AFTER socket subscription is active
        do {
            if let userAccount, !userAccount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                try await agoraManager.join(
                    channelName: channelName,
                    token: agoraToken,
                    userAccount: userAccount
                )
            } else {
                try await agoraManager.join(channelName: channelName, token: agoraToken, uid: uid)
            }
        } catch {
            throw LiveSessionError.joinFailed(reason: error.localizedDescription)
        }
    }

    // MARK: - Leave & End

    public func leaveSession(circleId: String) async throws {
        var restError: Error?
        
        // Attempt REST leave call
        do {
            _ = try await remoteDataSource.leaveSession(circleId: circleId).asyncValue()
        } catch {
            restError = error
        }

        // Cleanup regardless of REST result to avoid stuck session
        await performCleanup(circleId: circleId)

        if let restError {
            throw LiveSessionError.leaveFailed(reason: restError.localizedDescription)
        }
    }

    public func endSession(circleId: String, isHost: Bool) async throws {
        guard isHost else {
            throw LiveSessionError.notHost
        }

        var restError: Error?
        do {
            _ = try await remoteDataSource.endSession(circleId: circleId).asyncValue()
        } catch {
            restError = error
        }

        await performCleanup(circleId: circleId)

        if let restError {
            throw LiveSessionError.endFailed(reason: restError.localizedDescription)
        }
    }

    private func performCleanup(circleId: String) async {
        cancellables.removeAll()
        socketDataSource.unsubscribeFromCircleTopic(circleId: circleId)
        try? await agoraManager.leave()
        lock.withLock {
            participantsMap.removeAll()
            publishParticipantsLocked()
        }
        activeCircleId = nil
    }

    // MARK: - Participant Refresh & Reconnection Reconciliation

    public func refreshParticipants(circleId: String) async throws {
        let dtos = try await remoteDataSource.getParticipants(circleId: circleId).asyncValue()
        lock.withLock {
            let fetchedUids = Set(dtos.map { $0.uid })
            
            // Mark all existing non-fetched participants as not backend confirmed
            for (uid, participant) in participantsMap {
                if !fetchedUids.contains(uid) {
                    var updated = participant
                    updated.isBackendConfirmed = false
                    participantsMap[uid] = updated
                }
            }

            for dto in dtos {
                var existing = participantsMap[dto.uid] ?? SessionParticipant(uid: dto.uid)
                existing.name = dto.name ?? existing.name
                existing.avatarUrl = dto.avatarUrl ?? existing.avatarUrl
                existing.isHost = dto.isHost ?? existing.isHost
                existing.isMuted = dto.isMuted ?? existing.isMuted
                existing.isVideoEnabled = dto.isVideoEnabled ?? existing.isVideoEnabled
                existing.isBackendConfirmed = true
                participantsMap[dto.uid] = existing
            }

            publishParticipantsLocked()
        }
    }

    private func setupReconnectionListener() {
        socketDataSource.didReconnectPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self, let circleId = self.activeCircleId else { return }
                _ = self.socketDataSource.subscribeToCircleTopic(circleId: circleId)
                Task {
                    try? await self.refreshParticipants(circleId: circleId)
                }
            }
            .store(in: &cancellables)
    }

    private func setupTokenRenewal() {
        agoraManager.onTokenPrivilegeWillExpire = { [weak self] _ in
            guard let self, let circleId = self.activeCircleId else { return }
            Task { [weak self] in
                guard let self,
                      let token = try? await self.renewToken(circleId: circleId)
                else { return }
                self.agoraManager.renewToken(token)
            }
        }
    }

    // MARK: - Token Renewal

    public func renewToken(circleId: String) async throws -> String {
        if let tokenRefreshProvider {
            return try await tokenRefreshProvider.refreshToken()
        }
        do {
            let detail = try await remoteDataSource.getCircleDetail(circleId: circleId).asyncValue()
            guard let freshToken = detail.resolvedToken, !freshToken.isEmpty else {
                throw LiveSessionError.tokenRenewalFailed(
                    reason: "No valid Agora token present in GET /circles/\(circleId) response"
                )
            }
            return freshToken
        } catch let error as LiveSessionError {
            throw error
        } catch {
            throw LiveSessionError.tokenRenewalFailed(reason: error.localizedDescription)
        }
    }

    // MARK: - Controls & Canvas

    public func muteLocalAudio(_ muted: Bool) {
        agoraManager.muteLocalAudio(muted)
    }

    public func enableLocalVideo(_ enabled: Bool) {
        agoraManager.enableLocalVideo(enabled)
    }

    public func setupLocalVideoCanvas(_ view: UIView) -> Bool {
        agoraManager.setupLocalVideoCanvas(view)
    }

    public func setupRemoteVideoCanvas(_ view: UIView, forUid uid: Int) -> Bool {
        agoraManager.setupRemoteVideoCanvas(view, forUid: uid)
    }

    // MARK: - Private Event Handlers

    private func handleAgoraRemoteUserEvent(_ event: AgoraRemoteUserEvent) {
        lock.withLock {
            switch event {
            case .joined(let remoteUser):
                var participant = participantsMap[remoteUser.uid] ?? SessionParticipant(uid: remoteUser.uid)
                participant.isMediaConnected = true
                participant.isMuted = remoteUser.isAudioMuted
                participant.isVideoEnabled = remoteUser.videoEnabled
                participant.audioLevel = remoteUser.audioLevel
                participantsMap[remoteUser.uid] = participant

            case .left(let uid, _):
                participantsMap.removeValue(forKey: uid)

            case .mutedStateChanged(let uid, let isMuted):
                if var participant = participantsMap[uid] {
                    participant.isMuted = isMuted
                    participantsMap[uid] = participant
                }

            case .videoStateChanged(let uid, let isEnabled):
                if var participant = participantsMap[uid] {
                    participant.isVideoEnabled = isEnabled
                    participantsMap[uid] = participant
                }

            case .volumeUpdated(let uid, let level):
                if var participant = participantsMap[uid] {
                    participant.audioLevel = level
                    participantsMap[uid] = participant
                }
            }

            publishParticipantsLocked()
        }
    }

    private func handleSocketEnvelope(_ envelope: RealtimeEventEnvelope) {
        lock.withLock {
            switch envelope.eventType {
            case "PARTICIPANT_JOINED":
                if let dto = try? envelope.decodePayload(as: ParticipantSocketEventDTO.self) {
                    var participant = participantsMap[dto.uid] ?? SessionParticipant(uid: dto.uid)
                    participant.name = dto.name ?? participant.name
                    participant.avatarUrl = dto.avatarUrl ?? participant.avatarUrl
                    participant.isHost = dto.isHost ?? participant.isHost
                    participant.isBackendConfirmed = true
                    participantsMap[dto.uid] = participant
                }

            case "PARTICIPANT_LEFT":
                if let dto = try? envelope.decodePayload(as: ParticipantSocketEventDTO.self) {
                    participantsMap.removeValue(forKey: dto.uid)
                }

            case "CIRCLE_ENDED":
                sessionEndedSubject.send(())

            default:
                break
            }

            publishParticipantsLocked()
        }
    }

    private func publishParticipantsLocked() {
        let list = Array(participantsMap.values).sorted { $0.uid < $1.uid }
        participantsSubject.send(list)
    }
}

// MARK: - AnyPublisher Async Bridge Helper

private extension AnyPublisher {
    func asyncValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else if finishedWithoutValue {
                            continuation.resume(
                                throwing: NSError(domain: "CombineError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Publisher finished without emitting value"])
                            )
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        finishedWithoutValue = false
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
