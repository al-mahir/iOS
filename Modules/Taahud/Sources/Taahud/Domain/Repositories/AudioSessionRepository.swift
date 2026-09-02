//
//  AudioSessionRepository.swift
//  Taahud
//

import Foundation

public protocol AudioSessionRepository {

     func startCapture() async throws -> AsyncThrowingStream<Data, Error>

    func stopCapture() async

    func hasMicrophonePermission() async -> Bool
    func requestMicrophonePermission() async -> Bool
}
