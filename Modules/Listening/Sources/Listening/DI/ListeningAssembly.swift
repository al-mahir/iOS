//
//  ListeningAssembly.swift
//  Listening
//

import Foundation
import Swinject
import NetworkKit

/// Registers all Listening module dependencies into the provided Swinject container.
public final class ListeningAssembly: Assembly {

    public init() {}

    public func assemble(container: Container) {

        // MARK: Repository
        container.register(ListeningRepository.self) { _ in
            ListeningRepositoryImpl(networkService: NetworkService.shared)
        }.inObjectScope(.container)

        // MARK: Use Cases
        container.register(FetchRecitersUseCase.self) { r in
            FetchRecitersUseCaseImpl(repository: r.resolve(ListeningRepository.self)!)
        }
        container.register(FetchWordTimingsUseCase.self) { r in
            FetchWordTimingsUseCaseImpl(repository: r.resolve(ListeningRepository.self)!)
        }
        container.register(FetchAudioURLUseCase.self) { r in
            FetchAudioURLUseCaseImpl(repository: r.resolve(ListeningRepository.self)!)
        }

        // MARK: Audio Manager (singleton — shared across VM and views)
        container.register(AudioSyncManager.self) { _ in
            MainActor.assumeIsolated {
                AudioSyncManager()
            }
        }.inObjectScope(.container)

        // MARK: ViewModel
        container.register(ListeningViewModel.self) { r in
            MainActor.assumeIsolated {
                ListeningViewModel(
                    audioManager: r.resolve(AudioSyncManager.self)!,
                    fetchReciters: r.resolve(FetchRecitersUseCase.self)!,
                    fetchWordTimings: r.resolve(FetchWordTimingsUseCase.self)!,
                    fetchAudioURL: r.resolve(FetchAudioURLUseCase.self)!
                )
            }
        }.inObjectScope(.container)
    }
}
