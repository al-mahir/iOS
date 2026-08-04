//
//  QuranDataProviderProtocol.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 04/08/2026.
//


import Foundation

protocol QuranDataProviderProtocol {
    var allSurahs: [Surah] { get }
    func surah(for id: Int) -> Surah?
}

final class QuranDataProvider: QuranDataProviderProtocol {
    static let shared = QuranDataProvider()
    private init() {}

    var allSurahs: [Surah] {
        MockDataService.shared.getAllSurahs()
    }

    func surah(for id: Int) -> Surah? {
        allSurahs.first { $0.id == id }
    }
}
