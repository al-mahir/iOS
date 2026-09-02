//
//  ListeningRepository.swift
//  Listening
//

import Foundation
import Combine
import NetworkKit

/// Domain contract for all Listening-related network operations
public protocol ListeningRepository: AnyObject {

    /// Fetch the full list of available reciters from Quran.com
    func fetchReciters() -> AnyPublisher<[Reciter], NetworkError>

    /// Fetch the streaming audio URL for a given reciter + chapter
    func fetchAudioURL(reciterId: Int, chapterNumber: Int) -> AnyPublisher<URL, NetworkError>

    /// Fetch all word-level timestamps for a given reciter + chapter
    func fetchWordTimings(reciterId: Int, chapterNumber: Int) -> AnyPublisher<[WordTiming], NetworkError>
}
