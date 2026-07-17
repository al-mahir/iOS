//
//  MushafLocalDataSource.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//


import Foundation

protocol MushafLocalDataSource {
    func layoutLines(forPage pageNumber: Int) throws -> [PageLineRow]
    func words(fromId: Int, toId: Int) throws -> [WordRow]
}

final class MushafLocalDataSourceImpl: MushafLocalDataSource {
    private let wordsDAO: WordsDAO
    private let pagesDAO: PagesDAO

    init(wordsDAO: WordsDAO, pagesDAO: PagesDAO) {
        self.wordsDAO = wordsDAO
        self.pagesDAO = pagesDAO
    }

    func layoutLines(forPage pageNumber: Int) throws -> [PageLineRow] {
        try pagesDAO.fetchLines(forPage: pageNumber)
    }

    func words(fromId: Int, toId: Int) throws -> [WordRow] {
        try wordsDAO.fetchWords(fromId: fromId, toId: toId)
    }
}
