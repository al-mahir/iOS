//
//  InstantMeetingTokenRefreshProvider.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation
import Combine
import LiveSessionKit
import NetworkKit

public final class InstantMeetingTokenRefreshProvider: AgoraTokenRefreshProvider, @unchecked Sendable {
    private let requestId: String
    private let remoteDataSource: InstantMeetingsRemoteDataSourceProtocol

    public init(
        requestId: String,
        remoteDataSource: InstantMeetingsRemoteDataSourceProtocol
    ) {
        self.requestId = requestId
        self.remoteDataSource = remoteDataSource
    }

    public func refreshToken() async throws -> String {
        let response = try await remoteDataSource.getToken(requestId: requestId).asyncValue()
        return response.token
    }
}

private extension AnyPublisher {
    func asyncValue() async throws -> Output {
        try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?
            var finishedWithoutValue = true
            cancellable = self.first()
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            continuation.resume(throwing: error)
                        } else if finishedWithoutValue {
                            continuation.resume(
                                throwing: NSError(
                                    domain: "CombineError",
                                    code: -1,
                                    userInfo: [NSLocalizedDescriptionKey: "Publisher finished without emitting value"]
                                )
                            )
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { value in
                        finishedWithoutValue = false
                        continuation.resume(returning: value)
                    }
                )
        }
    }
}
