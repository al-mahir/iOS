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
    @Published public var circle: CircleModel
    @Published public var joinRequest: JoinRequest?
    @Published public var isLoading: Bool = false
    @Published public var isCancelled: Bool = false
    @Published public var errorMessage: String? = nil

    private let repository: CirclesRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(
        circle: CircleModel,
        repository: CirclesRepositoryProtocol = CirclesRepositoryImpl()
    ) {
        self.circle = circle
        self.repository = repository
        sendJoinRequest()
    }

    public func sendJoinRequest() {
        isLoading = true
        errorMessage = nil

        repository.requestToJoin(circleId: circle.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] request in
                self?.joinRequest = request
            }
            .store(in: &cancellables)
    }

    public func cancelRequest(completion: @escaping () -> Void) {
        guard let reqId = joinRequest?.id else {
            completion()
            return
        }

        isLoading = true
        repository.cancelJoinRequest(requestId: reqId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
                self?.isCancelled = true
                completion()
            } receiveValue: { _ in
            }
            .store(in: &cancellables)
    }
}
