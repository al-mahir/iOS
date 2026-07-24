//
//  MushafPage.swift
//  Mushaf
//
//  Created by Alaa Ayman on 17/07/2026.
//



import Foundation

public struct MushafPage: Identifiable, Hashable {
   
    public let id: Int
    public let lines: [MushafLine]
}
