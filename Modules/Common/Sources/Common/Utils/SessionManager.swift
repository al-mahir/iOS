//
//  SessionManager.swift
//  Common
//
//  Created for Session Management.
//

import Foundation
import Combine

@MainActor
public final class SessionManager: ObservableObject {
    public static let shared = SessionManager()
    
    @Published public private(set) var currentUser: SessionUser?
    
    private let defaults: UserDefaults
    private let userKey = "SessionManager.currentUser"
    
    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.currentUser = loadUser()
    }
    
    public func save(user: SessionUser) {
        self.currentUser = user
        if let encoded = try? JSONEncoder().encode(user) {
            defaults.set(encoded, forKey: userKey)
        }
    }
    
    public func clear() {
        self.currentUser = nil
        defaults.removeObject(forKey: userKey)
    }
    
    private func loadUser() -> SessionUser? {
        guard let data = defaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(SessionUser.self, from: data) else {
            return nil
        }
        return user
    }
}
