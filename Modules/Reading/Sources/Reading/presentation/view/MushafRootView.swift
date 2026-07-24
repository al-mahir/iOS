////
////  MushafRootView.swift
//  Reading
////
//
//import SwiftUI
//
//public struct MushafRootView: View {
//    @State private var fontsReady = false
//    @State private var viewModel: MushafViewModel?
//    @StateObject private var qraaManager: QraaManager
//
//    private let startPage: Int
//
//    public init(startPage: Int = 1) {
//        self.startPage = startPage
//
//        // Use the DI container to resolve the repository
//        let searchRepo: QuranSearchRepository?
//        
//        // Try to resolve the repository from DI
//        do {
//            // Try the non-optional first
//            searchRepo = DIContainer.shared.resolve(QuranSearchRepository.self)
//            print("✅ [MushafRootView] Repository resolved from DI")
//        } catch {
//            print("❌ [MushafRootView] Failed to resolve from DI: \(error)")
//            
//            // Fallback: Create it directly
//            do {
//                let dbManager = try MushafDatabaseManager()
//                searchRepo = SearchIndexDAO(db: dbManager.searchDB)
//                print("✅ [MushafRootView] Repository created directly as fallback")
//            } catch {
//                print("❌ [MushafRootView] Failed to create repository: \(error)")
//                searchRepo = nil
//            }
//        }
//        
//        // Initialize QraaManager with the repository
//        _qraaManager = StateObject(wrappedValue: QraaManager(searchRepository: searchRepo))
//    }
//
//    public var body: some View {
//        Group {
//            if fontsReady, let viewModel = viewModel {
//                MushafView(viewModel: viewModel, qraaManager: qraaManager)
//            } else {
//                ProgressView("Loading fonts…")
//            }
//        }
//        .onAppear {
//            if viewModel == nil {
//                let useCase = DIContainer.shared.resolve(GetMushafPageUseCase.self)
//                viewModel = MushafViewModel(getPage: useCase, startPage: startPage)
//            }
//
//            MushafFontManager.shared.registerFonts {
//                fontsReady = true
//            }
//            
//            // Test the repository
//            if let repo = qraaManager.searchRepository {
//                if let result = repo.fetchSearchWord(id: 1) {
//                    print("✅ [MushafRootView] Repository working: ID 1 -> '\(result.normalized)' / '\(result.display)'")
//                } else {
//                    print("⚠️ [MushafRootView] Repository lookup failed for ID 1")
//                }
//            } else {
//                print("❌ [MushafRootView] Repository is nil")
//            }
//        }
//    }
//}
