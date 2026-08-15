//
//  CircleMappers.swift
//  Circles
//
//  Created by Nadin Ahmed on 03/08/2026.
//

import Foundation

// MARK: - ISO-8601 Date Decoder (shared, internal)

private let iso8601Decoder: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    f.locale = Locale(identifier: "en_US_POSIX")
    f.timeZone = TimeZone(secondsFromGMT: 0)
    return f
}()

private func parseDate(_ string: String) -> Date {
    let formatsToTry = [
        "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
        "yyyy-MM-dd'T'HH:mm:ssZ",
        "yyyy-MM-dd'T'HH:mm:ss",
        "yyyy-MM-dd'T'HH:mm:ss.SSS",
    ]
    for format in formatsToTry {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = formatter.date(from: string) {
            return date
        }
    }
    if let date = ISO8601DateFormatter().date(from: string) {
        return date
    }
    return Date(timeIntervalSince1970: 0)
}

// MARK: - CircleDTO → Circle

extension CircleDTO {
    func toDomain() -> CircleModel {
        CircleModel(
            id: circleId,
            name: name,
            startDate: parseDate(startDate),
            endDate: parseDate(endDate),
            status: CircleStatus(rawValue: status) ?? .scheduled,
            type: CircleType(rawValue: type) ?? .public,
            requiresApproval: requiresApproval,
            maxParticipants: maxParticipants,
            channelName: channelName,
            ownerId: ownerId,
            memberCount: memberCount,
            inviteToken: inviteToken
        )
    }
}

// MARK: - PageDTO<CircleDTO> → CirclePage<Circle>

extension PageDTO where T == CircleDTO {
    func toDomain() -> CirclePage<CircleModel> {
        CirclePage(
            items: content.map { $0.toDomain() },
            totalElements: totalElements,
            totalPages: totalPages,
            currentPage: number,
            isFirst: first,
            isLast: last
        )
    }
}

// MARK: - CircleMemberDTO → CircleMember

extension CircleMemberDTO {
    func toDomain() -> CircleMember {
        CircleMember(
            id: id,
            username: username,
            status: CircleMembershipStatus(rawValue: status) ?? .active,
            joinedAt: parseDate(joinedAt)
        )
    }
}

// MARK: - PageDTO<CircleMemberDTO> → CirclePage<CircleMember>

extension PageDTO where T == CircleMemberDTO {
    func toDomain() -> CirclePage<CircleMember> {
        CirclePage(
            items: content.map { $0.toDomain() },
            totalElements: totalElements,
            totalPages: totalPages,
            currentPage: number,
            isFirst: first,
            isLast: last
        )
    }
}

// MARK: - CircleJoinResponseDTO → CircleMembership

extension CircleJoinResponseDTO {
    func toDomain() -> CircleMembership {
        CircleMembership(
            membershipId: membershipId,
            circleId: circleId,
            userId: userId,
            status: CircleMembershipStatus(rawValue: status) ?? .pending,
            requestedAt: parseDate(requestedAt)
        )
    }
}

// MARK: - PendingJoinRequestDTO → PendingJoinRequest

extension PendingJoinRequestDTO {
    func toDomain() -> PendingJoinRequest {
        PendingJoinRequest(
            userId: userId,
            username: username,
            requestedAt: parseDate(requestedAt)
        )
    }
}

// MARK: - PageDTO<PendingJoinRequestDTO> → CirclePage<PendingJoinRequest>

extension PageDTO where T == PendingJoinRequestDTO {
    func toDomain() -> CirclePage<PendingJoinRequest> {
        CirclePage(
            items: content.map { $0.toDomain() },
            totalElements: totalElements,
            totalPages: totalPages,
            currentPage: number,
            isFirst: first,
            isLast: last
        )
    }
}

// MARK: - AgoraTokenDTO → AgoraToken

extension AgoraTokenDTO {
    func toDomain() -> AgoraToken {
        AgoraToken(token: token, uid: uid, channelName: channelName)
    }
}
