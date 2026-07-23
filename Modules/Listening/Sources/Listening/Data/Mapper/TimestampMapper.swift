//
//  TimestampMapper.swift
//  Listening
//

import Foundation

enum TimestampMapper {

    /// Converts verse-level timestamp blocks (with nested word segments) into sorted WordTiming entities.
    static func toDomainList(_ dtos: [VerseTimestampDTO]) -> [WordTiming] {
        dtos.flatMap { verse -> [WordTiming] in
            let components = verse.verseKey.split(separator: ":")
            guard
                components.count == 2,
                let surah = Int(components[0]),
                let ayah  = Int(components[1]),
                let segments = verse.segments
            else { return [] }

            return segments.compactMap { segment -> WordTiming? in
                guard
                    segment.count >= 3,
                    segment[2] > segment[1]
                else { return nil }

                return WordTiming(
                    surah: surah,
                    ayah: ayah,
                    wordPosition: segment[0],
                    startMs: segment[1],
                    endMs: segment[2]
                )
            }
        }
        .sorted { $0.startMs < $1.startMs }
    }
}
