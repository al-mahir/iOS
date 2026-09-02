//
//  AcceptResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct AcceptResponseDTO: Codable, Sendable, Equatable {
    public let status: String
    public let requestId: String
    public let channelName: String
    public let agoraToken: String
    public let userAccount: String?
}
