//
//  AlMahirApp.swift
//  AlMahir
//
//  Created by Esraa Ehab on 16/07/2026.
//

import Authentication
import Mushaf
import Settings
import Search
import SwiftData
import Profile
import SwiftUI
import FirebaseCore

@main
struct AlMahirApp: App {
    init() {
        FirebaseApp.configure()
        AuthManager.configureInterceptor()

        let schema = Schema([])
        do {
            try SwiftDataService.shared.setup(schema: schema)
        } catch {
            print("Failed to setup SwiftData: \(error)")
        }
    }
    
    private let diContainer = AppDIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            // if let profileCoordinator = diContainer.resolve(ProfileCoordinatorView.self) {
            //     profileCoordinator
            // } else {
            //     Text("Error Loading Profile Module")
            //         .foregroundColor(.red)
            // }

//            AppRootView()
           // MushafRootView()
            MainTabView()
        }
    }
}

struct AppRootView: View {
    @StateObject private var authManager = AuthManager.shared

    var body: some View {
        Group {
            switch authManager.authState {
            
            case .bootstrapping:
                VStack(spacing: 16) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.green)
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .guest:
                LoginView()

            case .authenticated:
                MainTabView()
                    .dsTheme()

            case .sessionExpired:
                LoginView()
                    .overlay(alignment: .top) {
                        sessionExpiredBanner
                    }
            }
        }
        .onAppear {
            authManager.silentLoginOnLaunch()
        }
    }

    private var sessionExpiredBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.badge.exclamationmark.fill")
                .foregroundStyle(.orange)
            Text("Your session expired. Please sign in again.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.orange)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .padding(.top, 8)
    }
}
