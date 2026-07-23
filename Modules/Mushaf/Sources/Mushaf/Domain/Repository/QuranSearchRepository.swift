//
//  QuranSearchRepository.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 23/07/2026.
//


// Domain / Business Logic Layer
protocol QuranSearchRepository {
    func fetchSearchWord(id: Int) -> (normalized: String, display: String)?
}