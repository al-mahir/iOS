//
//  PrivateCirclesViewModel.swift
//  Circles
//

import Combine
import Foundation

@MainActor
public final class PrivateCirclesViewModel: ObservableObject {

    private let getPrivateCirclesUseCase: GetPrivateCirclesUseCase
    private let joinPrivateCircleUseCase: JoinPrivateCircleUseCase
    private let getCircleUseCase: GetCircleUseCase

    public init(
        getPrivateCirclesUseCase: GetPrivateCirclesUseCase,
        joinPrivateCircleUseCase: JoinPrivateCircleUseCase,
        getCircleUseCase: GetCircleUseCase
    ) {
        self.getPrivateCirclesUseCase = getPrivateCirclesUseCase
        self.joinPrivateCircleUseCase = joinPrivateCircleUseCase
        self.getCircleUseCase = getCircleUseCase
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
                self.allCircles = page.items
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

    private func applyLocalFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        circles = query.isEmpty
            ? allCircles
            : allCircles.filter { $0.name.lowercased().contains(query) }
    }
}
