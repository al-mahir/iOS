//
//  MeetingRequestResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct MeetingRequestResponseDTO: Codable, Sendable {
    public let requestId: String
    public let status: String
    public let channelName: String?
    public let expiresAt: String?
}
