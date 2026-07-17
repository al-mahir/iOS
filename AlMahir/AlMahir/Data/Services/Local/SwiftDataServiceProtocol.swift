//
//  SwiftDataServiceProtocol.swift
//  AlMahir
//
//  Created by Basmala Abuzied Ahmed on 17/07/2026.
//


import Foundation
import SwiftData

protocol SwiftDataServiceProtocol {
    func fetchAll<T: PersistentModel>() throws -> [T]
    func insert<T: PersistentModel>(_ item: T) throws
    func delete<T: PersistentModel>(_ item: T) throws
    func save() throws
}
