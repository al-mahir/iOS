//
//  SheikhEnvironment.swift
//  Sheikh
//
//  Created by Nadin Ahmed on 23/07/2026.
//
import Foundation

public enum SheikhEnvironment {

    public static var useMock: Bool = true

    static func makeRepository() -> any SheikhRepositoryProtocol {
        useMock ? SheikhMockRepository() : SheikhRepositoryImpl()
    }
}
