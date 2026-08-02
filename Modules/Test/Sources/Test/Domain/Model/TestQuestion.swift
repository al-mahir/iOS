//
//  TestQuestion.swift
//  Test
//
//  Created by Basmala Abuzied Ahmed on 31/07/2026.
//
import Foundation

struct TestQuestion: Identifiable, Equatable {
    let id = UUID()
    let index: Int
    let startWordId: Int
    let endWordId: Int
    let surah: Int
    let startAyah: Int
    let endAyah: Int

    var ayahCount: Int { endAyah - startAyah + 1 }
}
