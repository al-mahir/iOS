//
//  JoinCircleViewModel.swift
//  Circles
//  Created by Nadin Ahmed on 24/07/2026.
//

import Combine
import Common
import Foundation

@MainActor
public final class JoinCircleViewModel: ObservableObject {

    // MARK: - Init

    public let circle: CircleModel
    private let joinCircleUseCase: JoinCircleUseCase
    private let leaveCircleUseCase: LeaveCircleUseCase
    private let repository: any CircleRepositoryProtocol

    public init(
        circle: CircleModel,
        joinCircleUseCase: JoinCircleUseCase,
        leaveCircleUseCase: LeaveCircleUseCase,
        repository: any CircleRepositoryProtocol
    ) {
        self.circle = circle
        self.joinCircleUseCase = joinCircleUseCase
        self.leaveCircleUseCase = leaveCircleUseCase
        self.repository = repository
    }

    // MARK: - Published State

    @Published public var joinState: JoinState = .pending
    @Published public var membership: CircleMembership? = nil
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String? = nil

    // MARK: - Dependencies

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Actions

    // Joins a public circle (no password required). Called automatically on appear.
    public func joinPublic() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        joinCircleUseCase
            .execute(circleId: circle.id, password: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                self?.isLoading = false
                if case .failure(let error) = result {
                    self?.errorMessage = handleJoinError(error)
                }
            } receiveValue: { [weak self] membership in
                guard let self else { return }
                self.membership = membership
                switch membership.status {
                case .pending:
                    self.joinState = .pending
                    self.subscribeToMembershipStatus(membershipId: membership.membershipId)
                case .active:
                    self.joinState = .approved(
                        CircleMember(
                            id: membership.userId,
                            username: "",
                            status: .active,
                            joinedAt: membership.requestedAt
                        )
                    )
                }
            }
            .store(in: &cancellables)
    }

    // Joins a private circle using the code entered in ActiveCirclesView.
    public func startPendingWithMembership(_ membership: CircleMembership) {
        self.membership = membership
        self.joinState = .pending
        self.subscribeToMembershipStatus(membershipId: membership.membershipId)
    }

    public func leaveOrCancel(completion: @escaping () -> Void) {
        isLoading = true
        leaveCircleUseCase
            .execute(circleId: circle.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
                completion()
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    public func clearError() { errorMessage = nil }

    // MARK: - Private Helpers

    private func subscribeToMembershipStatus(membershipId: String) {
        // TODO: inject real auth token from AuthManager when connecting socket in JoinCircleViewModel.
        // connectSocket must be called before observing — see CircleRepositoryProtocol.connectSocket(authToken:)

        repository
            .observeMembershipStatus(membershipId: membershipId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .requestApproved(let member):
                    self.joinState = .approved(member)
                case .requestRejected(let reason):
                    self.joinState = .rejected(reason: reason)
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
}
