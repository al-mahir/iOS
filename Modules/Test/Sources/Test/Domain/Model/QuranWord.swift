//
//  QuranWord.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//




import Foundation

struct QuranWord: Identifiable, Hashable {
    let id: Int
    let surah: Int
    let ayah: Int
    let wordPosition: Int
    let text: String
}
