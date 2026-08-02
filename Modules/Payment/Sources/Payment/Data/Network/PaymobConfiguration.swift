//
//  PaymobConfiguration.swift
//  Payment
//
//  Created by Al-Mahir on 31/07/2026.
//

import Foundation

// MARK: - PaymobConfiguration

/// Holds all Paymob credentials needed for wallet & card payment APIs.
public struct PaymobConfiguration: Sendable {

    // MARK: Environment

    public enum Environment: Sendable {
        case production
        case sandbox

        public var baseURL: URL {
            return URL(string: "https://accept.paymob.com/api/")!
        }
    }

    // MARK: Properties

    /// Your Paymob API Key / Secret Key (e.g. `egy_sk_test_...`)
    public let apiKey: String

    /// Paymob Public Key (e.g. `egy_pk_test_...`) if available
    public let publicKey: String

    /// Integration IDs for each wallet provider.
    public let integrationIDs: [WalletProvider: Int]

    /// Integration ID for Credit/Debit Cards (UIG or VPC e.g. 5814327).
    public let cardIntegrationID: Int

    /// The merchant's iframe ID (used for 3DS / card iframe flows).
    public let iframeID: Int

    /// Which environment to use.
    public let environment: Environment

    // MARK: Init

    public init(
        apiKey: String,
        publicKey: String = "",
        integrationIDs: [WalletProvider: Int] = [:],
        cardIntegrationID: Int = 5814327,
        iframeID: Int = 0,
        environment: Environment = .sandbox
    ) {
        self.apiKey            = apiKey
        self.publicKey         = publicKey
        self.integrationIDs    = integrationIDs
        self.cardIntegrationID = cardIntegrationID
        self.iframeID          = iframeID
        self.environment       = environment
    }

    /// The integration ID for a specific wallet provider.
    public func integrationID(for provider: WalletProvider) -> Int? {
        integrationIDs[provider]
    }
}
