//
//  KeychainTokenStore.swift
//  Authentication
//
//  Created by Nadin Ahmed on 18/07/2026.
//
import Foundation
import Security

final class KeychainTokenStore: TokenStoring {

    private enum Key {
        static let accessToken  = "com.almahir.auth.accessToken"
        static let refreshToken = "com.almahir.auth.refreshToken"
    }

    func saveTokens(accessToken: String, refreshToken: String) throws {
        try save(value: accessToken,  forKey: Key.accessToken)
        try save(value: refreshToken, forKey: Key.refreshToken)
    }

    func getAccessToken()  -> String? { load(forKey: Key.accessToken) }
    func getRefreshToken() -> String? { load(forKey: Key.refreshToken) }

    func clearTokens() {
        delete(forKey: Key.accessToken)
        delete(forKey: Key.refreshToken)
    }

    // MARK: - Private Keychain helpers

    private func save(value: String, forKey key: String) throws {
        guard let data = value.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        let attrs: [CFString: Any] = [kSecValueData: data]

        let updateStatus = SecItemUpdate(query as CFDictionary, attrs as CFDictionary)

        if updateStatus == errSecItemNotFound {
            // Item doesn't exist yet — add it
            var addQuery = query
            addQuery[kSecValueData] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.saveFailed(addStatus)
            }
        } else if updateStatus != errSecSuccess {
            throw KeychainError.saveFailed(updateStatus)
        }
    }

    private func load(forKey key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(forKey key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}

// MARK: - Error

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    var errorDescription: String? {
        if case .saveFailed(let status) = self {
            return "Keychain write failed (OSStatus \(status))"
        }
        return nil
    }
}
