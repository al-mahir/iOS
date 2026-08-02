//
//  StudentMeetingHistoryResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct StudentMeetingHistoryResponseDTO: Codable, Sendable {
    public let requestId: String
    public let sheikhId: String
    public let sheikhName: String
    public let status: String
    public let requestedAt: String?
    public let acceptedAt: String?
    public let endedAt: String?
}
