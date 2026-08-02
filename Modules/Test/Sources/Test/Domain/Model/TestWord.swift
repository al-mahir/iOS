//
//  TestWord.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//
import Foundation

struct TestWord: Equatable {
    let id: Int
    let surah: Int
    let ayah: Int
    let wordPosition: Int
    let text: String

    var isVerseNumberMarker: Bool { wordPosition == 0 }
}
