//
//  AgoraAppIDProvider.swift
//  AgoraKit
//
//  Created by Nadin Ahmed on 29/07/2026.
//

import Foundation

public protocol InfoDictionaryProviding: Sendable {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: InfoDictionaryProviding {}

public protocol AgoraAppIDProviding: Sendable {
    func fetchAppID() throws -> String
}

public struct AgoraAppIDProvider: AgoraAppIDProviding {
    private let infoDictionaryProvider: InfoDictionaryProviding
    private let key: String

    public init(
        infoDictionaryProvider: InfoDictionaryProviding = Bundle.main,
        key: String = "AgoraAppID"
    ) {
        self.infoDictionaryProvider = infoDictionaryProvider
        self.key = key
    }

    public func fetchAppID() throws -> String {
        guard let value = infoDictionaryProvider.object(forInfoDictionaryKey: key) as? String else {
            throw AgoraSessionError.missingAppID
        }

        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AgoraSessionError.missingAppID
        }

        return trimmed
    }
}
