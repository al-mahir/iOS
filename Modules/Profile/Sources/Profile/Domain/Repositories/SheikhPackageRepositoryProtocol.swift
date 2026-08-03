//
//  SheikhPackageRepositoryProtocol.swift
//  Profile
//
//  Created by Basmala Abuzied Ahmed on 30/07/2026.
//


public protocol SheikhPackageRepositoryProtocol {
    func fetchMySubscriptions() async throws -> [SheikhPackageSubscription]
    func cancelSubscription(id: String) async throws
}
