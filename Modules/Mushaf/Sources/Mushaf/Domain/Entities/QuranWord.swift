//
//  QuranWord.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//




import Foundation

public struct QuranWord: Identifiable, Hashable {
    public let id: Int
    public let surah: Int
    public let ayah: Int
    public let wordPosition: Int
    public let text: String
    
    public init(id: Int, surah: Int, ayah: Int, wordPosition: Int, text: String) {
            self.id = id; self.surah = surah; self.ayah = ayah
            self.wordPosition = wordPosition; self.text = text
        }
}
