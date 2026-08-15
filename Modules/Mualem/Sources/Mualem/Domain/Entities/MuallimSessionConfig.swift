//
//  MuallimSessionConfig.swift
//  Mualem
//

import Foundation

public struct MuallimSessionConfig: Equatable {
    public let surah: Int
    public let startAyah: Int
    public let endAyah: Int
    public let repetitions: Int
    public let qariId: String
    public let waitTime: WaitTimeMode
    
    public enum WaitTimeMode: Equatable {
        case qariPace
        case manual(seconds: Int)
    }
    
    public init(surah: Int, startAyah: Int, endAyah: Int, repetitions: Int, qariId: String, waitTime: WaitTimeMode) {
        self.surah = surah
        self.startAyah = startAyah
        self.endAyah = endAyah
        self.repetitions = repetitions
        self.qariId = qariId
        self.waitTime = waitTime
    }
}
