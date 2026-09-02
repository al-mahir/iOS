//
//  MushafRepository.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation


protocol MushafRepository {
    func fetchPage(_ pageNumber: Int) throws -> MushafPage
}
