//
//  PageDTO.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

public struct PageDTO<T: Decodable>: Decodable {
    public let content: [T]
    public let totalElements: Int
    public let totalPages: Int
    public let number: Int
    public let first: Bool
    public let last: Bool
    public let numberOfElements: Int
    public let empty: Bool
}
