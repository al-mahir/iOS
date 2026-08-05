//
//  ActiveCirclesViewModel.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Combine
import Common
import Foundation

@MainActor
public final class ActiveCirclesViewModel: ObservableObject {

    // MARK: - Init

    private let listCirclesUseCase: ListCirclesUseCase
    private let getMyCirclesUseCase: GetMyCirclesUseCase
    private let joinCircleUseCase: JoinCircleUseCase
    private let getCircleUseCase: GetCircleUseCase

    public init(
        listCirclesUseCase: ListCirclesUseCase,
        getMyCirclesUseCase: GetMyCirclesUseCase,
        joinCircleUseCase: JoinCircleUseCase = JoinCircleUseCase(
            repository: CircleRepository()
        ),
        getCircleUseCase: GetCircleUseCase = GetCircleUseCase(
            repository: CircleRepository()
        )
    ) {
        self.listCirclesUseCase = listCirclesUseCase
        self.getMyCirclesUseCase = getMyCirclesUseCase
        self.joinCircleUseCase = joinCircleUseCase
        self.getCircleUseCase = getCircleUseCase
    }

    // MARK: - Published State — Circle List

    @Published public var circles: [CircleModel] = []
    @Published public var searchQuery: String = "" {
        didSet { applyLocalFilter() }
    }
    @Published public var selectedStatus: CircleStatus? = nil {
        didSet { resetAndFetch() }
    }
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil
    @Published public var hasMore: Bool = false

    // MARK: - Published State — Private Code Banner

    @Published public var privateSessionId: String = ""
    @Published public var privatePassword: String = ""
    @Published public var privateCodeError: String? = nil
    @Published public var isJoiningWithCode: Bool = false
    @Published public var pendingPrivateJoin: PrivateJoinResult? = nil

    // MARK: - Filter chips shown in the UI

    public let filterOptions: [(CircleStatus?, String)] = [
        (nil, "All"),
        (.scheduled, "Scheduled"),
        (.ongoing, "Live"),
        (.completed, "Completed"),
    ]

    // MARK: - Dependencies & Pagination

    private var allCircles: [CircleModel] = []
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Actions — Circle List

    public func fetchCircles() {
        currentPage = 0
        allCircles = []
        circles = []
        loadPage()
    }

    public func loadMore() {
        guard hasMore, !isLoading else { return }
        currentPage += 1
        loadPage()
    }

    public func clearError() { errorMessage = nil }

    // MARK: - Actions — Private Code Banner

    public func joinWithCode() {
        let sessionId = privateSessionId.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = privatePassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !sessionId.isEmpty, !password.isEmpty else {
            privateCodeError = "Please enter both the Session ID and Password."
            return
        }

        isJoiningWithCode = true
        privateCodeError = nil

        joinCircleUseCase
            .execute(circleId: sessionId, password: password)
            .receive(on: DispatchQueue.main)
            .flatMap {
                [weak self] membership -> AnyPublisher<(CircleMembership, CircleModel), CircleError> in
                guard let self else {
                    return Fail(error: CircleError.unknown("Internal error"))
                        .eraseToAnyPublisher()
                }
                return self.getCircleUseCase
                    .execute(circleId: membership.circleId)
                    .map { circle in (membership, circle) }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                self?.isJoiningWithCode = false
                if case .failure(let error) = result {
                    self?.privateCodeError = handleCodeError(error)
                }
            } receiveValue: { [weak self] (membership, circle) in
                guard let self else { return }
                self.privateSessionId = ""
                self.privatePassword = ""
                self.pendingPrivateJoin = PrivateJoinResult(
                    circle: circle,
                    membership: membership
                )
            }
            .store(in: &cancellables)
    }

    public func clearPrivateJoin() {
        pendingPrivateJoin = nil
    }

    // MARK: - Private Helpers

    private func resetAndFetch() {
        fetchCircles()
    }

    private func loadPage() {
        isLoading = true
        errorMessage = nil

        let params = ListCirclesParams(status: selectedStatus)
        let pageReq = CirclePageRequest(page: currentPage, size: pageSize)

        listCirclesUseCase
            .execute(params: params, page: pageReq)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.allCircles.append(contentsOf: page.items)
                self.hasMore = !page.isLast
                self.applyLocalFilter()
            }
            .store(in: &cancellables)
    }

    private func applyLocalFilter() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
        if query.isEmpty {
            circles = allCircles
        } else {
            circles = allCircles.filter {
                $0.name.lowercased().contains(query)
            }
        }
    }
}
