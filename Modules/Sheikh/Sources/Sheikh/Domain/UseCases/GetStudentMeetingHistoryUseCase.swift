//
//  GetStudentMeetingHistoryUseCase.swift
//  InstantMeetingKit
//
//  Created by Nadin Ahmed on 01/08/2026.
//

import Foundation

public protocol GetStudentMeetingHistoryUseCaseProtocol: Sendable {
    func execute(page: Int, size: Int) async throws -> PageResult<StudentMeetingHistoryItem>
}

public final class GetStudentMeetingHistoryUseCase: GetStudentMeetingHistoryUseCaseProtocol, Sendable {
    private let repository: SheikhRepositoryProtocol

    public init(repository: SheikhRepositoryProtocol) {
        self.repository = repository
    }

    public func execute(page: Int = 0, size: Int = 10) async throws -> PageResult<StudentMeetingHistoryItem> {
        try await repository.getStudentHistory(page: page, size: size)
    }
}
