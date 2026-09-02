//
//  AyahBookmarkDAO.swift
//  Bookmarks (Data)
//

import Foundation
import SwiftData
import LocalDataKit

protocol AyahBookmarkDAOProtocol {
    func fetchAll(forUserID userID: String) throws -> [AyahBookmarkEntity]
    func fetchOne(id: String) throws -> AyahBookmarkEntity?
    func insert(_ entity: AyahBookmarkEntity) throws
    func delete(id: String) throws
}

final class AyahBookmarkDAO: AyahBookmarkDAOProtocol {
    private let dataService: SwiftDataService
    
    
    init(dataService: SwiftDataService) {
            self.dataService = dataService
        }

    func fetchAll(forUserID userID: String) throws -> [AyahBookmarkEntity] {
        let predicate = #Predicate<AyahBookmarkEntity> { $0.userID == userID }
        return try dataService.fetch(predicate: predicate)
    }

    func fetchOne(id: String) throws -> AyahBookmarkEntity? {
        let predicate = #Predicate<AyahBookmarkEntity> { $0.id == id }
        return try dataService.fetch(predicate: predicate).first
    }

    func insert(_ entity: AyahBookmarkEntity) throws {
        try dataService.insert(entity)
    }

    func delete(id: String) throws {
        guard let entity = try fetchOne(id: id) else { return }
        try dataService.delete(entity)
    }
}
