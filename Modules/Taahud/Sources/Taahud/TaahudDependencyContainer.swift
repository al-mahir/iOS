//
//  TaahudDependencyContainer.swift
//  Taahud

import Foundation

public enum TaahudDependencyContainer {

    private static let baseURL = URL(string: "https://qualm-mountable-cultivate.ngrok-free.dev")!
    private static let webSocketURL = URL(string: "wss://qualm-mountable-cultivate.ngrok-free.dev/ws/session")!
    private static let gatewayToken = "_pmUwNKpcrUxY1UiYMmcGyP4HV3tSWQxP6JO1pbO8gw"
    
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
            stopRecitationUseCase: stopRecitationUseCase,
            recitationRepository: recitationRepository,
            fetchMushafPageUseCase: fetchMushafPageUseCase,
            seekRecitationUseCase: seekRecitationUseCase,
            mushafRepository: mushafRepository
        )
    }
    @MainActor
    public static func makeEmbeddedTaahudViewModel() -> TaahudViewModel {
        let recitationRepository = RecitationRepositoryImpl(webSocketURL: webSocketURL, authToken: gatewayToken)
        let audioSessionRepository = AudioRecorderService()

        let startRecitationUseCase = StartRecitationUseCase(recitationRepository: recitationRepository)
        let processAudioStreamUseCase = ProcessAudioStreamUseCase(
            audioSessionRepository: audioSessionRepository,
            recitationRepository: recitationRepository
        )
        let stopRecitationUseCase = StopRecitationUseCase(
            processAudioStreamUseCase: processAudioStreamUseCase,
            recitationRepository: recitationRepository
        )

        return TaahudViewModel(
            startRecitationUseCase: startRecitationUseCase,
            processAudioStreamUseCase: processAudioStreamUseCase,
            stopRecitationUseCase: stopRecitationUseCase,
            recitationRepository: recitationRepository
        )
    }
}
