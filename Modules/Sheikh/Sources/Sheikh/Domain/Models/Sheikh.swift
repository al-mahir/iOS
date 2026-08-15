//
//  Sheikh.swift
//  Sheikh
//

import Foundation

public struct Sheikh: Codable, Sendable, Equatable, Hashable, Identifiable {
    public let id: String
    public let username: String
    public let firstName: String
    public let lastName: String
    public let email: String
    public let phoneNumber: String?
    public let profilePictureUrl: String?
    public let sheikhStatus: SheikhAvailabilityStatus
    public let rate: Double

    // Enriched detail fields
    public let hasVerifiedIjazah: Bool
    public let targetAudience: String
    public let languages: [String]
    public let qiraat: [String]
    public let experienceYears: Int
    public let biography: String
    public let audioSamples: [SheikhAudioSample]
    public let packages: [SheikhPackage]
    public let reviews: [SheikhReview]
    public let reviewCount: Int
    public var isFavorite: Bool

    public init(
        id: String,
        username: String,
        firstName: String,
        lastName: String,
        email: String,
        phoneNumber: String? = nil,
        profilePictureUrl: String? = nil,
        sheikhStatus: SheikhAvailabilityStatus,
        rate: Double,
        hasVerifiedIjazah: Bool = true,
        targetAudience: String = "Men & Boys 10+",
        languages: [String] = ["Arabic", "Urdu"],
        qiraat: [String] = ["Hafs", "Warsh"],
        experienceYears: Int = 12,
        biography: String =
            "A scholar specialized in Quran sciences, certified with an unbroken chain of transmission (isnad).",
        audioSamples: [SheikhAudioSample] = [],
        packages: [SheikhPackage] = [],
        reviews: [SheikhReview] = [],
        reviewCount: Int = 120,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.profilePictureUrl = profilePictureUrl
        self.sheikhStatus = sheikhStatus
        self.rate = rate
        self.hasVerifiedIjazah = hasVerifiedIjazah
        self.targetAudience = targetAudience
        self.languages = languages
        self.qiraat = qiraat
        self.experienceYears = experienceYears
        self.biography = biography
        self.audioSamples = audioSamples
        self.packages = packages
        self.reviews = reviews
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
    }

    enum CodingKeys: String, CodingKey {
        case id, username, firstName, lastName, email, phoneNumber,
            profilePictureUrl, sheikhStatus, rate
        case hasVerifiedIjazah, targetAudience, languages, qiraat,
            experienceYears, biography, audioSamples, packages, reviews,
            reviewCount, isFavorite
    }

    // Custom decoder: gracefully falls back to defaults for enriched fields
    // that are absent in the basic sheikh list API response.
    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id               = try c.decode(String.self, forKey: .id)
        username         = try c.decode(String.self, forKey: .username)
        firstName        = try c.decode(String.self, forKey: .firstName)
        lastName         = try c.decode(String.self, forKey: .lastName)
        email            = try c.decode(String.self, forKey: .email)
        phoneNumber      = try c.decodeIfPresent(String.self, forKey: .phoneNumber)
        profilePictureUrl = try c.decodeIfPresent(String.self, forKey: .profilePictureUrl)
        sheikhStatus     = try c.decode(SheikhAvailabilityStatus.self, forKey: .sheikhStatus)
        rate             = try c.decode(Double.self, forKey: .rate)
        // Enriched detail fields — absent from the list endpoint, use defaults
        hasVerifiedIjazah = (try? c.decode(Bool.self,   forKey: .hasVerifiedIjazah)) ?? true
        targetAudience    = (try? c.decode(String.self, forKey: .targetAudience))    ?? "Men & Boys 10+"
        languages         = (try? c.decode([String].self, forKey: .languages))       ?? ["Arabic", "Urdu"]
        qiraat            = (try? c.decode([String].self, forKey: .qiraat))          ?? ["Hafs", "Warsh"]
        experienceYears   = (try? c.decode(Int.self,    forKey: .experienceYears))   ?? 12
        biography         = (try? c.decode(String.self, forKey: .biography))         ?? "A scholar specialized in Quran sciences, certified with an unbroken chain of transmission (isnad)."
        audioSamples      = (try? c.decode([SheikhAudioSample].self, forKey: .audioSamples)) ?? []
        packages          = (try? c.decode([SheikhPackage].self,     forKey: .packages))     ?? []
        reviews           = (try? c.decode([SheikhReview].self,      forKey: .reviews))      ?? []
        reviewCount       = (try? c.decode(Int.self,    forKey: .reviewCount))       ?? 0
        isFavorite        = (try? c.decode(Bool.self,   forKey: .isFavorite))        ?? false
    }

    public var fullName: String { "\(firstName) \(lastName)" }

    public var isAvailable: Bool { sheikhStatus == .available }

    public var formattedLanguages: String {
        languages.joined(separator: ", ")
    }

    public var formattedQiraat: String {
        qiraat.joined(separator: ", ")
    }

    public var initials: String {
        let first = firstName.first.map(String.init) ?? ""
        let last = lastName.first.map(String.init) ?? ""
        let combined = "\(first)\(last)".uppercased()
        return combined.isEmpty ? "SA" : combined
    }
}

