//
//  PendingJoinRequestDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

struct PendingJoinRequestDTO: Decodable {
    let userId: String
    let username: String
    let requestedAt: String  // ISO-8601
}
