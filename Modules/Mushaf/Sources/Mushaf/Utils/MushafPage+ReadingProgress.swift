//
//  MushafPage+ReadingProgress.swift
//  Mushaf
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

//
//  MushafPage+ReadingProgress.swift
//  Mushaf
//
//  Call ReadingProgressStore.shared.save(page.toReadingProgress()) wherever
//  your ViewModel finishes loading a page (e.g. at the end of loadPage /
//  loadPageIfNeeded, right after `pages[number] = page`). That's the one
//  integration point needed to make "last read" persist for real.
//

import Common

extension MushafPage {
    /// Builds a snapshot from this page's first ayah line, for persisting
    /// "last read" position. Returns nil only for a pathological page with
    /// no ayah content (shouldn't happen for any real mushaf page).
    func toReadingProgress() -> ReadingProgress? {
        guard
            let firstAyahLine = lines.first(where: { $0.lineType == .ayah && !$0.words.isEmpty }),
            let firstWord = firstAyahLine.words.first
        else { return nil }

        let surahNumber = firstWord.surah
        let ayahNumber = firstWord.ayah
        // Rough estimate: 604 pages ≈ 30 juz (~20.13 pages/juz). Swap for an
        // exact page->juz lookup table later if you want precision here.
        let juzNumber = min(30, max(1, Int((Double(id) / 604.0 * 30).rounded(.up))))

        return ReadingProgress(
            surahName: SurahNames.name(for: surahNumber),
            surahNumber: surahNumber,
            pageNumber: id,
            ayahNumber: ayahNumber,
            juzNumber: juzNumber
        )
    }
}
