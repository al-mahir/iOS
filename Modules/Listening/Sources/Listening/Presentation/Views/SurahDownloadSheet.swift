//
//  SurahDownloadSheet.swift
//  Listening
//

import SwiftUI
import Common

/// Sheet allowing user to choose specific Surahs to download for offline listening for a reciter.
public struct SurahDownloadSheet: View {

    public let reciter: Reciter
    @ObservedObject private var downloadManager: AudioDownloadManager = .shared
    @Environment(\.dsColors) private var dsColors
    @Environment(\.dismiss) private var dismiss

    @State private var searchText: String = ""
    @State private var surahToDelete: (number: Int, name: String)? = nil

    public init(reciter: Reciter) {
        self.reciter = reciter
    }

    // List of 114 Surahs metadata (Standard Quran Surah names)
    private static let surahList: [(number: Int, name: String, englishName: String)] = [
        (1, "الفاتحة", "Al-Fatihah"), (2, "البقرة", "Al-Baqarah"), (3, "آل عمران", "Ali 'Imran"),
        (4, "النساء", "An-Nisa"), (5, "المائدة", "Al-Ma'idah"), (6, "الأنعام", "Al-An'am"),
        (7, "الأعراف", "Al-A'raf"), (8, "الأنفال", "Al-Anfal"), (9, "التوبة", "At-Tawbah"),
        (10, "يونس", "Yunus"), (11, "هود", "Hud"), (12, "يوسف", "Yusuf"),
        (13, "الرعد", "Ar-Ra'd"), (14, "إبراهيم", "Ibrahim"), (15, "الحجر", "Al-Hijr"),
        (16, "النحل", "An-Nahl"), (17, "الإسراء", "Al-Isra"), (18, "الكهف", "Al-Kahf"),
        (19, "مريم", "Maryam"), (20, "طه", "Taha"), (21, "الأنبياء", "Al-Anbiya"),
        (22, "الحج", "Al-Hajj"), (23, "المؤمنون", "Al-Mu'minun"), (24, "النور", "An-Nur"),
        (25, "الفرقان", "Al-Furqan"), (26, "الشعراء", "Ash-Shu'ara"), (27, "النمل", "An-Naml"),
        (28, "القصص", "Al-Qasas"), (29, "العنكبوت", "Al-'Ankabut"), (30, "الروم", "Ar-Rum"),
        (31, "لقمان", "Luqman"), (32, "السجدة", "As-Sajdah"), (33, "الأحزاب", "Al-Ahzab"),
        (34, "سبإ", "Saba"), (35, "فاطر", "Fatir"), (36, "يس", "Ya-Sin"),
        (37, "الصافات", "As-Saffat"), (38, "ص", "Sad"), (39, "الزمر", "Az-Zumar"),
        (40, "غافر", "Ghafir"), (41, "فصلت", "Fussilat"), (42, "الشورى", "Ash-Shura"),
        (43, "الزخرف", "Az-Zukhruf"), (44, "الدخان", "Ad-Dukhan"), (45, "الجاثية", "Al-Jathiyah"),
        (46, "الأحقاف", "Al-Ahqaf"), (47, "محمد", "Muhammad"), (48, "الفتح", "Al-Fath"),
        (49, "الحجرات", "Al-Hujurat"), (50, "ق", "Qaf"), (51, "الذاريات", "Adh-Dhariyat"),
        (52, "الطور", "At-Tur"), (53, "النجم", "An-Najm"), (54, "القمر", "Al-Qamar"),
        (55, "الرحمن", "Ar-Rahman"), (56, "الواقعة", "Al-Waqi'ah"), (57, "الحديد", "Al-Hadid"),
        (58, "المجادلة", "Al-Mujadila"), (59, "الحشر", "Al-Hashr"), (60, "الممتحنة", "Al-Mumtahanah"),
        (61, "الصف", "As-Saff"), (62, "الجمعة", "Al-Jumu'ah"), (63, "المنافقون", "Al-Munafiqun"),
        (64, "التغابن", "At-Taghabun"), (65, "الطلاق", "At-Talaq"), (66, "التحريم", "At-Tahrim"),
        (67, "الملك", "Al-Mulk"), (68, "القلم", "Al-Qalam"), (69, "الحاقة", "Al-Haqqah"),
        (70, "المعارج", "Al-Ma'arij"), (71, "نوح", "Nuh"), (72, "الجن", "Al-Jinn"),
        (73, "المزمل", "Al-Muzzammil"), (74, "المدثر", "Al-Muddaththir"), (75, "القيامة", "Al-Qiyamah"),
        (76, "الإنسان", "Al-Insan"), (77, "المرسلات", "Al-Mursalat"), (78, "النبإ", "An-Naba"),
        (79, "النازعات", "An-Nazi'at"), (80, "عبس", "'Abasa"), (81, "التكوير", "At-Takwir"),
        (82, "الانفطار", "Al-Infitar"), (83, "المطففين", "Al-Mutaffifin"), (84, "الانشقاق", "Al-Inshiqaq"),
        (85, "البروج", "Al-Buruj"), (86, "الطارق", "At-Tariq"), (87, "الأعلى", "Al-A'la"),
        (88, "الغاشية", "Al-Ghashiyah"), (89, "الفجر", "Al-Fajr"), (90, "البلد", "Al-Balad"),
        (91, "الشمس", "Ash-Shams"), (92, "الليل", "Al-Layl"), (93, "الضحى", "Ad-Duha"),
        (94, "الشرح", "Ash-Sharh"), (95, "التين", "At-Tin"), (96, "العلق", "Al-'Alaq"),
        (97, "القدر", "Al-Qadr"), (98, "البينة", "Al-Bayyinah"), (99, "الزلزلة", "Az-Zalzalah"),
        (100, "العاديات", "Al-'Adiyat"), (101, "القارعة", "Al-Qari'ah"), (102, "التكاثر", "At-Takathur"),
        (103, "العصر", "Al-'Asr"), (104, "الهمزة", "Al-Humazah"), (105, "الفيل", "Al-Fil"),
        (106, "قريش", "Quraysh"), (107, "الماعون", "Al-Ma'un"), (108, "الكوثر", "Al-Kawthar"),
        (109, "الكافرون", "Al-Kafirun"), (110, "النصر", "An-Nasr"), (111, "المسد", "Al-Masad"),
        (112, "الإخلاص", "Al-Ikhlas"), (113, "الفلق", "Al-Falaq"), (114, "الناس", "An-Nas")
    ]

    private var filteredSurahs: [(number: Int, name: String, englishName: String)] {
        if searchText.isEmpty { return Self.surahList }
        return Self.surahList.filter {
            $0.englishName.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            "\($0.number)".contains(searchText)
        }
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                dsColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    headerCard
                    searchBar
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.sm)

                    ScrollView {
                        LazyVStack(spacing: DSSpacing.xs) {
                            ForEach(filteredSurahs, id: \.number) { item in
                                surahRow(item)
                            }
                        }
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.bottom, DSSpacing.xl)
                    }
                }
            }
            .navigationTitle(Text("Download Surahs", bundle: CommonBundle.bundle))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done", bundle: CommonBundle.bundle)) { dismiss() }
                        .dsFont(DSTypography.labelLarge)
                        .foregroundColor(dsColors.primary)
                }
            }
            .alert(
                Text("Delete Surah", bundle: CommonBundle.bundle),
                isPresented: Binding(
                    get: { surahToDelete != nil },
                    set: { if !$0 { surahToDelete = nil } }
                )
            ) {
                if let item = surahToDelete {
                    Button(String(localized: "Cancel", bundle: CommonBundle.bundle), role: .cancel) {
                        surahToDelete = nil
                    }
                    Button(String(localized: "Delete", bundle: CommonBundle.bundle), role: .destructive) {
                        downloadManager.deleteDownload(reciterId: reciter.id, surahNumber: item.number)
                        surahToDelete = nil
                    }
                }
            } message: {
                if let item = surahToDelete {
                    Text(String(format: String(localized: "Are you sure you want to delete %@ offline recording?", bundle: CommonBundle.bundle), item.name))
                }
            }
        }
    }

    // MARK: - Header Card

    private var headerCard: some View {
        HStack(spacing: DSSpacing.md) {
            ZStack {
                Circle()
                    .fill(dsColors.primaryContainer)
                    .frame(width: 48, height: 48)
                Text(String(reciter.localizedName.prefix(1)))
                    .dsFont(DSTypography.headlineSmall)
                    .foregroundColor(dsColors.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(reciter.localizedName)
                    .dsFont(DSTypography.titleMedium)
                    .foregroundColor(dsColors.textPrimary)

                let reciterDownloads = downloadManager.downloads.filter { $0.reciterId == reciter.id }
                Text(String(format: String(localized: "%d / 114 Surahs downloaded", bundle: CommonBundle.bundle), reciterDownloads.count))
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            Button(action: downloadAllSurahs) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 14))
                    Text("Download All", bundle: CommonBundle.bundle)
                        .dsFont(DSTypography.labelMedium)
                }
                .padding(.horizontal, DSSpacing.smMd)
                .padding(.vertical, DSSpacing.xs)
                .background(dsColors.primary, in: Capsule())
                .foregroundColor(dsColors.onPrimary)
            }
        }
        .padding(DSSpacing.md)
        .background(dsColors.surfaceContainerLowest)
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: DSSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(dsColors.textHint)
            TextField(String(localized: "Search surah name or number…", bundle: CommonBundle.bundle), text: $searchText)
                .dsFont(DSTypography.bodyMedium)
                .foregroundColor(dsColors.textPrimary)
        }
        .padding(DSSpacing.smMd)
        .background(dsColors.surfaceContainerHigh, in: RoundedRectangle(cornerRadius: DSRadius.md))
    }

    // MARK: - Surah Row

    private func surahRow(_ item: (number: Int, name: String, englishName: String)) -> some View {
        let isDownloaded = downloadManager.isSurahDownloaded(reciterId: reciter.id, surahNumber: item.number)
        let key = "\(reciter.id)_\(item.number)"
        let progress = downloadManager.activeDownloads[key]

        let isArabic = AppLanguage.isArabicActive
        let primaryName = isArabic ? item.name : item.englishName
        let secondaryName = isArabic ? item.englishName : item.name

        return HStack(spacing: DSSpacing.smMd) {
            // Surah Number Badge
            ZStack {
                RoundedRectangle(cornerRadius: DSRadius.sm)
                    .fill(isDownloaded ? dsColors.primaryContainer.opacity(0.4) : dsColors.surfaceContainerHigh)
                    .frame(width: 36, height: 36)
                Text("\(item.number)")
                    .dsFont(DSTypography.labelLarge)
                    .foregroundColor(isDownloaded ? dsColors.primary : dsColors.textSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(primaryName)
                    .dsFont(DSTypography.titleSmall)
                    .foregroundColor(dsColors.textPrimary)

                Text(secondaryName)
                    .dsFont(DSTypography.bodySmall)
                    .foregroundColor(dsColors.textSecondary)
            }

            Spacer()

            if isDownloaded {
                HStack(spacing: DSSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(dsColors.primary)
                        .font(.system(size: 18))

                    Button(action: {
                        surahToDelete = (item.number, primaryName)
                    }) {
                        Image(systemName: "trash")
                            .font(.system(size: 14))
                            .foregroundColor(dsColors.error)
                            .padding(6)
                    }
                }
            } else if let p = progress {
                VStack(spacing: 2) {
                    ProgressView(value: p)
                        .progressViewStyle(.linear)
                        .frame(width: 60)
                        .tint(dsColors.primary)
                    Text("\(Int(p * 100))%")
                        .dsFont(DSTypography.labelSmall)
                        .foregroundColor(dsColors.textHint)
                }
            } else {
                Button(action: {
                    downloadManager.downloadSurah(reciter: reciter, surahNumber: item.number, surahName: item.englishName)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 16))
                        Text("Download", bundle: CommonBundle.bundle)
                            .dsFont(DSTypography.labelSmall)
                    }
                    .foregroundColor(dsColors.primary)
                    .padding(.horizontal, DSSpacing.sm)
                    .padding(.vertical, 6)
                    .background(dsColors.primaryContainer.opacity(0.3), in: Capsule())
                }
            }
        }
        .padding(.horizontal, DSSpacing.md)
        .padding(.vertical, DSSpacing.smMd)
        .background(dsColors.surfaceContainerLowest, in: RoundedRectangle(cornerRadius: DSRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg)
                .stroke(dsColors.outlineVariant.opacity(0.3), lineWidth: 1)
        )
    }

    private func downloadAllSurahs() {
        for item in Self.surahList {
            if !downloadManager.isSurahDownloaded(reciterId: reciter.id, surahNumber: item.number) {
                downloadManager.downloadSurah(reciter: reciter, surahNumber: item.number, surahName: item.englishName)
            }
        }
    }
}
