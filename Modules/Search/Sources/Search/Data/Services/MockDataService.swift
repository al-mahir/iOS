//
//  MockDataService.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import Foundation

class MockDataService {
    nonisolated(unsafe) static let shared = MockDataService()
    private init() {}
    
    func getAllSurahs() -> [Surah] {
        return [
            Surah(id: 1, name: "Al-Fatihah", arabicName: "الفاتحة", englishName: "Al-Fatihah", ayahCount: 7, revelationType: .meccan, juzStart: 1, juzEnd: 1, pageStart: 1, pageEnd: 1),
            Surah(id: 2, name: "Al-Baqarah", arabicName: "البقرة", englishName: "Al-Baqarah", ayahCount: 286, revelationType: .medinan, juzStart: 1, juzEnd: 3, pageStart: 2, pageEnd: 49),
            Surah(id: 3, name: "Ali 'Imran", arabicName: "آل عمران", englishName: "Ali 'Imran", ayahCount: 200, revelationType: .medinan, juzStart: 3, juzEnd: 4, pageStart: 50, pageEnd: 76),
            Surah(id: 4, name: "An-Nisa", arabicName: "النساء", englishName: "An-Nisa", ayahCount: 176, revelationType: .medinan, juzStart: 4, juzEnd: 6, pageStart: 77, pageEnd: 106),
            Surah(id: 5, name: "Al-Ma'idah", arabicName: "المائدة", englishName: "Al-Ma'idah", ayahCount: 120, revelationType: .medinan, juzStart: 6, juzEnd: 7, pageStart: 106, pageEnd: 127),
            Surah(id: 6, name: "Al-An'am", arabicName: "الأنعام", englishName: "Al-An'am", ayahCount: 165, revelationType: .meccan, juzStart: 7, juzEnd: 8, pageStart: 128, pageEnd: 150),
            Surah(id: 7, name: "Al-A'raf", arabicName: "الأعراف", englishName: "Al-A'raf", ayahCount: 206, revelationType: .meccan, juzStart: 8, juzEnd: 9, pageStart: 151, pageEnd: 176),
            Surah(id: 8, name: "Al-Anfal", arabicName: "الأنفال", englishName: "Al-Anfal", ayahCount: 75, revelationType: .medinan, juzStart: 9, juzEnd: 10, pageStart: 177, pageEnd: 186),
            Surah(id: 9, name: "At-Tawbah", arabicName: "التوبة", englishName: "At-Tawbah", ayahCount: 129, revelationType: .medinan, juzStart: 10, juzEnd: 11, pageStart: 187, pageEnd: 207),
            Surah(id: 10, name: "Yunus", arabicName: "يونس", englishName: "Yunus", ayahCount: 109, revelationType: .meccan, juzStart: 11, juzEnd: 11, pageStart: 208, pageEnd: 221),
            Surah(id: 11, name: "Hud", arabicName: "هود", englishName: "Hud", ayahCount: 123, revelationType: .meccan, juzStart: 11, juzEnd: 12, pageStart: 221, pageEnd: 235),
            Surah(id: 12, name: "Yusuf", arabicName: "يوسف", englishName: "Yusuf", ayahCount: 111, revelationType: .meccan, juzStart: 12, juzEnd: 13, pageStart: 235, pageEnd: 248),
            Surah(id: 13, name: "Ar-Ra'd", arabicName: "الرعد", englishName: "Ar-Ra'd", ayahCount: 43, revelationType: .medinan, juzStart: 13, juzEnd: 13, pageStart: 249, pageEnd: 255),
            Surah(id: 14, name: "Ibrahim", arabicName: "إبراهيم", englishName: "Ibrahim", ayahCount: 52, revelationType: .meccan, juzStart: 13, juzEnd: 13, pageStart: 255, pageEnd: 261),
            Surah(id: 15, name: "Al-Hijr", arabicName: "الحجر", englishName: "Al-Hijr", ayahCount: 99, revelationType: .meccan, juzStart: 14, juzEnd: 14, pageStart: 262, pageEnd: 267),
            Surah(id: 16, name: "An-Nahl", arabicName: "النحل", englishName: "An-Nahl", ayahCount: 128, revelationType: .meccan, juzStart: 14, juzEnd: 14, pageStart: 267, pageEnd: 281),
            Surah(id: 17, name: "Al-Isra", arabicName: "الإسراء", englishName: "Al-Isra", ayahCount: 111, revelationType: .meccan, juzStart: 15, juzEnd: 15, pageStart: 282, pageEnd: 293),
            Surah(id: 18, name: "Al-Kahf", arabicName: "الكهف", englishName: "Al-Kahf", ayahCount: 110, revelationType: .meccan, juzStart: 15, juzEnd: 16, pageStart: 293, pageEnd: 304),
            Surah(id: 19, name: "Maryam", arabicName: "مريم", englishName: "Maryam", ayahCount: 98, revelationType: .meccan, juzStart: 16, juzEnd: 16, pageStart: 305, pageEnd: 312),
            Surah(id: 20, name: "Ta-Ha", arabicName: "طه", englishName: "Ta-Ha", ayahCount: 135, revelationType: .meccan, juzStart: 16, juzEnd: 16, pageStart: 312, pageEnd: 321),
            Surah(id: 21, name: "Al-Anbiya", arabicName: "الأنبياء", englishName: "Al-Anbiya", ayahCount: 112, revelationType: .meccan, juzStart: 17, juzEnd: 17, pageStart: 322, pageEnd: 331),
            Surah(id: 22, name: "Al-Hajj", arabicName: "الحج", englishName: "Al-Hajj", ayahCount: 78, revelationType: .medinan, juzStart: 17, juzEnd: 17, pageStart: 332, pageEnd: 341),
            Surah(id: 23, name: "Al-Mu'minun", arabicName: "المؤمنون", englishName: "Al-Mu'minun", ayahCount: 118, revelationType: .meccan, juzStart: 18, juzEnd: 18, pageStart: 342, pageEnd: 351),
            Surah(id: 24, name: "An-Nur", arabicName: "النور", englishName: "An-Nur", ayahCount: 64, revelationType: .medinan, juzStart: 18, juzEnd: 18, pageStart: 351, pageEnd: 364),
            Surah(id: 25, name: "Al-Furqan", arabicName: "الفرقان", englishName: "Al-Furqan", ayahCount: 77, revelationType: .meccan, juzStart: 18, juzEnd: 19, pageStart: 364, pageEnd: 376),
            Surah(id: 26, name: "Ash-Shu'ara", arabicName: "الشعراء", englishName: "Ash-Shu'ara", ayahCount: 227, revelationType: .meccan, juzStart: 19, juzEnd: 19, pageStart: 376, pageEnd: 396),
            Surah(id: 27, name: "An-Naml", arabicName: "النمل", englishName: "An-Naml", ayahCount: 93, revelationType: .meccan, juzStart: 19, juzEnd: 20, pageStart: 396, pageEnd: 404),
            Surah(id: 28, name: "Al-Qasas", arabicName: "القصص", englishName: "Al-Qasas", ayahCount: 88, revelationType: .meccan, juzStart: 20, juzEnd: 20, pageStart: 404, pageEnd: 414),
            Surah(id: 29, name: "Al-Ankabut", arabicName: "العنكبوت", englishName: "Al-Ankabut", ayahCount: 69, revelationType: .meccan, juzStart: 20, juzEnd: 21, pageStart: 415, pageEnd: 427),
            Surah(id: 30, name: "Ar-Rum", arabicName: "الروم", englishName: "Ar-Rum", ayahCount: 60, revelationType: .meccan, juzStart: 21, juzEnd: 21, pageStart: 428, pageEnd: 434),
            Surah(id: 31, name: "Luqman", arabicName: "لقمان", englishName: "Luqman", ayahCount: 34, revelationType: .meccan, juzStart: 21, juzEnd: 21, pageStart: 434, pageEnd: 438),
            Surah(id: 32, name: "As-Sajdah", arabicName: "السجدة", englishName: "As-Sajdah", ayahCount: 30, revelationType: .meccan, juzStart: 21, juzEnd: 21, pageStart: 438, pageEnd: 440),
            Surah(id: 33, name: "Al-Ahzab", arabicName: "الأحزاب", englishName: "Al-Ahzab", ayahCount: 73, revelationType: .medinan, juzStart: 21, juzEnd: 22, pageStart: 440, pageEnd: 451),
            Surah(id: 34, name: "Saba'", arabicName: "سبأ", englishName: "Saba'", ayahCount: 54, revelationType: .meccan, juzStart: 22, juzEnd: 22, pageStart: 451, pageEnd: 458),
            Surah(id: 35, name: "Fatir", arabicName: "فاطر", englishName: "Fatir", ayahCount: 45, revelationType: .meccan, juzStart: 22, juzEnd: 22, pageStart: 458, pageEnd: 464),
            Surah(id: 36, name: "Ya-Sin", arabicName: "يس", englishName: "Ya-Sin", ayahCount: 83, revelationType: .meccan, juzStart: 22, juzEnd: 23, pageStart: 465, pageEnd: 472),
            Surah(id: 37, name: "As-Saffat", arabicName: "الصافات", englishName: "As-Saffat", ayahCount: 182, revelationType: .meccan, juzStart: 23, juzEnd: 23, pageStart: 472, pageEnd: 482),
            Surah(id: 38, name: "Sad", arabicName: "ص", englishName: "Sad", ayahCount: 88, revelationType: .meccan, juzStart: 23, juzEnd: 23, pageStart: 483, pageEnd: 489),
            Surah(id: 39, name: "Az-Zumar", arabicName: "الزمر", englishName: "Az-Zumar", ayahCount: 75, revelationType: .meccan, juzStart: 23, juzEnd: 24, pageStart: 489, pageEnd: 501),
            Surah(id: 40, name: "Ghâfir", arabicName: "غافر", englishName: "Ghâfir", ayahCount: 85, revelationType: .meccan, juzStart: 24, juzEnd: 24, pageStart: 502, pageEnd: 515),
            Surah(id: 41, name: "Fussilat", arabicName: "فصلت", englishName: "Fussilat", ayahCount: 54, revelationType: .meccan, juzStart: 24, juzEnd: 25, pageStart: 515, pageEnd: 523),
            Surah(id: 42, name: "Ash-Shura", arabicName: "الشورى", englishName: "Ash-Shura", ayahCount: 53, revelationType: .meccan, juzStart: 25, juzEnd: 25, pageStart: 523, pageEnd: 531),
            Surah(id: 43, name: "Az-Zukhruf", arabicName: "الزخرف", englishName: "Az-Zukhruf", ayahCount: 89, revelationType: .meccan, juzStart: 25, juzEnd: 25, pageStart: 531, pageEnd: 541),
            Surah(id: 44, name: "Ad-Dukhan", arabicName: "الدخان", englishName: "Ad-Dukhan", ayahCount: 59, revelationType: .meccan, juzStart: 25, juzEnd: 25, pageStart: 541, pageEnd: 545),
            Surah(id: 45, name: "Al-Jathiyah", arabicName: "الجاثية", englishName: "Al-Jathiyah", ayahCount: 37, revelationType: .meccan, juzStart: 25, juzEnd: 25, pageStart: 545, pageEnd: 548),
            Surah(id: 46, name: "Al-Ahqaf", arabicName: "الأحقاف", englishName: "Al-Ahqaf", ayahCount: 35, revelationType: .meccan, juzStart: 26, juzEnd: 26, pageStart: 549, pageEnd: 552),
            Surah(id: 47, name: "Muhammad", arabicName: "محمد", englishName: "Muhammad", ayahCount: 38, revelationType: .medinan, juzStart: 26, juzEnd: 26, pageStart: 553, pageEnd: 557),
            Surah(id: 48, name: "Al-Fath", arabicName: "الفتح", englishName: "Al-Fath", ayahCount: 29, revelationType: .medinan, juzStart: 26, juzEnd: 26, pageStart: 557, pageEnd: 561),
            Surah(id: 49, name: "Al-Hujurat", arabicName: "الحجرات", englishName: "Al-Hujurat", ayahCount: 18, revelationType: .medinan, juzStart: 26, juzEnd: 26, pageStart: 561, pageEnd: 564),
            Surah(id: 50, name: "Qaf", arabicName: "ق", englishName: "Qaf", ayahCount: 45, revelationType: .meccan, juzStart: 26, juzEnd: 26, pageStart: 564, pageEnd: 567),
            Surah(id: 51, name: "Adh-Dhariyat", arabicName: "الذاريات", englishName: "Adh-Dhariyat", ayahCount: 60, revelationType: .meccan, juzStart: 26, juzEnd: 27, pageStart: 568, pageEnd: 571),
            Surah(id: 52, name: "At-Tur", arabicName: "الطور", englishName: "At-Tur", ayahCount: 49, revelationType: .meccan, juzStart: 27, juzEnd: 27, pageStart: 572, pageEnd: 574),
            Surah(id: 53, name: "An-Najm", arabicName: "النجم", englishName: "An-Najm", ayahCount: 62, revelationType: .meccan, juzStart: 27, juzEnd: 27, pageStart: 575, pageEnd: 577),
            Surah(id: 54, name: "Al-Qamar", arabicName: "القمر", englishName: "Al-Qamar", ayahCount: 55, revelationType: .meccan, juzStart: 27, juzEnd: 27, pageStart: 577, pageEnd: 581),
            Surah(id: 55, name: "Ar-Rahman", arabicName: "الرحمن", englishName: "Ar-Rahman", ayahCount: 78, revelationType: .medinan, juzStart: 27, juzEnd: 27, pageStart: 581, pageEnd: 585),
            Surah(id: 56, name: "Al-Waqi'ah", arabicName: "الواقعة", englishName: "Al-Waqi'ah", ayahCount: 96, revelationType: .meccan, juzStart: 27, juzEnd: 27, pageStart: 585, pageEnd: 589),
            Surah(id: 57, name: "Al-Hadid", arabicName: "الحديد", englishName: "Al-Hadid", ayahCount: 29, revelationType: .medinan, juzStart: 27, juzEnd: 27, pageStart: 589, pageEnd: 595),
            Surah(id: 58, name: "Al-Mujadilah", arabicName: "المجادلة", englishName: "Al-Mujadilah", ayahCount: 22, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 595, pageEnd: 598),
            Surah(id: 59, name: "Al-Hashr", arabicName: "الحشر", englishName: "Al-Hashr", ayahCount: 24, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 598, pageEnd: 602),
            Surah(id: 60, name: "Al-Mumtahanah", arabicName: "الممتحنة", englishName: "Al-Mumtahanah", ayahCount: 13, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 602, pageEnd: 605),
            Surah(id: 61, name: "As-Saff", arabicName: "الصف", englishName: "As-Saff", ayahCount: 14, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 605, pageEnd: 607),
            Surah(id: 62, name: "Al-Jumu'ah", arabicName: "الجمعة", englishName: "Al-Jumu'ah", ayahCount: 11, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 607, pageEnd: 609),
            Surah(id: 63, name: "Al-Munafiqun", arabicName: "المنافقون", englishName: "Al-Munafiqun", ayahCount: 11, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 609, pageEnd: 611),
            Surah(id: 64, name: "At-Taghabun", arabicName: "التغابن", englishName: "At-Taghabun", ayahCount: 18, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 611, pageEnd: 613),
            Surah(id: 65, name: "At-Talaq", arabicName: "الطلاق", englishName: "At-Talaq", ayahCount: 12, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 613, pageEnd: 615),
            Surah(id: 66, name: "At-Tahrim", arabicName: "التحريم", englishName: "At-Tahrim", ayahCount: 12, revelationType: .medinan, juzStart: 28, juzEnd: 28, pageStart: 615, pageEnd: 617),
            Surah(id: 67, name: "Al-Mulk", arabicName: "الملك", englishName: "Al-Mulk", ayahCount: 30, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 618, pageEnd: 620),
            Surah(id: 68, name: "Al-Qalam", arabicName: "القلم", englishName: "Al-Qalam", ayahCount: 52, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 620, pageEnd: 624),
            Surah(id: 69, name: "Al-Haqqah", arabicName: "الحاقة", englishName: "Al-Haqqah", ayahCount: 52, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 624, pageEnd: 627),
            Surah(id: 70, name: "Al-Ma'arij", arabicName: "المعارج", englishName: "Al-Ma'arij", ayahCount: 44, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 627, pageEnd: 629),
            Surah(id: 71, name: "Nuh", arabicName: "نوح", englishName: "Nuh", ayahCount: 28, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 629, pageEnd: 631),
            Surah(id: 72, name: "Al-Jinn", arabicName: "الجن", englishName: "Al-Jinn", ayahCount: 28, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 631, pageEnd: 633),
            Surah(id: 73, name: "Al-Muzzammil", arabicName: "المزمل", englishName: "Al-Muzzammil", ayahCount: 20, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 634, pageEnd: 636),
            Surah(id: 74, name: "Al-Muddaththir", arabicName: "المدثر", englishName: "Al-Muddaththir", ayahCount: 56, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 636, pageEnd: 638),
            Surah(id: 75, name: "Al-Qiyamah", arabicName: "القيامة", englishName: "Al-Qiyamah", ayahCount: 40, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 638, pageEnd: 640),
            Surah(id: 76, name: "Al-Insan", arabicName: "الإنسان", englishName: "Al-Insan", ayahCount: 31, revelationType: .medinan, juzStart: 29, juzEnd: 29, pageStart: 641, pageEnd: 643),
            Surah(id: 77, name: "Al-Mursalat", arabicName: "المرسلات", englishName: "Al-Mursalat", ayahCount: 50, revelationType: .meccan, juzStart: 29, juzEnd: 29, pageStart: 643, pageEnd: 645),
            Surah(id: 78, name: "An-Naba'", arabicName: "النبأ", englishName: "An-Naba'", ayahCount: 40, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 645, pageEnd: 647),
            Surah(id: 79, name: "An-Nazi'at", arabicName: "النازعات", englishName: "An-Nazi'at", ayahCount: 46, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 647, pageEnd: 649),
            Surah(id: 80, name: "'Abasa", arabicName: "عبس", englishName: "'Abasa", ayahCount: 42, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 649, pageEnd: 651),
            Surah(id: 81, name: "At-Takwir", arabicName: "التكوير", englishName: "At-Takwir", ayahCount: 29, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 651, pageEnd: 652),
            Surah(id: 82, name: "Al-Infitar", arabicName: "الانفطار", englishName: "Al-Infitar", ayahCount: 19, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 653, pageEnd: 653),
            Surah(id: 83, name: "Al-Mutaffifin", arabicName: "المطففين", englishName: "Al-Mutaffifin", ayahCount: 36, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 654, pageEnd: 655),
            Surah(id: 84, name: "Al-Inshiqaq", arabicName: "الانشقاق", englishName: "Al-Inshiqaq", ayahCount: 25, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 656, pageEnd: 657),
            Surah(id: 85, name: "Al-Buruj", arabicName: "البروج", englishName: "Al-Buruj", ayahCount: 22, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 657, pageEnd: 658),
            Surah(id: 86, name: "At-Tariq", arabicName: "الطارق", englishName: "At-Tariq", ayahCount: 17, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 659, pageEnd: 659),
            Surah(id: 87, name: "Al-A'la", arabicName: "الأعلى", englishName: "Al-A'la", ayahCount: 19, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 660, pageEnd: 660),
            Surah(id: 88, name: "Al-Ghashiyah", arabicName: "الغاشية", englishName: "Al-Ghashiyah", ayahCount: 26, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 661, pageEnd: 662),
            Surah(id: 89, name: "Al-Fajr", arabicName: "الفجر", englishName: "Al-Fajr", ayahCount: 30, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 662, pageEnd: 664),
            Surah(id: 90, name: "Al-Balad", arabicName: "البلد", englishName: "Al-Balad", ayahCount: 20, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 664, pageEnd: 665),
            Surah(id: 91, name: "Ash-Shams", arabicName: "الشمس", englishName: "Ash-Shams", ayahCount: 15, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 665, pageEnd: 666),
            Surah(id: 92, name: "Al-Layl", arabicName: "الليل", englishName: "Al-Layl", ayahCount: 21, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 666, pageEnd: 667),
            Surah(id: 93, name: "Ad-Duha", arabicName: "الضحى", englishName: "Ad-Duha", ayahCount: 11, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 668, pageEnd: 668),
            Surah(id: 94, name: "Ash-Sharh", arabicName: "الشرح", englishName: "Ash-Sharh", ayahCount: 8, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 668, pageEnd: 669),
            Surah(id: 95, name: "At-Tin", arabicName: "التين", englishName: "At-Tin", ayahCount: 8, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 669, pageEnd: 669),
            Surah(id: 96, name: "Al-'Alaq", arabicName: "العلق", englishName: "Al-'Alaq", ayahCount: 19, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 670, pageEnd: 671),
            Surah(id: 97, name: "Al-Qadr", arabicName: "القدر", englishName: "Al-Qadr", ayahCount: 5, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 671, pageEnd: 671),
            Surah(id: 98, name: "Al-Bayyinah", arabicName: "البينة", englishName: "Al-Bayyinah", ayahCount: 8, revelationType: .medinan, juzStart: 30, juzEnd: 30, pageStart: 672, pageEnd: 673),
            Surah(id: 99, name: "Az-Zalzalah", arabicName: "الزلزلة", englishName: "Az-Zalzalah", ayahCount: 8, revelationType: .medinan, juzStart: 30, juzEnd: 30, pageStart: 673, pageEnd: 674),
            Surah(id: 100, name: "Al-'Adiyat", arabicName: "العاديات", englishName: "Al-'Adiyat", ayahCount: 11, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 674, pageEnd: 675),
            Surah(id: 101, name: "Al-Qari'ah", arabicName: "القارعة", englishName: "Al-Qari'ah", ayahCount: 11, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 675, pageEnd: 676),
            Surah(id: 102, name: "At-Takathur", arabicName: "التكاثر", englishName: "At-Takathur", ayahCount: 8, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 676, pageEnd: 676),
            Surah(id: 103, name: "Al-'Asr", arabicName: "العصر", englishName: "Al-'Asr", ayahCount: 3, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 677, pageEnd: 677),
            Surah(id: 104, name: "Al-Humazah", arabicName: "الهمزة", englishName: "Al-Humazah", ayahCount: 9, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 677, pageEnd: 678),
            Surah(id: 105, name: "Al-Fil", arabicName: "الفيل", englishName: "Al-Fil", ayahCount: 5, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 678, pageEnd: 679),
            Surah(id: 106, name: "Quraysh", arabicName: "قريش", englishName: "Quraysh", ayahCount: 4, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 679, pageEnd: 679),
            Surah(id: 107, name: "Al-Ma'un", arabicName: "الماعون", englishName: "Al-Ma'un", ayahCount: 7, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 680, pageEnd: 680),
            Surah(id: 108, name: "Al-Kawthar", arabicName: "الكوثر", englishName: "Al-Kawthar", ayahCount: 3, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 681, pageEnd: 681),
            Surah(id: 109, name: "Al-Kafirun", arabicName: "الكافرون", englishName: "Al-Kafirun", ayahCount: 6, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 681, pageEnd: 682),
            Surah(id: 110, name: "An-Nasr", arabicName: "النصر", englishName: "An-Nasr", ayahCount: 3, revelationType: .medinan, juzStart: 30, juzEnd: 30, pageStart: 682, pageEnd: 682),
            Surah(id: 111, name: "Al-Masad", arabicName: "المسد", englishName: "Al-Masad", ayahCount: 5, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 683, pageEnd: 683),
            Surah(id: 112, name: "Al-Ikhlas", arabicName: "الإخلاص", englishName: "Al-Ikhlas", ayahCount: 4, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 683, pageEnd: 684),
            Surah(id: 113, name: "Al-Falaq", arabicName: "الفلق", englishName: "Al-Falaq", ayahCount: 5, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 684, pageEnd: 684),
            Surah(id: 114, name: "An-Nas", arabicName: "الناس", englishName: "An-Nas", ayahCount: 6, revelationType: .meccan, juzStart: 30, juzEnd: 30, pageStart: 685, pageEnd: 685)
        ]
    }
    
    func getAllJuz() -> [Juz] {
        return [
            Juz(id: 1, number: 1, surahRange: "1-2", ayahRange: "1:1-2:141", pageStart: 1, pageEnd: 21),
            Juz(id: 2, number: 2, surahRange: "2", ayahRange: "2:142-2:252", pageStart: 22, pageEnd: 41),
            Juz(id: 3, number: 3, surahRange: "2-3", ayahRange: "2:253-3:92", pageStart: 42, pageEnd: 61),
            Juz(id: 4, number: 4, surahRange: "3-4", ayahRange: "3:93-4:23", pageStart: 62, pageEnd: 81),
            Juz(id: 5, number: 5, surahRange: "4", ayahRange: "4:24-4:147", pageStart: 82, pageEnd: 101),
            Juz(id: 6, number: 6, surahRange: "4-5", ayahRange: "4:148-5:81", pageStart: 102, pageEnd: 121),
            Juz(id: 7, number: 7, surahRange: "5-6", ayahRange: "5:82-6:110", pageStart: 122, pageEnd: 141),
            Juz(id: 8, number: 8, surahRange: "6-7", ayahRange: "6:111-7:87", pageStart: 142, pageEnd: 161),
            Juz(id: 9, number: 9, surahRange: "7-8", ayahRange: "7:88-8:40", pageStart: 162, pageEnd: 181),
            Juz(id: 10, number: 10, surahRange: "8-9", ayahRange: "8:41-9:92", pageStart: 182, pageEnd: 201),
            Juz(id: 11, number: 11, surahRange: "9-11", ayahRange: "9:93-11:5", pageStart: 202, pageEnd: 221),
            Juz(id: 12, number: 12, surahRange: "11-12", ayahRange: "11:6-12:52", pageStart: 222, pageEnd: 241),
            Juz(id: 13, number: 13, surahRange: "12-14", ayahRange: "12:53-14:52", pageStart: 242, pageEnd: 261),
            Juz(id: 14, number: 14, surahRange: "15-16", ayahRange: "15:1-16:128", pageStart: 262, pageEnd: 281),
            Juz(id: 15, number: 15, surahRange: "17-18", ayahRange: "17:1-18:74", pageStart: 282, pageEnd: 301),
            Juz(id: 16, number: 16, surahRange: "18-20", ayahRange: "18:75-20:135", pageStart: 302, pageEnd: 321),
            Juz(id: 17, number: 17, surahRange: "21-22", ayahRange: "21:1-22:78", pageStart: 322, pageEnd: 341),
            Juz(id: 18, number: 18, surahRange: "23-25", ayahRange: "23:1-25:20", pageStart: 342, pageEnd: 361),
            Juz(id: 19, number: 19, surahRange: "25-27", ayahRange: "25:21-27:55", pageStart: 362, pageEnd: 381),
            Juz(id: 20, number: 20, surahRange: "27-29", ayahRange: "27:56-29:45", pageStart: 382, pageEnd: 401),
            Juz(id: 21, number: 21, surahRange: "29-33", ayahRange: "29:46-33:30", pageStart: 402, pageEnd: 421),
            Juz(id: 22, number: 22, surahRange: "33-36", ayahRange: "33:31-36:27", pageStart: 422, pageEnd: 441),
            Juz(id: 23, number: 23, surahRange: "36-39", ayahRange: "36:28-39:31", pageStart: 442, pageEnd: 461),
            Juz(id: 24, number: 24, surahRange: "39-41", ayahRange: "39:32-41:46", pageStart: 462, pageEnd: 481),
            Juz(id: 25, number: 25, surahRange: "41-45", ayahRange: "41:47-45:37", pageStart: 482, pageEnd: 501),
            Juz(id: 26, number: 26, surahRange: "46-51", ayahRange: "46:1-51:30", pageStart: 502, pageEnd: 521),
            Juz(id: 27, number: 27, surahRange: "51-57", ayahRange: "51:31-57:29", pageStart: 522, pageEnd: 541),
            Juz(id: 28, number: 28, surahRange: "58-66", ayahRange: "58:1-66:12", pageStart: 542, pageEnd: 561),
            Juz(id: 29, number: 29, surahRange: "67-77", ayahRange: "67:1-77:50", pageStart: 562, pageEnd: 581),
            Juz(id: 30, number: 30, surahRange: "78-114", ayahRange: "78:1-114:6", pageStart: 582, pageEnd: 604)
        ]
    }
    
    func getAyahsForSurah(_ surahId: Int) -> [Ayah] {
        let count = [7, 286, 200, 176, 120, 165, 206, 75, 129, 109][surahId % 10] + 10
        let pageStart = ((surahId - 1) * 3) + 1
        
        return (1...min(count, 50)).map { ayahNumber in
            let pageOffset = (ayahNumber - 1) / 15
            let pageNumber = pageStart + pageOffset
            
            return Ayah(
                id: "\(surahId):\(ayahNumber)",
                surahId: surahId,
                number: ayahNumber,
                arabicText: getAyahText(surahId: surahId, ayahNumber: ayahNumber),
                englishTranslation: getAyahTranslation(surahId: surahId, ayahNumber: ayahNumber),
                tafsir: getTafsir(surahId: surahId, ayahNumber: ayahNumber),
                pageNumber: min(pageNumber, 604)
            )
        }
    }
    
    func getAyahsForJuz(_ juzNumber: Int) -> [Ayah] {
        let juzList = getAllJuz()
        guard let targetJuz = juzList.first(where: { $0.number == juzNumber }) else { return [] }
        let surahs = getAllSurahs()
        let associatedSurah = surahs.first { $0.juzStart == juzNumber } ?? surahs[0]
        
        let count = 20
        return (1...count).map { ayahNumber in
            let pageNumber = targetJuz.pageStart + (ayahNumber - 1) / 15
            
            return Ayah(
                id: "\(associatedSurah.id):\(ayahNumber)",
                surahId: associatedSurah.id,
                number: ayahNumber,
                arabicText: "إِنَّ اللَّهَ مَعَ الصَّابِرِينَ",
                englishTranslation: "Indeed, Allah is with the patient.",
                tafsir: "This verse emphasizes the importance of patience in times of difficulty.",
                pageNumber: min(pageNumber, targetJuz.pageEnd)
            )
        }
    }
    
    private func getAyahText(surahId: Int, ayahNumber: Int) -> String {
        let texts = [
            "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
            "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
            "الرَّحْمَٰنِ الرَّحِيمِ",
            "مَالِكِ يَوْمِ الدِّينِ",
            "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
            "اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ",
            "صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ"
        ]
        return texts[ayahNumber % texts.count]
    }
    
    private func getAyahTranslation(surahId: Int, ayahNumber: Int) -> String {
        let translations = [
            "In the name of Allah, the Most Gracious, the Most Merciful.",
            "All praise is due to Allah, Lord of the worlds.",
            "The Most Gracious, the Most Merciful.",
            "Master of the Day of Judgment.",
            "You alone we worship and You alone we ask for help.",
            "Guide us to the straight path.",
            "The path of those upon whom You have bestowed favor, not of those who have evoked anger or of those who are astray."
        ]
        return translations[ayahNumber % translations.count]
    }
    
    private func getTafsir(surahId: Int, ayahNumber: Int) -> String? {
        let tafsirs = [
            "This verse emphasizes the importance of seeking Allah's guidance.",
            "A reminder of Allah's mercy and compassion towards His creation.",
            "This verse highlights the importance of patience and perseverance.",
            "A call to remember Allah in all circumstances.",
            "This verse teaches us to be grateful for Allah's blessings."
        ]
        return tafsirs[ayahNumber % tafsirs.count]
    }
    
    func performSearch(query: String, category: SearchCategory, filters: SearchFilter) -> [SearchResult] {
        var results: [SearchResult] = []
        let surahs = getAllSurahs()
        
        // Apply surah filters
        let filteredSurahs = filters.surahIds.isEmpty ? surahs : surahs.filter { filters.surahIds.contains($0.id) }
        
        // Apply juz filters
        let filteredJuz = filters.juzNumbers.isEmpty ? getAllJuz() : getAllJuz().filter { filters.juzNumbers.contains($0.number) }
        
        switch category {
        case .surah:
            // Search in surah names
            let searchedSurahs = filteredSurahs.filter { surah in
                query.isEmpty ||
                surah.name.localizedCaseInsensitiveContains(query) ||
                surah.englishName.localizedCaseInsensitiveContains(query) ||
                surah.arabicName.localizedCaseInsensitiveContains(query)
            }
            
            for surah in searchedSurahs.prefix(10) {
                let ayahs = getAyahsForSurah(surah.id)
                if let firstAyah = ayahs.first {
                    results.append(SearchResult(
                        surah: surah,
                        ayah: firstAyah,
                        matchedText: surah.name,
                        relevanceScore: 1.0,
                        pageNumber: surah.pageStart
                    ))
                }
            }
            
        case .juz:
            // Search in juz
            let searchedJuz = filteredJuz.filter { juz in
                query.isEmpty || "\(juz.number)".contains(query)
            }
            
            for juz in searchedJuz.prefix(10) {
                let ayahs = getAyahsForJuz(juz.number)
                if let firstAyah = ayahs.first,
                   let surah = surahs.first(where: { $0.id == firstAyah.surahId }) {
                    results.append(SearchResult(
                        surah: surah,
                        ayah: firstAyah,
                        matchedText: "Juz' \(juz.number)",
                        relevanceScore: 1.0,
                        pageNumber: juz.pageStart
                    ))
                }
            }
            
        case .ayah, .semantic:
            // Search in ayah text and translation
            for surah in filteredSurahs.prefix(10) {
                let ayahs = getAyahsForSurah(surah.id)
                for ayah in ayahs.prefix(5) {
                    if query.isEmpty ||
                       ayah.arabicText.localizedCaseInsensitiveContains(query) ||
                       ayah.englishTranslation.localizedCaseInsensitiveContains(query) {
                        results.append(SearchResult(
                            surah: surah,
                            ayah: ayah,
                            matchedText: ayah.arabicText,
                            relevanceScore: Double.random(in: 0.5...1.0),
                            pageNumber: ayah.pageNumber
                        ))
                    }
                }
            }
        }
        
        return results.sorted { $0.relevanceScore > $1.relevanceScore }
    }
}
