//
//  File.swift
//  
//
//  Created by Esraa Ehab on 17/07/2026.
//

import Foundation
import SwiftUI

public class SettingsViewModel: ObservableObject {
    
    @Published public var showDeleteRecordingsAlert: Bool = false
    
    public init() {}
    
    public func openMushafLayout() {
        print("Navigate to: هيئة المصحف")
    }
    
    public func openHiddenAyahs() {
        print("Navigate to: الآيات المخفية")
    }
    
    public func openHighlighting() {
        print("Navigate to: تحديد")
    }
    
    public func openLanguageSettings() {
        print("Navigate to: اللغة")
    }
    
    public func openThemeSettings() {
        print("Navigate to: المظهر")
    }
    
    public func openReminders() {
        print("Navigate to: تذكيرات")
    }
    
    public func openMistakesSettings() {
        print("Navigate to: الأخطاء")
    }
    
    public func openSessionControls() {
        print("Navigate to: بدء وإيقاف الجلسة")
    }
    
    public func openConnectionLoss() {
        print("Navigate to: انقطاع الاتصال")
    }
    
    public func openReciters() {
        print("Navigate to: القراء")
    }
    
    public func openTranslations() {
        print("Navigate to: ترجمة")
    }
    
    public func openTafsir() {
        print("Navigate to: تفسير")
    }
    
    public func openDataUsage() {
        print("Navigate to: استخدام البيانات")
    }
    
    public func requestDeleteAllRecordings() {
        showDeleteRecordingsAlert = true
    }
    
    public func executeDeleteAllRecordings() {
        print("Call UseCase to delete all local/remote recordings")
    }
}
