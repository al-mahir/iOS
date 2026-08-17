import Common
import Foundation

@MainActor
internal func localizedSheikhString(_ key: String) -> String {
    LanguageManager.localizedString(key, bundle: .module)
}

public extension SheikhAvailabilityStatus {
    @MainActor
    var localizedTitle: String {
        localizedSheikhString(displayTitle)
    }
}
