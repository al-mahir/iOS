//
//  Juz.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//


struct Juz: Identifiable, Codable, Hashable {
    let id: Int
    let number: Int
    let surahRange: String
    let ayahRange: String
    let pageStart: Int
    let pageEnd: Int
}