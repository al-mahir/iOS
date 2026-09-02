//
//  RepositoryAssembly.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 20/07/2026.
//

import Swinject
import Foundation
import NetworkKit

final class RepositoryAssembly: Assembly {
   func assemble(container: Container) {

       container.register(SearchRepository.self) { r in
           guard let localDataSource = r.resolve(MushafSearchLocalDataSource?.self) ?? nil else {
               return UnavailableSearchRepository()
           }
           return SearchRepositoryImpl(localDataSource: localDataSource)
       }.inObjectScope(.container)

      
       container.register(TafsirRemoteDataSource.self) { _ in
           TafsirRemoteDataSourceImpl()
       }.inObjectScope(.container)

       container.register(TafsirRepositoryProtocol.self) { r in
           TafsirRepositoryImpl(
               remoteDataSource: r.resolve(TafsirRemoteDataSource.self)!
           )
       }.inObjectScope(.container)
   }
}

private struct UnavailableSearchRepository: SearchRepository {
   struct UnavailableError: LocalizedError {
       var errorDescription: String? {
           "Search isn't set up yet. Check that search-index.db is added to the app target."
       }
   }

   func searchAyahs(query: String) throws -> [SearchResult] {
       throw UnavailableError()
   }
}

