//
//  CurrentUserProvider.swift
//  Bookmarks (Services)
//

import Foundation
import Authentication

/// Every bookmark row is tagged with this key. Signed-in users get a stable key
/// derived from their account; signed-out users get a random ID generated once
/// and persisted in UserDefaults, so their bookmarks survive relaunches even
/// before they ever log in.
///
/// NOTE: if a guest later logs in, their guest-scoped bookmarks stay under the
/// guest key and won't automatically appear under the account key — merging
/// guest data into an account on login is separate work, not implemented here.
enum CurrentUserProvider {
    private static let guestIDDefaultsKey = "com.almahir.bookmarks.guestID"

    @MainActor
    static var userID: String {
        switch AuthManager.shared.currentAuthState {
        case .authenticated(let user):
            return "user_\(user.id)"
        default:
            return guestID
        }
    }

    private static var guestID: String {
        let defaults = UserDefaults.standard
        if let existing = defaults.string(forKey: guestIDDefaultsKey) {
            return existing
        }
        let newID = "guest_\(UUID().uuidString)"
        defaults.set(newID, forKey: guestIDDefaultsKey)
        return newID
    }
}
