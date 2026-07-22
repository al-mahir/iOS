//
//  SwiftDataService.swift
//  AlMahir
//
//  Created by Basmala Abuzied Ahmed on 17/07/2026.
//

import SwiftData
import Foundation

public class SwiftDataService: SwiftDataServiceProtocol {
    @MainActor public static let shared = SwiftDataService()
    
    private var container: ModelContainer?
    private var context: ModelContext?
    
    private init() {}
    
    @MainActor public func setup(schema: Schema) throws {
        do {
            self.container = try ModelContainer(for: schema)
            self.context = self.container?.mainContext
        } catch {
            throw SwiftDataError.initializationFailed(error)
        }
    }
    
    public func fetchAll<T: PersistentModel>() throws -> [T] {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        let descriptor = FetchDescriptor<T>()
        return try context.fetch(descriptor)
    }
    
    public func insert<T: PersistentModel>(_ item: T) throws {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        context.insert(item)
        try save()
    }
    
    public func delete<T: PersistentModel>(_ item: T) throws {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        context.delete(item)
        try save()
    }
    
    public func save() throws {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        if context.hasChanges {
            try context.save()
        }
    }
}

// Extension methods used across modules should also be public
public extension SwiftDataService {
    
    func fetchAll<T: PersistentModel>(sortBy: SortDescriptor<T>...) throws -> [T] {
        var descriptor = FetchDescriptor<T>()
        descriptor.sortBy = sortBy
        return try fetchAll(with: descriptor)
    }
    
    func fetchAll<T: PersistentModel>(with descriptor: FetchDescriptor<T>) throws -> [T] {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        return try context.fetch(descriptor)
    }
    
    func fetch<T: PersistentModel>(predicate: Predicate<T>?) throws -> [T] {
        guard let context = context else {
            throw SwiftDataError.containerNotInitialized
        }
        var descriptor = FetchDescriptor<T>()
        descriptor.predicate = predicate
        return try context.fetch(descriptor)
    }
    
    func deleteAll<T: PersistentModel>(_ type: T.Type) throws {
        let items: [T] = try fetchAll()
        for item in items {
            try delete(item)
        }
    }
}
