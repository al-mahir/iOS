//
//  TaahudDependencyContainer.swift
//  Reading
//
//  Composition root / manual DI. Nothing below this file should ever
//  construct a concrete Data-layer type directly — everything is built and
//  injected here, once, then handed to SwiftUI as a `TaahudViewModel`.
//

import Foundation

public enum TaahudDependencyContainer {

    /// Points at the Al-Mahir backend (see SETUP.md / API.md). Swap this for
    /// a build-config value (Info.plist / xcconfig) before shipping — an
    /// ngrok tunnel is a dev convenience, not production infrastructure, and
    /// the token here is a development gateway token, not a per-user secret.
    private static let baseURL = URL(string: "https://qualm-mountable-cultivate.ngrok-free.dev")!
    private static let webSocketURL = URL(string: "wss://qualm-mountable-cultivate.ngrok-free.dev/ws/session")!
    private static let gatewayToken = "_pmUwNKpcrUxY1UiYMmcGyP4HV3tSWQxP6JO1pbO8gw"

    /// Builds a fully-wired `TaahudViewModel`.
    ///
    /// - Parameters:
    ///   - searchIndexDBURL: file URL to the bundled `search-index.db`.
    ///   - qpcV4DBURL: file URL to the bundled `qpc_v4.db`.
    @MainActor
    public static func makeTaahudViewModel(searchIndexDBURL: URL, qpcV4DBURL: URL) throws -> TaahudViewModel {
        let searchIndexDataSource = try SearchIndexLocalDataSource(databaseURL: searchIndexDBURL)
        let qpcDataSource = try QPCV4LocalDataSource(databaseURL: qpcV4DBURL)

        let recitationRepository = RecitationRepositoryImpl(webSocketURL: webSocketURL, authToken: gatewayToken)
        let mushafRepository = MushafRepositoryImpl(qpcDataSource: qpcDataSource, searchIndexDataSource: searchIndexDataSource)
        let audioSessionRepository = AudioRecorderService()

        let startRecitationUseCase = StartRecitationUseCase(recitationRepository: recitationRepository)
        let processAudioStreamUseCase = ProcessAudioStreamUseCase(
            audioSessionRepository: audioSessionRepository,
            recitationRepository: recitationRepository
        )
        let fetchMushafPageUseCase = FetchMushafPageUseCase(mushafRepository: mushafRepository)
        let seekRecitationUseCase = SeekRecitationUseCase(
            recitationRepository: recitationRepository,
            mushafRepository: mushafRepository
        )
        let stopRecitationUseCase = StopRecitationUseCase(
            processAudioStreamUseCase: processAudioStreamUseCase,
            recitationRepository: recitationRepository
        )

        return TaahudViewModel(
            startRecitationUseCase: startRecitationUseCase,
            processAudioStreamUseCase: processAudioStreamUseCase,
            fetchMushafPageUseCase: fetchMushafPageUseCase,
            seekRecitationUseCase: seekRecitationUseCase,
            stopRecitationUseCase: stopRecitationUseCase,
            recitationRepository: recitationRepository,
            mushafRepository: mushafRepository
        )
    }
}
