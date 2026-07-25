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
    case qalqalah
    case tafkhim
    case idghamAndSilent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .maddObligatory:   return "Obligatory Madd (6)"
        case .maddMandatory:    return "Mandatory Madd (4-5)"
        case .maddPermissible:  return "Permissible Madd (2/4/6)"
        case .maddNormal:       return "Normal Madd (2)"
        case .ikhfaAndGhunnah:  return "Ghunnah"
        case .qalqalah:         return "Qalqalah"
        case .tafkhim:          return "Tafkhim"
        case .idghamAndSilent:  return "Silent Letters"
        }
    }

    var subtitle: String {
        switch self {
        case .maddObligatory:   return "6 Counts"
        case .maddMandatory:    return "4 - 5 Counts"
        case .maddPermissible:  return "2, 4, or 6 Counts"
        case .maddNormal:       return "2 Counts"
        case .ikhfaAndGhunnah:  return "Nun and Meem Mushaddad"
        case .qalqalah:         return "Echoing sound of sukoon"
        case .tafkhim:          return "Heavy pronunciation"
        case .idghamAndSilent:  return "Written but not spoken"
        }
    }

    var color: Color {
        switch self {
        case .maddObligatory:   return Color(red: 0.72, green: 0.11, blue: 0.11)
        case .maddMandatory:    return Color(red: 0.96, green: 0.35, blue: 0.15)
        case .maddPermissible:  return Color(red: 0.95, green: 0.62, blue: 0.10)
        case .maddNormal:       return Color(red: 0.98, green: 0.78, blue: 0.10)
        case .ikhfaAndGhunnah:  return Color(red: 0.22, green: 0.70, blue: 0.29)
        case .qalqalah:         return Color(red: 0.18, green: 0.68, blue: 0.93)
        case .tafkhim:          return Color(red: 0.15, green: 0.22, blue: 0.58)
        case .idghamAndSilent:  return Color(red: 0.60, green: 0.60, blue: 0.60)
        }
    }
}
