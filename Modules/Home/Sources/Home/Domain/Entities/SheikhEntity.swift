//
//  SheikhEntity.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//

import Foundation

public struct SheikhEntity: Identifiable {
    public let id = UUID()
    public let initial: String
    public let name: String
    public let rating: Double
    public let isInSession: Bool
}

