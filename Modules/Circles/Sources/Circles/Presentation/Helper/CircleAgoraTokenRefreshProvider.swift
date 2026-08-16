//
//  CircleAgoraTokenRefreshProvider.swift
//  Circles
//

import Combine
import LiveSessionKit

final class CircleAgoraTokenRefreshProvider: AgoraTokenRefreshProvider, @unchecked Sendable {
    private let circleId: String
    private let getAgoraTokenUseCase: GetAgoraTokenUseCase

    init(circleId: String, getAgoraTokenUseCase: GetAgoraTokenUseCase) {
        self.circleId = circleId
        self.getAgoraTokenUseCase = getAgoraTokenUseCase
    }

    func refreshToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            cancellable = getAgoraTokenUseCase
                .execute(circleId: circleId)
                .sink { completion in
                    if case .failure(let error) = completion {
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: { token in
                    continuation.resume(returning: token.token)
                    cancellable?.cancel()
                }
        }
    }
}
