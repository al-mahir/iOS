//
//  CircleMemberDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

struct CircleMemberDTO: Decodable {
    let id: String
    let username: String
    let status: String  // "ACTIVE" | "PENDING"
    let joinedAt: String  // ISO-8601
}
