//
//  SwiftDataError.swift
//  AlMahir
//
//  Created by Basmala Abuzied Ahmed on 17/07/2026.
//


enum SwiftDataError: Error {
    case containerNotInitialized
    case initializationFailed(Error)
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
}