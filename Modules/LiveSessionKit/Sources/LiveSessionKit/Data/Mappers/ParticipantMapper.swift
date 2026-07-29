//
//  ParticipantMapper.swift
//  LiveSessionKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public enum ParticipantMapper {
    public static func map(_ dto: ParticipantDTO) -> SessionParticipant {
        SessionParticipant(
            uid: dto.uid,
            name: dto.name,
            avatarUrl: dto.avatarUrl,
            isHost: dto.isHost ?? false,
            isMuted: dto.isMuted ?? false,
            isVideoEnabled: dto.isVideoEnabled ?? false,
            audioLevel: 0,
            isMediaConnected: false,
            isBackendConfirmed: true
        )
    }

    public static func map(_ event: ParticipantSocketEventDTO) -> SessionParticipant {
        SessionParticipant(
            uid: event.uid,
            name: event.name,
            avatarUrl: event.avatarUrl,
            isHost: event.isHost ?? false,
            isMuted: false,
            isVideoEnabled: false,
            audioLevel: 0,
            isMediaConnected: false,
            isBackendConfirmed: true
        )
    }
}
