//
//  SurahData.swift
//  Listening
//

import Foundation
import Common

public struct SurahItem: Sendable {
    public let number: Int
    public let name: String
    public let englishName: String
    public let ayahs: Int

    public init(number: Int, name: String, englishName: String, ayahs: Int) {
        self.number = number
        self.name = name
        self.englishName = englishName
        self.ayahs = ayahs
    }

    public var localizedName: String {
        AppLanguage.isArabicActive ? name : englishName
    }
}

public enum SurahData {
    public static let surahs: [SurahItem] = [
        SurahItem(number: 1, name: "الفاتحة", englishName: "Al-Fatihah", ayahs: 7),
        SurahItem(number: 2, name: "البقرة", englishName: "Al-Baqarah", ayahs: 286),
        SurahItem(number: 3, name: "آل عمران", englishName: "Ali 'Imran", ayahs: 200),
        SurahItem(number: 4, name: "النساء", englishName: "An-Nisa", ayahs: 176),
        SurahItem(number: 5, name: "المائدة", englishName: "Al-Ma'idah", ayahs: 120),
        SurahItem(number: 6, name: "الأنعام", englishName: "Al-An'am", ayahs: 165),
        SurahItem(number: 7, name: "الأعراف", englishName: "Al-A'raf", ayahs: 206),
        SurahItem(number: 8, name: "الأنفال", englishName: "Al-Anfal", ayahs: 75),
        SurahItem(number: 9, name: "التوبة", englishName: "At-Tawbah", ayahs: 129),
        SurahItem(number: 10, name: "يونس", englishName: "Yunus", ayahs: 109),
        SurahItem(number: 11, name: "هود", englishName: "Hud", ayahs: 123),
        SurahItem(number: 12, name: "يوسف", englishName: "Yusuf", ayahs: 111),
        SurahItem(number: 13, name: "الرعد", englishName: "Ar-Ra'd", ayahs: 43),
        SurahItem(number: 14, name: "إبراهيم", englishName: "Ibrahim", ayahs: 52),
        SurahItem(number: 15, name: "الحجر", englishName: "Al-Hijr", ayahs: 99),
        SurahItem(number: 16, name: "النحل", englishName: "An-Nahl", ayahs: 128),
        SurahItem(number: 17, name: "الإسراء", englishName: "Al-Isra", ayahs: 111),
        SurahItem(number: 18, name: "الكهف", englishName: "Al-Kahf", ayahs: 110),
        SurahItem(number: 19, name: "مريم", englishName: "Maryam", ayahs: 98),
        SurahItem(number: 20, name: "طه", englishName: "Taha", ayahs: 135),
        SurahItem(number: 21, name: "الأنبياء", englishName: "Al-Anbiya", ayahs: 112),
        SurahItem(number: 22, name: "الحج", englishName: "Al-Hajj", ayahs: 78),
        SurahItem(number: 23, name: "المؤمنون", englishName: "Al-Mu'minun", ayahs: 118),
        SurahItem(number: 24, name: "النور", englishName: "An-Nur", ayahs: 64),
        SurahItem(number: 25, name: "الفرقان", englishName: "Al-Furqan", ayahs: 77),
        SurahItem(number: 26, name: "الشعراء", englishName: "Ash-Shu'ara", ayahs: 227),
        SurahItem(number: 27, name: "النمل", englishName: "An-Naml", ayahs: 93),
        SurahItem(number: 28, name: "القصص", englishName: "Al-Qasas", ayahs: 88),
        SurahItem(number: 29, name: "العنكبوت", englishName: "Al-'Ankabut", ayahs: 69),
        SurahItem(number: 30, name: "الروم", englishName: "Ar-Rum", ayahs: 60),
        SurahItem(number: 31, name: "لقمان", englishName: "Luqman", ayahs: 34),
        SurahItem(number: 32, name: "السجدة", englishName: "As-Sajdah", ayahs: 30),
        SurahItem(number: 33, name: "الأحزاب", englishName: "Al-Ahzab", ayahs: 73),
        SurahItem(number: 34, name: "سبإ", englishName: "Saba", ayahs: 54),
        SurahItem(number: 35, name: "فاطر", englishName: "Fatir", ayahs: 45),
        SurahItem(number: 36, name: "يس", englishName: "Ya-Sin", ayahs: 83),
        SurahItem(number: 37, name: "الصافات", englishName: "As-Saffat", ayahs: 182),
        SurahItem(number: 38, name: "ص", englishName: "Sad", ayahs: 88),
        SurahItem(number: 39, name: "الزمر", englishName: "Az-Zumar", ayahs: 75),
        SurahItem(number: 40, name: "غافر", englishName: "Ghafir", ayahs: 85),
        SurahItem(number: 41, name: "فصلت", englishName: "Fussilat", ayahs: 54),
        SurahItem(number: 42, name: "الشورى", englishName: "Ash-Shura", ayahs: 53),
        SurahItem(number: 43, name: "الزخرف", englishName: "Az-Zukhruf", ayahs: 89),
        SurahItem(number: 44, name: "الدخان", englishName: "Ad-Dukhan", ayahs: 59),
        SurahItem(number: 45, name: "الجاثية", englishName: "Al-Jathiyah", ayahs: 37),
        SurahItem(number: 46, name: "الأحقاف", englishName: "Al-Ahqaf", ayahs: 35),
        SurahItem(number: 47, name: "محمد", englishName: "Muhammad", ayahs: 38),
        SurahItem(number: 48, name: "الفتح", englishName: "Al-Fath", ayahs: 29),
        SurahItem(number: 49, name: "الحجرات", englishName: "Al-Hujurat", ayahs: 18),
        SurahItem(number: 50, name: "ق", englishName: "Qaf", ayahs: 45),
        SurahItem(number: 51, name: "الذاريات", englishName: "Adh-Dhariyat", ayahs: 60),
        SurahItem(number: 52, name: "الطور", englishName: "At-Tur", ayahs: 49),
        SurahItem(number: 53, name: "النجم", englishName: "An-Najm", ayahs: 62),
        SurahItem(number: 54, name: "القمر", englishName: "Al-Qamar", ayahs: 55),
        SurahItem(number: 55, name: "الرحمن", englishName: "Ar-Rahman", ayahs: 78),
        SurahItem(number: 56, name: "الواقعة", englishName: "Al-Waqi'ah", ayahs: 96),
        SurahItem(number: 57, name: "الحديد", englishName: "Al-Hadid", ayahs: 29),
        SurahItem(number: 58, name: "المجادلة", englishName: "Al-Mujadila", ayahs: 22),
        SurahItem(number: 59, name: "الحشر", englishName: "Al-Hashr", ayahs: 24),
        SurahItem(number: 60, name: "الممتحنة", englishName: "Al-Mumtahanah", ayahs: 13),
        SurahItem(number: 61, name: "الصف", englishName: "As-Saff", ayahs: 14),
        SurahItem(number: 62, name: "الجمعة", englishName: "Al-Jumu'ah", ayahs: 11),
        SurahItem(number: 63, name: "المنافقون", englishName: "Al-Munafiqun", ayahs: 11),
        SurahItem(number: 64, name: "التغابن", englishName: "At-Taghabun", ayahs: 18),
        SurahItem(number: 65, name: "الطلاق", englishName: "At-Talaq", ayahs: 12),
        SurahItem(number: 66, name: "التحريم", englishName: "At-Tahrim", ayahs: 12),
        SurahItem(number: 67, name: "الملك", englishName: "Al-Mulk", ayahs: 30),
        SurahItem(number: 68, name: "القلم", englishName: "Al-Qalam", ayahs: 52),
        SurahItem(number: 69, name: "الحاقة", englishName: "Al-Haqqah", ayahs: 52),
        SurahItem(number: 70, name: "المعارج", englishName: "Al-Ma'arij", ayahs: 44),
        SurahItem(number: 71, name: "نوح", englishName: "Nuh", ayahs: 28),
        SurahItem(number: 72, name: "الجن", englishName: "Al-Jinn", ayahs: 28),
        SurahItem(number: 73, name: "المزمل", englishName: "Al-Muzzammil", ayahs: 20),
        SurahItem(number: 74, name: "المدثر", englishName: "Al-Muddaththir", ayahs: 56),
        SurahItem(number: 75, name: "القيامة", englishName: "Al-Qiyamah", ayahs: 40),
        SurahItem(number: 76, name: "الإنسان", englishName: "Al-Insan", ayahs: 31),
        SurahItem(number: 77, name: "المرسلات", englishName: "Al-Mursalat", ayahs: 50),
        SurahItem(number: 78, name: "النبإ", englishName: "An-Naba", ayahs: 40),
        SurahItem(number: 79, name: "النازعات", englishName: "An-Nazi'at", ayahs: 46),
        SurahItem(number: 80, name: "عبس", englishName: "'Abasa", ayahs: 42),
        SurahItem(number: 81, name: "التكوير", englishName: "At-Takwir", ayahs: 29),
        SurahItem(number: 82, name: "الانفطار", englishName: "Al-Infitar", ayahs: 19),
        SurahItem(number: 83, name: "المطففين", englishName: "Al-Mutaffifin", ayahs: 36),
        SurahItem(number: 84, name: "الانشقاق", englishName: "Al-Inshiqaq", ayahs: 25),
        SurahItem(number: 85, name: "البروج", englishName: "Al-Buruj", ayahs: 22),
        SurahItem(number: 86, name: "الطارق", englishName: "At-Tariq", ayahs: 17),
        SurahItem(number: 87, name: "الأعلى", englishName: "Al-A'la", ayahs: 19),
        SurahItem(number: 88, name: "الغاشية", englishName: "Al-Ghashiyah", ayahs: 26),
        SurahItem(number: 89, name: "الفجر", englishName: "Al-Fajr", ayahs: 30),
        SurahItem(number: 90, name: "البلد", englishName: "Al-Balad", ayahs: 20),
        SurahItem(number: 91, name: "الشمس", englishName: "Ash-Shams", ayahs: 15),
        SurahItem(number: 92, name: "الليل", englishName: "Al-Layl", ayahs: 21),
        SurahItem(number: 93, name: "الضحى", englishName: "Ad-Duha", ayahs: 11),
        SurahItem(number: 94, name: "الشرح", englishName: "Ash-Sharh", ayahs: 8),
        SurahItem(number: 95, name: "التين", englishName: "At-Tin", ayahs: 8),
        SurahItem(number: 96, name: "العلق", englishName: "Al-'Alaq", ayahs: 19),
        SurahItem(number: 97, name: "القدر", englishName: "Al-Qadr", ayahs: 5),
        SurahItem(number: 98, name: "البينة", englishName: "Al-Bayyinah", ayahs: 8),
        SurahItem(number: 99, name: "الزلزلة", englishName: "Az-Zalzalah", ayahs: 8),
        SurahItem(number: 100, name: "العاديات", englishName: "Al-'Adiyat", ayahs: 11),
        SurahItem(number: 101, name: "القارعة", englishName: "Al-Qari'ah", ayahs: 11),
        SurahItem(number: 102, name: "التكاثر", englishName: "At-Takathur", ayahs: 8),
        SurahItem(number: 103, name: "العصر", englishName: "Al-'Asr", ayahs: 3),
        SurahItem(number: 104, name: "الهمزة", englishName: "Al-Humazah", ayahs: 9),
        SurahItem(number: 105, name: "الفيل", englishName: "Al-Fil", ayahs: 5),
        SurahItem(number: 106, name: "قريش", englishName: "Quraysh", ayahs: 4),
        SurahItem(number: 107, name: "الماعون", englishName: "Al-Ma'un", ayahs: 7),
        SurahItem(number: 108, name: "الكوثر", englishName: "Al-Kawthar", ayahs: 3),
        SurahItem(number: 109, name: "الكافرون", englishName: "Al-Kafirun", ayahs: 6),
        SurahItem(number: 110, name: "النصر", englishName: "An-Nasr", ayahs: 3),
        SurahItem(number: 111, name: "المسد", englishName: "Al-Masad", ayahs: 5),
        SurahItem(number: 112, name: "الإخلاص", englishName: "Al-Ikhlas", ayahs: 4),
        SurahItem(number: 113, name: "الفلق", englishName: "Al-Falaq", ayahs: 5),
        SurahItem(number: 114, name: "الناس", englishName: "An-Nas", ayahs: 6)
    ]

    public static func englishName(for number: Int) -> String {
        guard number >= 1 && number <= surahs.count else { return "" }
        return surahs[number - 1].englishName
    }

    public static func arabicName(for number: Int) -> String {
        guard number >= 1 && number <= surahs.count else { return "" }
        return surahs[number - 1].name
    }

    public static func localizedName(for number: Int) -> String {
        guard number >= 1 && number <= surahs.count else { return "" }
        return AppLanguage.isArabicActive ? arabicName(for: number) : englishName(for: number)
    }

    public static let surahStartPages: [Int] = [
        1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
        221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
        322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
        411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
        477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
        520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
        551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
        570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
        586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
        595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
        600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
        603, 604, 604, 604
    ]

    public static func pageStart(for number: Int) -> Int {
        guard number >= 1 && number <= surahStartPages.count else { return 1 }
        return surahStartPages[number - 1]
    }
}
