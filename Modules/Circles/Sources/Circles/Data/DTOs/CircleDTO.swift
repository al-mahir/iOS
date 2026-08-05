//
//  CircleDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

struct CircleDTO: Decodable {
    let circleId: String
    let name: String
    let startDate: String  // ISO-8601
    let endDate: String  // ISO-8601
    let status: String  // "SCHEDULED" | "ONGOING" | "COMPLETED" | "CANCELLED"
    let type: String  // "PUBLIC" | "PRIVATE"
    let requiresApproval: Bool
    let maxParticipants: Int
    let channelName: String
    let ownerId: String
    let memberCount: Int

    private enum CodingKeys: String, CodingKey {
        case circleId
        case name = "title"
        case startDate
        case endDate
        case status
        case type
        case requiresApproval
        case maxParticipants
        case channelName
        case ownerId
        case memberCount
    }
}
