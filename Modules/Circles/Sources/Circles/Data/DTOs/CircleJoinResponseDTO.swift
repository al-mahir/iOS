//
//  CircleJoinResponseDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

struct CircleJoinResponseDTO: Decodable {
    let membershipId: String
    let circleId: String
    let userId: String
    let status: String  // "ACTIVE" | "PENDING"
    let requestedAt: String  // ISO-8601
}
