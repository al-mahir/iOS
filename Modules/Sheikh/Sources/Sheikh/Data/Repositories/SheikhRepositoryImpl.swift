//
//  SheikhRepositoryImpl.swift
//  Sheikh
//

import Foundation
import Combine
import NetworkKit
import RealtimeKit
import Bookmarks

public final class SheikhRepositoryImpl: SheikhRepositoryProtocol, @unchecked
    Sendable
{

    private let networkService: any NetworkServiceProtocol
    private var favoriteIDs: Set<String> = [
        "00000000-0000-0000-0000-000000000000",
        "44444444-4444-4444-4444-444444444444",
    ]
    private var cachedSheikhs: [String: Sheikh] = [:]
    private let sheikhBookmarkUseCase: SheikhBookmarkUseCase?
    private var cancellables = Set<AnyCancellable>()

    private let remoteDataSource: InstantMeetingsRemoteDataSourceProtocol
    private let realtimeDataSource: InstantMeetingsRealtimeDataSourceProtocol

    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime, .withFractionalSeconds,
        ]
        return formatter
    }()

    public init(
        networkService: any NetworkServiceProtocol = NetworkService.shared,
        remoteDataSource: InstantMeetingsRemoteDataSourceProtocol = InstantMeetingsRemoteDataSource(),
        realtimeDataSource: InstantMeetingsRealtimeDataSourceProtocol = InstantMeetingsRealtimeDataSource(realtimeClient: RealtimeClient()),
        sheikhBookmarkUseCase: SheikhBookmarkUseCase? = nil
    ) {
        self.remoteDataSource = remoteDataSource
        self.realtimeDataSource = realtimeDataSource
        self.networkService = networkService
        self.sheikhBookmarkUseCase = sheikhBookmarkUseCase ?? SheikhBookmarkUseCaseFactory.makeDefault()

        syncFavoriteIDs()
        observeBookmarkChanges()
    }

    private func syncFavoriteIDs() {
        Task { @MainActor [weak self] in
            guard let self = self, let useCase = self.sheikhBookmarkUseCase else { return }
            if let bookmarks = try? useCase.fetchAll() {
                let ids = Set(bookmarks.map(\.sheikhID))
                self.favoriteIDs.formUnion(ids)
            }
        }
    }

    private func observeBookmarkChanges() {
        NotificationCenter.default.publisher(for: .bookmarkDidChange)
            .sink { [weak self] _ in
                self?.syncFavoriteIDs()
            }
            .store(in: &cancellables)
    }

    public func getAllSheikhs() -> AnyPublisher<[Sheikh], NetworkError> {
        let directArrayPublisher: AnyPublisher<[Sheikh], NetworkError> = networkService.request(SheikhEndpoints.getAllSheikhs)
        let pagePublisher: AnyPublisher<PageResponseDTO<Sheikh>, NetworkError> = networkService.request(SheikhEndpoints.getAllSheikhs)

        return directArrayPublisher
            .catch { _ in
                pagePublisher.map { $0.content }
            }
            .catch { _ in
                Just([Sheikh.dummyTestSheikh]).setFailureType(to: NetworkError.self)
            }
            .map { [weak self] (sheikhs: [Sheikh]) in
                let list = sheikhs.isEmpty ? [Sheikh.dummyTestSheikh] : sheikhs
                return self?.applyFavorites(to: list) ?? list
            }
            .eraseToAnyPublisher()
    }

    public func getSheikhByID(_ id: String) -> AnyPublisher<
        Sheikh, NetworkError
    > {
        if id == Sheikh.dummyTestSheikh.id {
            var dummy = Sheikh.dummyTestSheikh
            dummy.isFavorite = favoriteIDs.contains(id)
            cachedSheikhs[id] = dummy
            return Just(dummy)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }
        return networkService.request(SheikhEndpoints.getSheikhByID(id: id))
            .catch { _ in
                var dummy = Sheikh.dummyTestSheikh
                dummy.isFavorite = self.favoriteIDs.contains(id)
                return Just(dummy).setFailureType(to: NetworkError.self)
            }
            .map { [weak self] (sheikh: Sheikh) in
                var updated = sheikh
                if let self = self {
                    updated.isFavorite = self.favoriteIDs.contains(sheikh.id)
                    self.cachedSheikhs[sheikh.id] = updated
                }
                return updated
            }
            .eraseToAnyPublisher()
    }

    public func searchSheikhs(name: String?) -> AnyPublisher<
        [SheikhSearchResult], NetworkError
    > {
        networkService.requestExternal(
            SheikhEndpoints.searchSheikhs(name: name)
        )
        .eraseToAnyPublisher()
    }

    public func toggleFavorite(sheikhID: String) -> AnyPublisher<
        Bool, NetworkError
    > {
        let currentlyFav = favoriteIDs.contains(sheikhID)
        let newFav = !currentlyFav

        if currentlyFav {
            favoriteIDs.remove(sheikhID)
            Task { @MainActor [weak self] in
                try? self?.sheikhBookmarkUseCase?.remove(sheikhID: sheikhID)
                NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
            }
        } else {
            favoriteIDs.insert(sheikhID)
            let sheikh = cachedSheikhs[sheikhID] ?? (sheikhID == Sheikh.dummyTestSheikh.id ? Sheikh.dummyTestSheikh : nil)
            let name = sheikh?.fullName ?? "Sheikh"
            let reciterStyle = (sheikh?.formattedQiraat.isEmpty == false) ? sheikh!.formattedQiraat : "Reciter"
            Task { @MainActor [weak self] in
                try? self?.sheikhBookmarkUseCase?.add(
                    sheikhID: sheikhID,
                    name: name,
                    arabicName: name,
                    reciterStyle: reciterStyle
                )
                NotificationCenter.default.post(name: .bookmarkDidChange, object: nil)
            }
        }

        return Just(newFav)
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }

    private func applyFavorites(to sheikhs: [Sheikh]) -> [Sheikh] {
        sheikhs.map { s in
            cachedSheikhs[s.id] = s
            var copy = s
            copy.isFavorite = favoriteIDs.contains(s.id)
            return copy
        }
    }

    public func getSheikhAvailability(sheikhId: String) async throws
        -> SheikhAvailability
    {
        let dto = try await remoteDataSource.getAvailability(sheikhId: sheikhId)
            .asyncValue()
        let status = SheikhAvailabilityStatus(rawValue: dto.status) ?? .notAvailable
        let updatedAt = dto.updatedAt.flatMap {
            Self.isoFormatter.date(from: $0)
        }
        return SheikhAvailability(
            sheikhId: dto.sheikhId,
            status: status,
            updatedAt: updatedAt
        )
    }

    public func requestMeeting(sheikhId: String) async throws
        -> InstantMeetingRequest
    {
        let dto = try await remoteDataSource.createRequest(sheikhId: sheikhId)
            .asyncValue()
        let status = Self.mapStatus(
            dto.status,
            channelName: dto.channelName,
            token: nil,
            userAccount: nil,
            reason: nil
        )
        let expiresAt = dto.expiresAt.flatMap {
            Self.isoFormatter.date(from: $0)
        }
        return InstantMeetingRequest(
            requestId: dto.requestId,
            status: status,
            channelName: dto.channelName,
            expiresAt: expiresAt
        )
    }

    public func cancelMeeting(requestId: String) async throws {
        _ = try await remoteDataSource.cancelRequest(requestId: requestId)
            .asyncValue()
    }

    public func getStudentHistory(page: Int, size: Int) async throws
        -> PageResult<StudentMeetingHistoryItem>
    {
        let dto = try await remoteDataSource.getStudentHistory(
            page: page,
            size: size
        ).asyncValue()

        let items = dto.content.map { item -> StudentMeetingHistoryItem in
            let status = Self.mapStatus(
                item.status,
                channelName: nil,
                token: nil,
                userAccount: nil,
                reason: nil
            )
            let requestedAt = item.requestedAt.flatMap {
                Self.isoFormatter.date(from: $0)
            }
            let acceptedAt = item.acceptedAt.flatMap {
                Self.isoFormatter.date(from: $0)
            }
            let endedAt = item.endedAt.flatMap {
                Self.isoFormatter.date(from: $0)
            }
            return StudentMeetingHistoryItem(
                requestId: item.requestId,
                sheikhId: item.sheikhId,
                sheikhName: item.sheikhName,
                status: status,
                requestedAt: requestedAt,
                acceptedAt: acceptedAt,
                endedAt: endedAt
            )
        }

        return PageResult(
            content: items,
            pageNumber: dto.pageNumber,
            pageSize: dto.pageSize,
            totalElements: dto.totalElements,
            totalPages: dto.totalPages,
            isLast: dto.isLast,
            isFirst: dto.isFirst
        )
    }

    public func getFreshAgoraToken(requestId: String) async throws -> (
        token: String, channelName: String, userAccount: String?
    ) {
        let dto = try await remoteDataSource.getToken(requestId: requestId)
            .asyncValue()
        return (
            token: dto.token, channelName: dto.channelName ?? "",
            userAccount: dto.userAccount
        )
    }

    public func observeRequestUpdates(requestId: String) -> AnyPublisher<
        InstantMeetingStatus, Never
    > {
        realtimeDataSource.subscribeToRequestTopic(requestId: requestId)
            .map { event -> InstantMeetingStatus in
                switch event {
                case .accepted(let dto):
                    return .accepted(
                        channelName: dto.channelName,
                        agoraToken: dto.agoraToken,
                        userAccount: dto.userAccount
                    )
                case .declined(let reason):
                    return .declined(reason: reason)
                case .cancelled:
                    return .cancelled
                case .expired:
                    return .expired
                case .ended:
                    return .ended
                }
            }
            .eraseToAnyPublisher()
    }

    private static func mapStatus(
        _ statusStr: String,
        channelName: String?,
        token: String?,
        userAccount: String?,
        reason: String?
    ) -> InstantMeetingStatus {
        switch statusStr.uppercased() {
        case "ACCEPTED":
            return .accepted(
                channelName: channelName ?? "",
                agoraToken: token ?? "",
                userAccount: userAccount
            )
        case "DECLINED":
            return .declined(reason: reason)
        case "CANCELLED":
            return .cancelled
        case "EXPIRED":
            return .expired
        case "ENDED":
            return .ended
        default:
            return .pending
        }
    }
}

extension AnyPublisher {
    fileprivate func asyncValue() async throws -> Output {
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
                                    userInfo: [
                                        NSLocalizedDescriptionKey:
                                            "Publisher finished without emitting value"
                                    ]
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
