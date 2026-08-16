//
//  PrivetCodeResult.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

import Foundation

public struct PrivateJoinResult: Identifiable, Hashable {
    public let id = UUID()
    public let circle: CircleModel
    public let membership: CircleMembership
}
