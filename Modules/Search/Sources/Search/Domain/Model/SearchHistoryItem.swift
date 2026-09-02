//
//  SearchHistoryItem.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 19/07/2026.
//

import Foundation
struct SearchHistoryItem: Identifiable, Codable, Hashable {
    var id: String {
        "\(category.rawValue)_\(query.lowercased())"
    }
    let query: String
    let timestamp: TimeInterval
    let category: SearchCategory
    
    var date: Date {
        Date(timeIntervalSince1970: timestamp)
    }
    
    init(query: String, category: SearchCategory) {
        self.query = query
        self.timestamp = Date().timeIntervalSince1970
        self.category = category
    }
    
    init(query: String, timestamp: TimeInterval, category: SearchCategory) {
        self.query = query
        self.timestamp = timestamp
        self.category = category
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchHistoryItem, rhs: SearchHistoryItem) -> Bool {
        lhs.id == rhs.id
    }
}
