//
//  PageResponseDTO.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct PageResponseDTO<T: Codable & Sendable>: Codable, Sendable {
    public let content: [T]
    public let pageNumber: Int
    public let pageSize: Int
    public let totalElements: Int64
    public let totalPages: Int
    public let isLast: Bool
    public let isFirst: Bool
}
