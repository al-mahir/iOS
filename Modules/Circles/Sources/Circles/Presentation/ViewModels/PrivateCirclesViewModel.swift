//
//  PrivateCirclesViewModel.swift
//  Circles
//

import Combine
import Common
import Foundation
import LiveSessionKit

public enum CircleActionFeedback: Equatable {
    case success(String)
    case error(String)

    var message: String {
        switch self {
        case .success(let message), .error(let message):
            return message
        }
    }
}

@MainActor
public final class PrivateCirclesViewModel: ObservableObject {

    private let getPrivateCirclesUseCase: GetPrivateCirclesUseCase
    private let joinPrivateCircleUseCase: JoinPrivateCircleUseCase
    private let getCircleUseCase: GetCircleUseCase
    private let startCircleUseCase: StartCircleUseCase
    private let getAgoraTokenUseCase: GetAgoraTokenUseCase
    private let cancelCircleUseCase: CancelCircleUseCase
    private let currentUserIDProvider: @MainActor () -> String?

    public init(
        getPrivateCirclesUseCase: GetPrivateCirclesUseCase,
        joinPrivateCircleUseCase: JoinPrivateCircleUseCase,
        getCircleUseCase: GetCircleUseCase,
        startCircleUseCase: StartCircleUseCase = StartCircleUseCase(
            repository: CircleRepository()
        ),
        getAgoraTokenUseCase: GetAgoraTokenUseCase = GetAgoraTokenUseCase(
            repository: CircleRepository()
        ),
        cancelCircleUseCase: CancelCircleUseCase = CancelCircleUseCase(
            repository: CircleRepository()
        ),
        currentUserIDProvider: @escaping @MainActor () -> String? = {
            SessionManager.shared.currentUser?.id
        }
    ) {
        self.getPrivateCirclesUseCase = getPrivateCirclesUseCase
        self.joinPrivateCircleUseCase = joinPrivateCircleUseCase
        self.getCircleUseCase = getCircleUseCase
        self.startCircleUseCase = startCircleUseCase
        self.getAgoraTokenUseCase = getAgoraTokenUseCase
        self.cancelCircleUseCase = cancelCircleUseCase
        self.currentUserIDProvider = currentUserIDProvider
    }

    @Published public var circles: [CircleModel] = []
    @Published public var searchQuery = "" {
        didSet { applyLocalFilter() }
    }
    @Published public var isLoading = false
    @Published public var errorMessage: String?

    @Published public var privateToken = ""
    @Published public var privateTokenError: String?
    @Published public var isJoiningWithToken = false
    @Published public var pendingPrivateJoin: PrivateJoinResult?
    @Published public private(set) var startingCircleID: String?
    @Published public private(set) var deletingCircleID: String?
    @Published public var liveSessionDestination: CircleLiveSessionDestination?
    @Published public var actionFeedback: CircleActionFeedback?

    private var allCircles: [CircleModel] = []
    private var cancellables = Set<AnyCancellable>()

    public func fetchCircles() {
        isLoading = true
        errorMessage = nil

        getPrivateCirclesUseCase
            .execute()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                let currentUserID = self.currentUserIDProvider()
                self.allCircles = page.items.filter { $0.ownerId == currentUserID }
                self.applyLocalFilter()
            }
            .store(in: &cancellables)
    }

    public func joinWithToken() {
        let token = privateToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !token.isEmpty else {
            privateTokenError = "Please enter an invite token."
            return
        }

        isJoiningWithToken = true
        privateTokenError = nil

        joinPrivateCircleUseCase
            .execute(token: token)
            .flatMap { [weak self] membership -> AnyPublisher<PrivateJoinResult, CircleError> in
                guard let self else {
                    return Fail(error: .unknown("Internal error"))
                        .eraseToAnyPublisher()
                }
                return self.getCircleUseCase
                    .execute(circleId: membership.circleId)
                    .map { PrivateJoinResult(circle: $0, membership: membership) }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isJoiningWithToken = false
                if case .failure(let error) = completion {
                    self?.privateTokenError = handleCodeError(error)
                }
            } receiveValue: { [weak self] result in
                guard let self else { return }
                self.privateToken = ""
                self.pendingPrivateJoin = result
            }
            .store(in: &cancellables)
    }

    public func clearPrivateJoin() {
        pendingPrivateJoin = nil
    }

    public func clearError() {
        errorMessage = nil
    }

    public func start(circle: CircleModel) {
        guard circle.canStart, startingCircleID == nil else { return }

        startingCircleID = circle.id
        startCircleUseCase
            .execute(circle: circle)
            .flatMap { [getAgoraTokenUseCase] in
                getAgoraTokenUseCase.execute(circleId: circle.id)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.startingCircleID = nil
                if case .failure(let error) = completion {
                    self?.actionFeedback = .error(userFacingMessage(for: error))
                }
            } receiveValue: { [weak self] token in
                self?.liveSessionDestination = CircleLiveSessionDestination(
                    circleId: circle.id,
                    agoraToken: token
                )
            }
            .store(in: &cancellables)
    }

    public func delete(circle: CircleModel) {
        guard circle.canCancel, deletingCircleID == nil else { return }

        deletingCircleID = circle.id
        cancelCircleUseCase
            .execute(circle: circle)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.deletingCircleID = nil
                if case .failure(let error) = completion {
                    self?.actionFeedback = .error(userFacingMessage(for: error))
                }
            } receiveValue: { [weak self] in
                self?.allCircles.removeAll { $0.id == circle.id }
                self?.applyLocalFilter()
            }
            .store(in: &cancellables)
    }

    public func replaceCircle(_ updatedCircle: CircleModel) {
        guard let index = allCircles.firstIndex(where: { $0.id == updatedCircle.id }) else {
            return
        }

        let original = allCircles[index]
        allCircles[index] = updatedCircle.replacing(
            inviteToken: updatedCircle.inviteToken ?? original.inviteToken
        )
        applyLocalFilter()
    }

    public func makeTokenRefreshProvider(
        circleID: String
    ) -> any AgoraTokenRefreshProvider {
        CircleAgoraTokenRefreshProvider(
            circleId: circleID,
            getAgoraTokenUseCase: getAgoraTokenUseCase
        )
    }

    public func clearLiveSessionDestination() {
        liveSessionDestination = nil
    }

    public func clearActionFeedback() {
        actionFeedback = nil
    }

    public func showSuccessFeedback(_ message: String) {
        actionFeedback = .success(message)
    }

    private func applyLocalFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        circles = query.isEmpty
            ? allCircles
            : allCircles.filter { $0.name.lowercased().contains(query) }
    }
}
