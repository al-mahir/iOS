//
//  JoinState.swift
//  Circles
//
//  Created by Nadin Ahmed on 04/08/2026.
//

import Foundation

public enum JoinState: Equatable {
    case pending
    case approved(CircleMember)
    case rejected(reason: String)
}
