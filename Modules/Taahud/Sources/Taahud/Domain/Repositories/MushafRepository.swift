//
//  MushafRepository.swift
//  Taahud

import Foundation
public protocol MushafRepository {

    func fetchPage(pageNumber: Int) async throws -> MushafPageData

    func pageNumber(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> Int

    func word(forSura sura: Int, aya: Int, wordIdx: Int) async throws -> AyahWord?
}
