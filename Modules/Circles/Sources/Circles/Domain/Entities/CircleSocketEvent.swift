//
//  CircleSocketEvent.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public enum CircleSocketEvent: Sendable, Equatable {

    // MARK: - Topic 1 — Owner's live pending-requests feed

    case joinRequestReceived(PendingJoinRequest)
    case joinRequestRemoved(membershipId: String)

    // MARK: - Topic 2 — Requesting member's own request status

    case requestApproved(CircleMember)
    case requestRejected(reason: String)

    // MARK: - Topic 3 — Circle-wide roster / lifecycle sync

    case memberJoined(CircleMember)
    case memberLeft(userId: String)
    case memberRemoved(userId: String)
    case circleStarted(circleId: String)
    case circleEnded(circleId: String)
    case circleCancelled(circleId: String)
}
