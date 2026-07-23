//
//  SurahBookmarkDAO.swift
//  Bookmarks (Data)
//

import Foundation
import SwiftData
import LocalDataKit
/// Lowest layer: raw persistence on SurahBookmarkEntity, nothing else. Doesn't
/// know what "current user" means — the caller (LocalDataSource) decides which
/// userID to filter by.
///
/// NOTE: typed against the concrete `SwiftDataService`, not `SwiftDataServiceProtocol` —
/// `fetch(predicate:)` is declared in the extension on the concrete class, not on
/// the protocol. Add it to SwiftDataServiceProtocol if you want this mockable.
protocol SurahBookmarkDAOProtocol {
    func fetchAll(forUserID userID: String) throws -> [SurahBookmarkEntity]
    func fetchOne(id: String) throws -> SurahBookmarkEntity?
    func insert(_ entity: SurahBookmarkEntity) throws
    func delete(id: String) throws
}

final class SurahBookmarkDAO: SurahBookmarkDAOProtocol {
    private let dataService: SwiftDataService

    init(dataService: SwiftDataService) {
        self.dataService = dataService
    }

    func fetchAll(forUserID userID: String) throws -> [SurahBookmarkEntity] {
        let predicate = #Predicate<SurahBookmarkEntity> { $0.userID == userID }
        return try dataService.fetch(predicate: predicate)
    }

    func fetchOne(id: String) throws -> SurahBookmarkEntity? {
        let predicate = #Predicate<SurahBookmarkEntity> { $0.id == id }
        return try dataService.fetch(predicate: predicate).first
    }

    func insert(_ entity: SurahBookmarkEntity) throws {
        try dataService.insert(entity)
    }

    func delete(id: String) throws {
        guard let entity = try fetchOne(id: id) else { return }
        try dataService.delete(entity)
    }
}
