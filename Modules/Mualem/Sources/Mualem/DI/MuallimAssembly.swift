//
//  MuallimAssembly.swift
//  Mualem
//

import Foundation
import Swinject

public final class MuallimAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        
        // MARK: - Data Sources
        
        container.register(MuallemWebSocketDataSource.self) { _ in
            MuallemWebSocketDataSource()
        }.inObjectScope(.container)
        
        container.register(MuallemRESTDataSource.self) { _ in
            MuallemRESTDataSource()
        }.inObjectScope(.container)
        
        container.register(MuallemMockDataSource.self) { _ in
            MuallemMockDataSource()
        }.inObjectScope(.container)
        
        container.register(AudioCaptureService.self) { _ in
            AudioCaptureService()
        }
        
        // MARK: - Repositories
        
        container.register(MuallemSessionRepositoryProtocol.self) { r in
            MuallemSessionRepositoryImpl(
                wsDataSource: r.resolve(MuallemWebSocketDataSource.self)!,
                mockDataSource: r.resolve(MuallemMockDataSource.self)!
            )
        }
        
        container.register(MuallemAIConfigRepositoryProtocol.self) { r in
            MuallemAIConfigRepositoryImpl(
                restDataSource: r.resolve(MuallemRESTDataSource.self)!,
                mockDataSource: r.resolve(MuallemMockDataSource.self)!
            )
        }
        
        // MARK: - Use Cases
        
        container.register(StartMuallemSessionUseCase.self) { r in
            StartMuallemSessionUseCase(
                repository: r.resolve(MuallemSessionRepositoryProtocol.self)!
            )
        }
        
        container.register(FetchAIConfigUseCase.self) { r in
            FetchAIConfigUseCase(
                repository: r.resolve(MuallemAIConfigRepositoryProtocol.self)!
            )
        }
        
        // Keep the old use case registered for backward compatibility
        container.register(EvaluateRecitationUseCase.self) { r in
            EvaluateRecitationUseCase(evaluator: r.resolve(VoiceEvaluationServiceProtocol.self)!)
        }
        
        // Data Layer — Voice Evaluation Service (kept for backward compat)
        container.register(VoiceEvaluationServiceProtocol.self) { _ in
            #if targetEnvironment(simulator)
            MockVoiceEvaluationService()
            #else
            SFSpeechEvaluationService()
            #endif
        }.inObjectScope(.container)
        
        // MARK: - Presentation Layer (ViewModel)
        
        container.register(MuallimViewModel.self) { r in
            MainActor.assumeIsolated {
                MuallimViewModel(
                    audioService: r.resolve(AudioPlaybackServiceProtocol.self)!,
                    sessionUseCase: r.resolve(StartMuallemSessionUseCase.self)!,
                    configUseCase: r.resolve(FetchAIConfigUseCase.self)!,
                    audioCaptureService: r.resolve(AudioCaptureService.self)!,
                    ayahTextProvider: r.resolve(AyahTextProviding.self)!
                )
            }
        }
    }
}
