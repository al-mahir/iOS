//
//  InstantMeetingRealtimeEventDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public enum InstantMeetingRealtimeEventDTO: Sendable, Equatable {
    case accepted(AcceptResponseDTO)
    case declined(reason: String?)
    case cancelled(requestId: String)
    case expired(requestId: String)
    case ended(requestId: String)
}
