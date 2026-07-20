//
//  AlMahirApp.swift
//  AlMahir
//
//  Created by Esraa Ehab on 16/07/2026.
//

import SwiftUI
import Mushaf
import Settings
import Search
import SwiftData
import Profile
@main
struct AlMahirApp: App {
    init() {
        let schema = Schema([])
        do {
            try SwiftDataService.shared.setup(schema: schema)
        } catch {
            print("Failed to setup SwiftData: \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
            //MushafRootView()
            SearchView()
        }
    }
}
