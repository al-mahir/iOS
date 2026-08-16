//
//  JoinCircleViewModel.swift
//  Circles
//

import Combine
import Foundation
import LiveSessionKit

public struct CircleLiveSessionDestination: Identifiable {
    public let id = UUID()
    public let circleId: String
    public let agoraToken: AgoraToken
}

@MainActor
public final class JoinCircleViewModel: ObservableObject {

    public let circle: CircleModel
    private let joinCircleUseCase: JoinCircleUseCase
    private let leaveCircleUseCase: LeaveCircleUseCase
    private let getAgoraTokenUseCase: GetAgoraTokenUseCase
    private let repository: any CircleRepositoryProtocol
    private let accessTokenProvider: () -> String?
    public let tokenRefreshProvider: any AgoraTokenRefreshProvider

    @Published public var joinState: JoinState = .pending
    @Published public var membership: CircleMembership?
    @Published public var isLoading = false
    @Published public var isPreparingLiveSession = false
    @Published public var errorMessage: String?
    @Published public var liveSessionDestination: CircleLiveSessionDestination?

    private var cancellables = Set<AnyCancellable>()
    private var membershipStatusCancellable: AnyCancellable?
    private var isConnectingSocket = false

    public init(
        circle: CircleModel,
        joinCircleUseCase: JoinCircleUseCase,
        leaveCircleUseCase: LeaveCircleUseCase,
        getAgoraTokenUseCase: GetAgoraTokenUseCase,
        repository: any CircleRepositoryProtocol,
        accessTokenProvider: @escaping () -> String?,
        tokenRefreshProvider: any AgoraTokenRefreshProvider
    ) {
        self.circle = circle
        self.joinCircleUseCase = joinCircleUseCase
        self.leaveCircleUseCase = leaveCircleUseCase
        self.getAgoraTokenUseCase = getAgoraTokenUseCase
        self.repository = repository
        self.accessTokenProvider = accessTokenProvider
        self.tokenRefreshProvider = tokenRefreshProvider
    }

    public func joinPublic() {
        guard !isLoading, membership == nil else { return }
        isLoading = true
        errorMessage = nil

        joinCircleUseCase
            .execute(circleId: circle.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = handleJoinError(error)
                }
            } receiveValue: { [weak self] membership in
                self?.handleMembership(membership)
            }
            .store(in: &cancellables)
    }

    public func startPendingWithMembership(_ membership: CircleMembership) {
        handleMembership(membership)
    }

    public func retryConnection() {
        guard let membership, membership.status == .pending else { return }
        connectSocket()
    }

    public func retryLiveSessionPreparation() {
        prepareLiveSession()
    }

    public func clearLiveSessionDestination() {
        liveSessionDestination = nil
    }

    public func leaveOrCancel(completion: @escaping () -> Void) {
        isLoading = true
        leaveCircleUseCase
            .execute(circleId: circle.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
                self?.stopObservingMembership()
                completion()
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    public func clearError() {
        errorMessage = nil
    }

    private func handleMembership(_ membership: CircleMembership) {
        self.membership = membership
#if DEBUG
        print("[CircleDebug] Join membership received: circleId=\(membership.circleId), membershipId=\(membership.membershipId), userId=\(membership.userId), status=\(membership.status)")
#endif
        switch membership.status {
        case .pending:
#if DEBUG
            print("[CircleDebug] Join request is pending; subscribing for host decision: membershipId=\(membership.membershipId)")
#endif
            joinState = .pending
            subscribeToMembershipStatus(membershipId: membership.membershipId)
            connectSocket()
        case .active:
            joinState = .approved(activeMember(from: membership))
            prepareLiveSession()
        }
    }

    private func subscribeToMembershipStatus(membershipId: String) {
        membershipStatusCancellable?.cancel()
#if DEBUG
        print("[CircleDebug] Join-status subscription registered: membershipId=\(membershipId)")
#endif
        membershipStatusCancellable = repository
            .observeMembershipStatus(membershipId: membershipId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .requestApproved(let member):
#if DEBUG
                    print("[CircleDebug] Join request approved by host: circleId=\(self.circle.id), userId=\(member.id)")
#endif
                    self.joinState = .approved(member)
                    self.prepareLiveSession()
                case .requestRejected(let reason):
#if DEBUG
                    print("[CircleDebug] Join request rejected by host: circleId=\(self.circle.id), reason=\(reason)")
#endif
                    self.joinState = .rejected(reason: reason)
                    self.stopObservingMembership()
                default:
                    break
                }
            }
    }

    private func connectSocket() {
        guard !isConnectingSocket else {
#if DEBUG
            print("[CircleDebug] Join-status socket connection ignored: already connecting, circleId=\(circle.id)")
#endif
            return
        }
        guard let accessToken = accessTokenProvider(), !accessToken.isEmpty else {
#if DEBUG
            print("[CircleDebug] Join-status socket connection blocked: missing access token, circleId=\(circle.id)")
#endif
            errorMessage = "Please sign in again to receive the host's response."
            return
        }

        isConnectingSocket = true
        errorMessage = nil
#if DEBUG
        print("[CircleDebug] Join-status socket connection started: circleId=\(circle.id)")
#endif
        Task { [weak self] in
            guard let self else { return }
            do {
                try await repository.connectSocket(authToken: accessToken)
#if DEBUG
                print("[CircleDebug] Join-status socket connection initiated: circleId=\(self.circle.id)")
#endif
            } catch {
#if DEBUG
                print("[CircleDebug] Join-status socket connection failed: circleId=\(self.circle.id), error=\(error)")
#endif
                errorMessage = error.localizedDescription
            }
            isConnectingSocket = false
        }
    }

    private func prepareLiveSession() {
        guard !isPreparingLiveSession, liveSessionDestination == nil else { return }
        isPreparingLiveSession = true
        errorMessage = nil

        getAgoraTokenUseCase
            .execute(circleId: circle.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isPreparingLiveSession = false
                if case .failure(let error) = completion {
                    self?.errorMessage = userFacingMessage(for: error)
                }
            } receiveValue: { [weak self] token in
                guard let self else { return }
                self.liveSessionDestination = CircleLiveSessionDestination(
                    circleId: self.circle.id,
                    agoraToken: token
                )
            }
            .store(in: &cancellables)
    }

    private func stopObservingMembership() {
        membershipStatusCancellable?.cancel()
        membershipStatusCancellable = nil
        Task {
            await repository.disconnectSocket()
        }
    }

    private func activeMember(from membership: CircleMembership) -> CircleMember {
        CircleMember(
            id: membership.userId,
            username: "",
            status: .active,
            joinedAt: membership.requestedAt
        )
    }
}
