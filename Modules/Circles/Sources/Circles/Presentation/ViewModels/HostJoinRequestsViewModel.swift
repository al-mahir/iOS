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
    private var isReloadingRequests = false
    private var refreshContinuations = [CheckedContinuation<Void, Never>]()

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
        guard !hasStarted else {
#if DEBUG
            print("[CircleDebug] Host request inbox start ignored: already started, circleId=\(circleID)")
#endif
            return
        }
        hasStarted = true

#if DEBUG
        print("[CircleDebug] Host request inbox started: circleId=\(circleID)")
#endif

        observeOwnerRequests()
        observeSocketConnection()
        connectSocket()
    }

    public func stop() {
        guard hasStarted else { return }
        hasStarted = false
        isReloadingRequests = false
        isLoading = false
        completeRefreshContinuations()
        cancellables.removeAll()

#if DEBUG
        print("[CircleDebug] Host request inbox stopped: circleId=\(circleID)")
#endif

        Task { [repository] in
            await repository.disconnectSocket()
        }
    }

    // MARK: - Actions

    public func retry() {
        errorMessage = nil
        connectionError = nil
#if DEBUG
        print("[CircleDebug] Host request inbox retry: circleId=\(circleID)")
#endif
        connectSocket()
        reloadRequests()
    }

    public func refreshRequests() async {
        errorMessage = nil
        await withCheckedContinuation { continuation in
            reloadRequests(continuation: continuation)
        }
    }

    public func approve(_ request: PendingJoinRequest) {
        guard !actionUserIDs.contains(request.userId) else {
#if DEBUG
            print("[CircleDebug] Approve join request ignored: action already running, circleId=\(circleID), userId=\(request.userId)")
#endif
            return
        }
        actionUserIDs.insert(request.userId)
        errorMessage = nil

#if DEBUG
        print("[CircleDebug] Approve join request started: circleId=\(circleID), userId=\(request.userId)")
#endif

        Task { [weak self] in
            guard let self else { return }
            guard await self.ensureSocketConnection() else {
                self.actionUserIDs.remove(request.userId)
                self.errorMessage = "Unable to connect to live updates. Please try again."
                return
            }
            self.submitApproval(request)
        }
    }

    private func submitApproval(_ request: PendingJoinRequest) {
        approveJoinRequestUseCase.execute(circleId: circleID, userId: request.userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.finishAction(for: request.userId, error: error)
            } receiveValue: { [weak self] _ in
#if DEBUG
                print("[CircleDebug] Approve join request succeeded: circleId=\(self?.circleID ?? "unknown"), userId=\(request.userId)")
#endif
                self?.removeRequest(for: request.userId)
                self?.actionUserIDs.remove(request.userId)
            }
            .store(in: &cancellables)
    }

    public func reject(_ request: PendingJoinRequest) {
        guard !actionUserIDs.contains(request.userId) else {
#if DEBUG
            print("[CircleDebug] Reject join request ignored: action already running, circleId=\(circleID), userId=\(request.userId)")
#endif
            return
        }
        actionUserIDs.insert(request.userId)
        errorMessage = nil

#if DEBUG
        print("[CircleDebug] Reject join request started: circleId=\(circleID), userId=\(request.userId)")
#endif

        Task { [weak self] in
            guard let self else { return }
            guard await self.ensureSocketConnection() else {
                self.actionUserIDs.remove(request.userId)
                self.errorMessage = "Unable to connect to live updates. Please try again."
                return
            }
            self.submitRejection(request)
        }
    }

    private func submitRejection(_ request: PendingJoinRequest) {
        rejectJoinRequestUseCase.execute(circleId: circleID, userId: request.userId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard case .failure(let error) = completion else { return }
                self?.finishAction(for: request.userId, error: error)
            } receiveValue: { [weak self] in
#if DEBUG
                print("[CircleDebug] Reject join request succeeded: circleId=\(self?.circleID ?? "unknown"), userId=\(request.userId)")
#endif
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
#if DEBUG
        print("[CircleDebug] Host request socket subscription registered: circleId=\(circleID)")
#endif
        repository.observeOwnerRequests(circleId: circleID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }

                switch event {
                case .joinRequestReceived(let request):
#if DEBUG
                    print("[CircleDebug] Host request socket event mapped: circleId=\(self.circleID), userId=\(request.userId)")
#endif
                    self.upsert(request)
                case .joinRequestRemoved:
#if DEBUG
                    print("[CircleDebug] Host request socket removal received: circleId=\(self.circleID)")
#endif
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

#if DEBUG
                print("[CircleDebug] Host request socket state: circleId=\(self.circleID), connected=\(isConnected), wasConnected=\(wasConnected)")
#endif

                if isConnected, !wasConnected, self.hasLoadedRequests {
                    self.reloadRequests(showLoading: false)
                }
            }
            .store(in: &cancellables)
    }

    private func connectSocket() {
        Task { [weak self] in
            _ = await self?.ensureSocketConnection()
        }
    }

    private func ensureSocketConnection() async -> Bool {
        guard let token = accessTokenProvider()?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ), !token.isEmpty else {
#if DEBUG
            print("[CircleDebug] Host request socket connection blocked: missing access token, circleId=\(circleID)")
#endif
            connectionError = "Sign in again to receive live join requests."
            return false
        }

#if DEBUG
        print("[CircleDebug] Host request socket connection started: circleId=\(circleID)")
#endif

        do {
            try await repository.connectSocket(authToken: token)
#if DEBUG
            print("[CircleDebug] Host request socket connection confirmed: circleId=\(circleID)")
#endif
            connectionError = nil
            return true
        } catch {
#if DEBUG
            print("[CircleDebug] Host request socket connection failed: circleId=\(circleID), error=\(error)")
#endif
            connectionError = "Unable to connect to live join requests."
            return false
        }
    }

    private func reloadRequests(
        showLoading: Bool = true,
        continuation: CheckedContinuation<Void, Never>? = nil
    ) {
        if let continuation {
            refreshContinuations.append(continuation)
        }

        guard !isReloadingRequests else { return }
        isReloadingRequests = true

        if showLoading, requests.isEmpty {
            isLoading = true
        }

#if DEBUG
        print("[CircleDebug] Host pending-requests fetch started: circleId=\(circleID), showLoading=\(showLoading)")
#endif

        getPendingRequestsUseCase.execute(circleId: circleID)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                self.isLoading = false
                self.isReloadingRequests = false

                if case .failure(let error) = completion {
#if DEBUG
                    print("[CircleDebug] Host pending-requests fetch failed: circleId=\(self.circleID), error=\(error)")
#endif
                    self.errorMessage = userFacingMessage(for: error)
                }
                self.completeRefreshContinuations()
            } receiveValue: { [weak self] page in
                guard let self else { return }
                self.requests = page.items.sorted { $0.requestedAt < $1.requestedAt }
                self.hasLoadedRequests = true
#if DEBUG
                print("[CircleDebug] Host pending-requests fetch succeeded: circleId=\(self.circleID), count=\(page.items.count), userIds=\(page.items.map { $0.userId })")
#endif
            }
            .store(in: &cancellables)
    }

    private func completeRefreshContinuations() {
        let continuations = refreshContinuations
        refreshContinuations.removeAll()
        continuations.forEach { $0.resume() }
    }

    private func finishAction(for userID: String, error: CircleError) {
#if DEBUG
        print("[CircleDebug] Host join-request action failed: circleId=\(circleID), userId=\(userID), error=\(error)")
#endif
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
