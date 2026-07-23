//
//  PageBookmarkDAO.swift
//  Bookmarks (Data)
//

import Foundation
import SwiftData
import LocalDataKit

protocol PageBookmarkDAOProtocol {
    func fetchAll(forUserID userID: String) throws -> [PageBookmarkEntity]
    func fetchOne(id: String) throws -> PageBookmarkEntity?
    func insert(_ entity: PageBookmarkEntity) throws
    func delete(id: String) throws
}

final class PageBookmarkDAO: PageBookmarkDAOProtocol {
    private let dataService: SwiftDataService

    init(dataService: SwiftDataService) {
        self.dataService = dataService
    }

    func fetchAll(forUserID userID: String) throws -> [PageBookmarkEntity] {
        let predicate = #Predicate<PageBookmarkEntity> { $0.userID == userID }
        return try dataService.fetch(predicate: predicate)
    }

    func fetchOne(id: String) throws -> PageBookmarkEntity? {
        let predicate = #Predicate<PageBookmarkEntity> { $0.id == id }
        return try dataService.fetch(predicate: predicate).first
    }

    func insert(_ entity: PageBookmarkEntity) throws {
        try dataService.insert(entity)
    }

    func delete(id: String) throws {
        guard let entity = try fetchOne(id: id) else { return }
        try dataService.delete(entity)
    }
}
