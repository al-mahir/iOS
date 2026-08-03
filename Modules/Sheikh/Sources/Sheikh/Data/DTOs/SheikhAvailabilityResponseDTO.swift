//
//  SheikhAvailabilityResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct SheikhAvailabilityResponseDTO: Codable, Sendable {
    public let sheikhId: String
    public let status: String
    public let updatedAt: String?
}
