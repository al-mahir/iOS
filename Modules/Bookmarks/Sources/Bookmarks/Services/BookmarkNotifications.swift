//
//  BookmarkNotifications.swift
//  Bookmarks (Services)
//
//  Shared notification names that allow other modules (e.g. Mushaf) to signal
//  that bookmarks have been mutated, so the Bookmarks tab can refresh itself.
//

import Foundation

public extension Notification.Name {
    /// Posted whenever any bookmark (page, ayah, surah, or sheikh) is added or
    /// removed. Any observer — typically `BookmarksViewModel` — should reload
    /// its data when it receives this notification.
    static let bookmarkDidChange = Notification.Name("com.almahir.bookmark.didChange")
}
