//
//  InstantMeetingStatus.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public enum InstantMeetingStatus: Sendable, Equatable {
    case pending
    case accepted(channelName: String, agoraToken: String, userAccount: String?)
    case declined(reason: String?)
    case cancelled
    case expired
    case ended
}
