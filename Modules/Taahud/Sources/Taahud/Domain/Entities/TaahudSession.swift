import Foundation

/// A 1-based sura/aya, 0-based word position within the muṣḥaf.
public struct MushafPosition: Codable, Equatable, Hashable, Sendable {
    public let sura: Int
    public let aya: Int
    public let wordIdx: Int

    public init(sura: Int, aya: Int, wordIdx: Int = 0) {
        self.sura = sura
        self.aya = aya
        self.wordIdx = wordIdx
    }
}

/// Everything the mobile app is allowed to configure for one session, matching
/// the `start` message fields in API.md §5.2. Every field is optional there;
/// keep that here too so a caller can omit what they have no opinion on.
public struct TaahudSessionConfig: Equatable, Sendable {
    public var position: MushafPosition?
    public var strictness: Strictness
    public var engine: ASREngine?
    /// nil = grade everything (server default). [] is a real choice: ḥifẓ/tashkīl only.
    public var rules: [String]?
    /// Only the moshaf-schema keys the user actually changed.
    public var moshafOverrides: [String: MoshafValue]
    public var includeUnits: Bool

    public init(
        position: MushafPosition? = nil,
        strictness: Strictness = .normal,
        engine: ASREngine? = nil,
        rules: [String]? = nil,
        moshafOverrides: [String: MoshafValue] = [:],
        includeUnits: Bool = false
    ) {
        self.position = position
        self.strictness = strictness
        self.engine = engine
        self.rules = rules
        self.moshafOverrides = moshafOverrides
        self.includeUnits = includeUnits
    }
}

/// A moshaf-schema field value is either a string or an integer (API.md §6).
public enum MoshafValue: Equatable, Sendable {
    case string(String)
    case int(Int)
}

/// The server's ack to `start` (API.md §5.2, "the session ack"). `engine` is
/// the source of truth for what actually ran — always diff it against what
/// was requested.
public struct SessionAck: Equatable, Sendable {
    public let sessionId: String
    public let engine: ASREngine
    public let sampleRate: Int
}

/// Local session lifecycle, distinct from the transport's own state.
public enum TaahudSessionPhase: Equatable, Sendable {
    case idle
    case requestingMicPermission
    case micPermissionDenied
    case connecting
    case active
    case paused
    case ending
    case finished
    case failed(String)
}
