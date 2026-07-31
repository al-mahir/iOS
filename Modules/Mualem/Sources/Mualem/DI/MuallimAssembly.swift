//
//  MuallimAssembly.swift
//  Mualem
//

import Foundation
import Swinject

public final class MuallimAssembly: Assembly {
    
    public init() {}
    
    public func assemble(container: Container) {
        
        // Data Layer — Voice Evaluation Service
        // Use real SFSpeechRecognizer on device, Mock on Simulator
        container.register(VoiceEvaluationServiceProtocol.self) { _ in
            #if targetEnvironment(simulator)
            MockVoiceEvaluationService()
            #else
            SFSpeechEvaluationService()
            #endif
        }.inObjectScope(.container)
        
        // Domain Layer (Use Cases)
        container.register(EvaluateRecitationUseCase.self) { r in
            EvaluateRecitationUseCase(evaluator: r.resolve(VoiceEvaluationServiceProtocol.self)!)
        }
        
        // Presentation Layer (ViewModel)
        container.register(MuallimViewModel.self) { r in
            MainActor.assumeIsolated {
                MuallimViewModel(
                    audioService: r.resolve(AudioPlaybackServiceProtocol.self)!,
                    evaluateUseCase: r.resolve(EvaluateRecitationUseCase.self)!,
                    ayahTextProvider: r.resolve(AyahTextProviding.self)!
                )
            }
        }
    }
}
