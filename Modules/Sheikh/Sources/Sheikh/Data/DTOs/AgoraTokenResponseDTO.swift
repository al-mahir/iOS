//
//  AgoraTokenResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct AgoraTokenResponseDTO: Codable, Sendable {
    public let token: String
    public let channelName: String?
    public let userAccount: String?
}
