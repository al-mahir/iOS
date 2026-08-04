//
//  QuranWord.swift
//  Common
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
}
