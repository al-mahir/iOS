//
//  AlMahirApp.swift
//  AlMahir
//
//  Created by Esraa Ehab on 16/07/2026.
//

import Authentication
import Mushaf
import SwiftData
import SwiftUI

@main
struct AlMahirApp: App {
    init() {
        AuthManager.configureInterceptor()

        let schema = Schema([])
        do {
            try SwiftDataService.shared.setup(schema: schema)
        } catch {
            print("Failed to setup SwiftData: \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
            AppRootView()
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
                MushafRootView()

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
