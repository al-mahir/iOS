//
//  PageResult.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public struct PageResult<T: Sendable>: Sendable {
    public let content: [T]
    public let pageNumber: Int
    public let pageSize: Int
    public let totalElements: Int64
    public let totalPages: Int
    public let isLast: Bool
    public let isFirst: Bool

    public init(
        content: [T],
        pageNumber: Int,
        pageSize: Int,
        totalElements: Int64,
        totalPages: Int,
        isLast: Bool,
        isFirst: Bool
    ) {
        self.content = content
        self.pageNumber = pageNumber
        self.pageSize = pageSize
        self.totalElements = totalElements
        self.totalPages = totalPages
        self.isLast = isLast
        self.isFirst = isFirst
    }
}
