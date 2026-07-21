//
//  WordsDAO.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 21/07/2026.
//
import SwiftUI

enum TajweedRule: String, CaseIterable, Identifiable {
    case maddObligatory
    case maddMandatory
    case maddPermissible
    case maddNormal
    case ikhfaAndGhunnah
    case idghamAndSilent
    case tafkhim
    case qalqalah

    var id: String { rawValue }

    var title: String {
        switch self {
        case .maddObligatory:   return "Obligatory Madd (6)"
        case .maddMandatory:    return "Mandatory Madd (4-5)"
        case .maddPermissible:  return "Permissible Madd (2/4/6)"
        case .maddNormal:       return "Normal Madd (2)"
        case .ikhfaAndGhunnah:  return "Ikhfa & Ghunnah"
        case .idghamAndSilent:  return "Idgham & Silent"
        case .tafkhim:          return "Tafkhim"
        case .qalqalah:         return "Qalqalah"
        }
    }

    var color: Color {
        switch self {
        case .maddObligatory:   return Color(red: 0.65, green: 0.0, blue: 0.0)
        case .maddMandatory:    return Color(red: 0.90, green: 0.25, blue: 0.20)
        case .maddPermissible:  return Color(red: 0.92, green: 0.50, blue: 0.20)
        case .maddNormal:       return Color(red: 0.90, green: 0.68, blue: 0.20)
        case .ikhfaAndGhunnah:  return Color(red: 0.15, green: 0.60, blue: 0.35)
        case .idghamAndSilent:  return Color(red: 0.55, green: 0.55, blue: 0.55)
        case .tafkhim:          return Color(red: 0.15, green: 0.30, blue: 0.55)
        case .qalqalah:         return Color(red: 0.20, green: 0.50, blue: 0.85)
        }
    }
}
