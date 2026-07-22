//
//  SheikhBookmarkDAO.swift
//  Bookmarks (Data)
//

import Foundation
import SwiftData
import LocalDataKit
protocol SheikhBookmarkDAOProtocol {
    func fetchAll(forUserID userID: String) throws -> [SheikhBookmarkEntity]
    func fetchOne(id: String) throws -> SheikhBookmarkEntity?
    func insert(_ entity: SheikhBookmarkEntity) throws
    func delete(id: String) throws
}

final class SheikhBookmarkDAO: SheikhBookmarkDAOProtocol {
    private let dataService: SwiftDataService

    init(dataService: SwiftDataService = .shared) {
        self.dataService = dataService
    }

    func fetchAll(forUserID userID: String) throws -> [SheikhBookmarkEntity] {
        let predicate = #Predicate<SheikhBookmarkEntity> { $0.userID == userID }
        return try dataService.fetch(predicate: predicate)
    }

    func fetchOne(id: String) throws -> SheikhBookmarkEntity? {
        let predicate = #Predicate<SheikhBookmarkEntity> { $0.id == id }
        return try dataService.fetch(predicate: predicate).first
    }

    func insert(_ entity: SheikhBookmarkEntity) throws {
        try dataService.insert(entity)
    }

    func delete(id: String) throws {
        guard let entity = try fetchOne(id: id) else { return }
        try dataService.delete(entity)
    }
}
