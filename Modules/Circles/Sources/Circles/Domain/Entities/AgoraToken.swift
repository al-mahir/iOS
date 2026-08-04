//
//  AgoraToken.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public struct AgoraToken: Equatable, Hashable, Sendable {

    public let token: String
    public let uid: Int
    public let channelName: String

    public init(token: String, uid: Int, channelName: String) {
        self.token = token
        self.uid = uid
        self.channelName = channelName
    }
}
