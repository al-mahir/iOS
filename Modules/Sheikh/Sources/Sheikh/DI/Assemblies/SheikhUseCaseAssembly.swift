//
//  SheikhUseCaseAssembly.swift
//  Sheikh
//

import Swinject

public final class SheikhUseCaseAssembly: Assembly {
    public init() {}

    public func assemble(container: Container) {
        container.register((any GetSheikhsUseCaseProtocol).self) { r in
            GetSheikhsUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any GetSheikhDetailUseCaseProtocol).self) { r in
            GetSheikhDetailUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any ToggleFavoriteSheikhUseCaseProtocol).self) { r in
            ToggleFavoriteSheikhUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        // MARK: Private Session Use Cases

        container.register((any GetSheikhAvailabilityUseCaseProtocol).self) { r in
            GetSheikhAvailabilityUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any SendMeetingRequestUseCaseProtocol).self) { r in
            SendMeetingRequestUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any CancelMeetingRequestUseCaseProtocol).self) { r in
            CancelMeetingRequestUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)

        container.register((any ObserveMeetingRequestUseCaseProtocol).self) { r in
            ObserveMeetingRequestUseCase(repository: r.resolve((any SheikhRepositoryProtocol).self)!)
        }.inObjectScope(.transient)
    }
}
