//
//  SheikhAudioSample.swift
//  Sheikh
//

import Foundation

public struct SheikhAudioSample: Codable, Sendable, Identifiable, Equatable, Hashable {
    public let id: String
    public let title: String
    public let riwaya: String
    public let audioUrl: String
    public let duration: String

    public init(
        id: String,
        title: String,
        riwaya: String,
        audioUrl: String,
        duration: String = "02:45"
    ) {
        self.id = id
        self.title = title
        self.riwaya = riwaya
        self.audioUrl = audioUrl
        self.duration = duration
    }
}
