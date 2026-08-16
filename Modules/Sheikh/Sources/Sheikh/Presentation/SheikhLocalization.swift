import Common
import Foundation

@MainActor
internal func localizedSheikhString(_ key: String) -> String {
    LanguageManager.localizedString(key, bundle: .module)
}
