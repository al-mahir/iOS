//
//  AgoraTokenDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

struct AgoraTokenDTO: Decodable {
    let token: String
    let uid: Int?
    let channelName: String
    let userAccount: String?
}
