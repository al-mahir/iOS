//
//  SurahBookmarkMetadata.swift
//  Mushaf
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//


//
//  SurahBookmarkMetadata.swift
//  Mushaf
//
//  Created by Alaa Ayman on 08/02/1448 AH.
//




import Foundation

enum SurahBookmarkMetadata {
    struct Info {
        let englishName: String
        let ayahCount: Int
    }

    static func info(for surahNumber: Int) -> Info? {
        table[surahNumber]
    }

    private static let table: [Int: Info] = [
        1: Info(englishName: "Al-Fatihah", ayahCount: 7),
        2: Info(englishName: "Al-Baqarah", ayahCount: 286),
        3: Info(englishName: "Aal-E-Imran", ayahCount: 200),
        4: Info(englishName: "An-Nisa", ayahCount: 176),
        5: Info(englishName: "Al-Ma'idah", ayahCount: 120),
        6: Info(englishName: "Al-An'am", ayahCount: 165),
        7: Info(englishName: "Al-A'raf", ayahCount: 206),
        8: Info(englishName: "Al-Anfal", ayahCount: 75),
        9: Info(englishName: "At-Tawbah", ayahCount: 129),
        10: Info(englishName: "Yunus", ayahCount: 109),
        11: Info(englishName: "Hud", ayahCount: 123),
        12: Info(englishName: "Yusuf", ayahCount: 111),
        13: Info(englishName: "Ar-Ra'd", ayahCount: 43),
        14: Info(englishName: "Ibrahim", ayahCount: 52),
        15: Info(englishName: "Al-Hijr", ayahCount: 99),
        16: Info(englishName: "An-Nahl", ayahCount: 128),
        17: Info(englishName: "Al-Isra", ayahCount: 111),
        18: Info(englishName: "Al-Kahf", ayahCount: 110),
        19: Info(englishName: "Maryam", ayahCount: 98),
        20: Info(englishName: "Ta-Ha", ayahCount: 135),
        21: Info(englishName: "Al-Anbya", ayahCount: 112),
        22: Info(englishName: "Al-Hajj", ayahCount: 78),
        23: Info(englishName: "Al-Mu'minun", ayahCount: 118),
        24: Info(englishName: "An-Nur", ayahCount: 64),
        25: Info(englishName: "Al-Furqan", ayahCount: 77),
        26: Info(englishName: "Ash-Shu'ara", ayahCount: 227),
        27: Info(englishName: "An-Naml", ayahCount: 93),
        28: Info(englishName: "Al-Qasas", ayahCount: 88),
        29: Info(englishName: "Al-Ankabut", ayahCount: 69),
        30: Info(englishName: "Ar-Rum", ayahCount: 60),
        31: Info(englishName: "Luqman", ayahCount: 34),
        32: Info(englishName: "As-Sajda", ayahCount: 30),
        33: Info(englishName: "Al-Ahzab", ayahCount: 73),
        34: Info(englishName: "Saba", ayahCount: 54),
        35: Info(englishName: "Fatir", ayahCount: 45),
        36: Info(englishName: "Ya-Sin", ayahCount: 83),
        37: Info(englishName: "As-Saffat", ayahCount: 182),
        38: Info(englishName: "Sad", ayahCount: 88),
        39: Info(englishName: "Az-Zumar", ayahCount: 75),
        40: Info(englishName: "Ghafir", ayahCount: 85),
        41: Info(englishName: "Fussilat", ayahCount: 54),
        42: Info(englishName: "Ash-Shura", ayahCount: 53),
        43: Info(englishName: "Az-Zukhruf", ayahCount: 89),
        44: Info(englishName: "Ad-Dukhan", ayahCount: 59),
        45: Info(englishName: "Al-Jathiya", ayahCount: 37),
        46: Info(englishName: "Al-Ahqaf", ayahCount: 35),
        47: Info(englishName: "Muhammad", ayahCount: 38),
        48: Info(englishName: "Al-Fath", ayahCount: 29),
        49: Info(englishName: "Al-Hujurat", ayahCount: 18),
        50: Info(englishName: "Qaf", ayahCount: 45),
        51: Info(englishName: "Adh-Dhariyat", ayahCount: 60),
        52: Info(englishName: "At-Tur", ayahCount: 49),
        53: Info(englishName: "An-Najm", ayahCount: 62),
        54: Info(englishName: "Al-Qamar", ayahCount: 55),
        55: Info(englishName: "Ar-Rahman", ayahCount: 78),
        56: Info(englishName: "Al-Waqi'a", ayahCount: 96),
        57: Info(englishName: "Al-Hadid", ayahCount: 29),
        58: Info(englishName: "Al-Mujadila", ayahCount: 22),
        59: Info(englishName: "Al-Hashr", ayahCount: 24),
        60: Info(englishName: "Al-Mumtahina", ayahCount: 13),
        61: Info(englishName: "As-Saff", ayahCount: 14),
        62: Info(englishName: "Al-Jumu'a", ayahCount: 11),
        63: Info(englishName: "Al-Munafiqun", ayahCount: 11),
        64: Info(englishName: "At-Taghabun", ayahCount: 18),
        65: Info(englishName: "At-Talaq", ayahCount: 12),
        66: Info(englishName: "At-Tahrim", ayahCount: 12),
        67: Info(englishName: "Al-Mulk", ayahCount: 30),
        68: Info(englishName: "Al-Qalam", ayahCount: 52),
        69: Info(englishName: "Al-Haqqah", ayahCount: 52),
        70: Info(englishName: "Al-Ma'arij", ayahCount: 44),
        71: Info(englishName: "Nuh", ayahCount: 28),
        72: Info(englishName: "Al-Jinn", ayahCount: 28),
        73: Info(englishName: "Al-Muzzammil", ayahCount: 20),
        74: Info(englishName: "Al-Muddaththir", ayahCount: 56),
        75: Info(englishName: "Al-Qiyama", ayahCount: 40),
        76: Info(englishName: "Al-Insan", ayahCount: 31),
        77: Info(englishName: "Al-Mursalat", ayahCount: 50),
        78: Info(englishName: "An-Naba", ayahCount: 40),
        79: Info(englishName: "An-Nazi'at", ayahCount: 46),
        80: Info(englishName: "Abasa", ayahCount: 42),
        81: Info(englishName: "At-Takwir", ayahCount: 29),
        82: Info(englishName: "Al-Infitar", ayahCount: 19),
        83: Info(englishName: "Al-Mutaffifin", ayahCount: 36),
        84: Info(englishName: "Al-Inshiqaq", ayahCount: 25),
        85: Info(englishName: "Al-Buruj", ayahCount: 22),
        86: Info(englishName: "At-Tariq", ayahCount: 17),
        87: Info(englishName: "Al-A'la", ayahCount: 19),
        88: Info(englishName: "Al-Ghashiya", ayahCount: 26),
        89: Info(englishName: "Al-Fajr", ayahCount: 30),
        90: Info(englishName: "Al-Balad", ayahCount: 20),
        91: Info(englishName: "Ash-Shams", ayahCount: 15),
        92: Info(englishName: "Al-Layl", ayahCount: 21),
        93: Info(englishName: "Ad-Duha", ayahCount: 11),
        94: Info(englishName: "Ash-Sharh", ayahCount: 8),
        95: Info(englishName: "At-Tin", ayahCount: 8),
        96: Info(englishName: "Al-Alaq", ayahCount: 19),
        97: Info(englishName: "Al-Qadr", ayahCount: 5),
        98: Info(englishName: "Al-Bayyina", ayahCount: 8),
        99: Info(englishName: "Az-Zalzala", ayahCount: 8),
        100: Info(englishName: "Al-Adiyat", ayahCount: 11),
        101: Info(englishName: "Al-Qari'a", ayahCount: 11),
        102: Info(englishName: "At-Takathur", ayahCount: 8),
        103: Info(englishName: "Al-Asr", ayahCount: 3),
        104: Info(englishName: "Al-Humaza", ayahCount: 9),
        105: Info(englishName: "Al-Fil", ayahCount: 5),
        106: Info(englishName: "Quraysh", ayahCount: 4),
        107: Info(englishName: "Al-Ma'un", ayahCount: 7),
        108: Info(englishName: "Al-Kawthar", ayahCount: 3),
        109: Info(englishName: "Al-Kafirun", ayahCount: 6),
        110: Info(englishName: "An-Nasr", ayahCount: 3),
        111: Info(englishName: "Al-Masad", ayahCount: 5),
        112: Info(englishName: "Al-Ikhlas", ayahCount: 4),
        113: Info(englishName: "Al-Falaq", ayahCount: 5),
        114: Info(englishName: "An-Nas", ayahCount: 6)
    ]
}
