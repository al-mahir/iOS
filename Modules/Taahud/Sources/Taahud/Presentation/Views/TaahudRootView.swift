//
//  TaahudRootView.swift
//  Taahud
//
//  Created by Basmala Abuzied Ahmed on 03/08/2026.
//

import SwiftUI

public struct TaahudRootView: View {
    public init(){}
    public var body: some View {
        Group {
            if let viewModel = Self.makeViewModel() {
                TaahudContainerView(viewModel: viewModel, initialPage: 1)
            } else {
                Text("Could not load recitation databases.")
                    .foregroundStyle(.red)
            }
        }
    }

    @MainActor
    private static func makeViewModel() -> TaahudViewModel? {
        guard
            let searchIndexURL = Bundle.main.url(forResource: "search-index", withExtension: "db"),
            let qpcV4URL = Bundle.main.url(forResource: "qpc_v4", withExtension: "db")
        else {
            print("❌ [Taahud] bundled databases not found")
            return nil
        }

        do {
            return try TaahudDependencyContainer.makeTaahudViewModel(
                searchIndexDBURL: searchIndexURL,
                qpcV4DBURL: qpcV4URL
            )
        } catch {
            print("❌ [Taahud] failed to build ViewModel: \(error.localizedDescription)")
            return nil
        }
    }
}
