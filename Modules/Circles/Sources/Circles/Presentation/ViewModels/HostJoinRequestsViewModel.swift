//
//  HostJoinRequestsViewModel.swift
//  Circles
//

import Combine
import Foundation

@MainActor
public final class HostJoinRequestsViewModel: ObservableObject {

    // MARK: - Published State

    @Published public private(set) var requests: [PendingJoinRequest] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var actionUserIDs = Set<String>()
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var connectionError: String?

    public var pendingCount: Int { requests.count }

    // MARK: - Dependencies

    private let circleID: String
    private let getPendingRequestsUseCase: GetPendingRequestsUseCase
    private let approveJoinRequestUseCase: ApproveJoinRequestUseCase
    private let rejectJoinRequestUseCase: RejectJoinRequestUseCase
    private let repository: any CircleRepositoryProtocol
    private let accessTokenProvider: () -> String?

    private var cancellables = Set<AnyCancellable>()
    private var hasStarted = false
    private var hasLoadedRequests = false
    private var isSocketConnected = false

    // MARK: - Init

    public init(
        circleID: String,
        getPendingRequestsUseCase: GetPendingRequestsUseCase,
        approveJoinRequestUseCase: ApproveJoinRequestUseCase,
        rejectJoinRequestUseCase: RejectJoinRequestUseCase,
        repository: any CircleRepositoryProtocol,
        accessTokenProvider: @escaping () -> String?
    ) {
        self.circleID = circleID
        self.getPendingRequestsUseCase = getPendingRequestsUseCase
        self.approveJoinRequestUseCase = approveJoinRequestUseCase
        self.rejectJoinRequestUseCase = rejectJoinRequestUseCase
        self.repository = repository
        self.accessTokenProvider = accessTokenProvider
    }

    // MARK: - Lifecycle

    public func start() {
        guard !hasStarted else { return }
        hasStarted = true

        observeOwnerRequests()
        observeSocketConnection()
        connectSocket()
        reloadRequests()
    }

    public func stop() {
        guard hasStarted else { return }
        hasStarted = false
        cancellables.removeAll()

        Task { [repository] in
            await repository.disconnectSocket()
        }
    }

    // MARK: - Actions

    public func retry() {
        errorMessage = nil
        connectionError = nil
        connectSocket()
        reloadRequests()
    }

    public func approve(_ request: PendingJoinRequest) {
        guard !actionUserIDs.contains(request.userId) else { return }
        actionUserIDs.insert(request.userId)
        errorMessage = nil

        approveJoinRequestUseCase.execute(circleId: circleID, userId: request.userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.finishAction(for: request.userId, error: error)
            } receiveValue: { [weak self] _ in
                self?.removeRequest(for: request.userId)
                self?.actionUserIDs.remove(request.userId)
            }
            .store(in: &cancellables)
    }

    public func reject(_ request: PendingJoinRequest) {
        guard !actionUserIDs.contains(request.userId) else { return }
        actionUserIDs.insert(request.userId)
        errorMessage = nil

        rejectJoinRequestUseCase.execute(circleId: circleID, userId: request.userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.finishAction(for: request.userId, error: error)
            } receiveValue: { [weak self] in
                self?.removeRequest(for: request.userId)
                self?.actionUserIDs.remove(request.userId)
            }
            .store(in: &cancellables)
    }

    public func isActing(on request: PendingJoinRequest) -> Bool {
        actionUserIDs.contains(request.userId)
    }

    // MARK: - Private Helpers

    private func observeOwnerRequests() {
        repository.observeOwnerRequests(circleId: circleID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .joinRequestReceived(let request):
                    self.upsert(request)
                case .joinRequestRemoved:
                    self.reloadRequests(showLoading: false)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }

    private func observeSocketConnection() {
        repository.socketConnectionState
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                guard let self else { return }
                let wasConnected = self.isSocketConnected
                self.isSocketConnected = isConnected

                if isConnected, !wasConnected, self.hasLoadedRequests {
                    self.reloadRequests(showLoading: false)
                }
            }
            .store(in: &cancellables)
    }

    private func connectSocket() {
        guard let token = accessTokenProvider()?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !token.isEmpty else {
            connectionError = "Sign in again to receive live join requests."
            return
        }

        Task { [weak self, repository] in
            do {
                try await repository.connectSocket(authToken: token)
            } catch {
                self?.connectionError = error.localizedDescription
            }
        }
    }

    private func reloadRequests(showLoading: Bool = true) {
        if showLoading, requests.isEmpty {
            isLoading = true
        }

        getPendingRequestsUseCase.execute(circleId: circleID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false

                if case .failure(let error) = completion {
                    self.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.requests = page.items.sorted { $0.requestedAt < $1.requestedAt }
                self.hasLoadedRequests = true
            }
            .store(in: &cancellables)
    }

    private func finishAction(for userID: String, error: CircleError) {
        actionUserIDs.remove(userID)
        errorMessage = userFacingMessage(for: error)
    }

    private func upsert(_ request: PendingJoinRequest) {
        requests.removeAll { $0.userId == request.userId }
        requests.append(request)
        requests.sort { $0.requestedAt < $1.requestedAt }
    }

    private func removeRequest(for userID: String) {
        requests.removeAll { $0.userId == userID }
    }
}
