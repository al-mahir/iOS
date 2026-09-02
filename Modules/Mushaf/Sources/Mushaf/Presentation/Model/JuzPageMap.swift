//
//  JuzPageMap.swift
//  Mushaf
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//


//
//  JuzPageMap.swift
//  Mushaf
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//


//
//  JuzPageMap.swift
//  Mushaf
//

import Foundation

/// Standard juz boundaries for the 604-page Madani mushaf layout.
/// `startPages[i]` is the first page of juz `i + 1`.
enum JuzPageMap {
    private static let startPages: [Int] = [
        1, 22, 42, 62, 82, 102, 121, 142, 162, 182,
        201, 222, 242, 262, 282, 302, 322, 342, 362, 382,
        402, 422, 442, 462, 482, 502, 522, 542, 562, 582
    ]

    static func juzNumber(forPage page: Int) -> Int {
        var juz = 1
        for (index, startPage) in startPages.enumerated() where page >= startPage {
            juz = index + 1
        }
        return juz
    }
}
