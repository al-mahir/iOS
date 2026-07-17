//
//  File.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import Foundation
import SwiftUI

public class SettingsViewModel: ObservableObject {
    // Profile Data (Mocked)
    @Published public var userName: String = "Loading..."
    @Published public var userEmail: String = ""
    
    //Preferences
    @Published public var isDarkMode: Bool = false
    @Published public var mushafFontSize: Double = 18.0
    
    public init() {
        fetchMockProfile()
    }
    
    private func fetchMockProfile() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.userName = "Esraa"
            self.userEmail = "esraa@example.com"
        }
    }
    
    // Actions
    public func changePassword() {
        print("Navigate to Change Password Screen")
    }
    
    public func deleteAccount() {
        print("Trigger Delete Account Flow - Requires Backend Pipeline")
    }
    
    public func downloadPrivacyData() {
        print("Trigger Privacy Data Download")
    }
    
    public func logout() {
        print("Clear Session and Navigate to Auth Screen")
    }
}
