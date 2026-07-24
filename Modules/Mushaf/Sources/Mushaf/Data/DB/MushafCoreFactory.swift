//
//  MushafCoreFactory.swift
//  Mushaf
//
//  Created by Basmala Abuzied Ahmed on 24/07/2026.
//


public enum MushafCoreFactory {
    public static func makeMushafPageUseCase(dbManager: MushafDatabaseManager) -> GetMushafPageUseCase {
        let localDataSource = MushafLocalDataSourceImpl(
            wordsDAO: WordsDAO(db: dbManager.wordsDB),
            pagesDAO: PagesDAO(db: dbManager.layoutDB)
        )
        let repository = MushafRepositoryImpl(localDataSource: localDataSource)
        return GetMushafPageUseCaseImpl(repository: repository)
    }
}
