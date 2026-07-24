//
//  AlMahirApp.swift
//  AlMahir
//
//  Created by Esraa Ehab on 16/07/2026.
//
import Authentication
import GoogleSignIn
import Mushaf
import Search
import SwiftData
import SwiftUI
import Bookmarks
import Common
import LocalDataKit

@main
struct AlMahirApp: App {

    init() {
        AuthManager.configureInterceptor()
        MainActor.assumeIsolated { setupSwiftData() }
        MushafFontManager.shared.registerFonts()
    }

    @MainActor private func setupSwiftData() {
        let schema = Schema([
            PageBookmarkEntity.self,
            AyahBookmarkEntity.self,
            SurahBookmarkEntity.self,
            SheikhBookmarkEntity.self,
        ])
        do {
            try SwiftDataService.shared.setup(schema: schema)
        } catch {
            assertionFailure("SwiftData setup failed: \(error)")
        }
    }
    var body: some Scene {
        WindowGroup {
  //          AppRootView()
 //               .onOpenURL { url in
  //                  GIDSignIn.sharedInstance.handle(url)
  //              }
 //           SearchView()
            MainTabView()
                .dsTheme()
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
