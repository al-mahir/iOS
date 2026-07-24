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
        guard let firstWord = lines.flatMap(\.words).first else { return nil }

        let surahNumber = firstWord.surah
        let ayahNumber = firstWord.ayah
        let juzNumber = JuzPageMap.juzNumber(forPage: id)

        return ReadingProgress(
            surahName: SurahNames.name(for: surahNumber),
            surahNumber: surahNumber,
            pageNumber: id,
            ayahNumber: ayahNumber,
            juzNumber: juzNumber
        )
    }
}
