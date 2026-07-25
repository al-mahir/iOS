//
//  QuranSearchRepository.swift
//  Reading
//
//  Created by Basmala Abuzied Ahmed on 23/07/2026.
//

protocol QuranSearchRepository {
    func fetchSearchWord(id: Int) -> (normalized: String, display: String)?
}
