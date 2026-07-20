//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 19/07/2026.
//

import SwiftUI

struct AccountOptionsListView: View {
    var body: some View {
        VStack(spacing: 20) {
            AccountOptionRow(title: "عن التطبيق", icon: "info.circle")
            AccountOptionRow(title: "طلب خاصية جديدة", icon: "bubble.left")
            AccountOptionRow(title: "مركز المساعدة", icon: "questionmark.circle")
            AccountOptionRow(title: "شارك التطبيق", icon: "square.and.arrow.up")
            AccountOptionRow(title: "قيم البرنامج", icon: "star")
            
            Divider()
            
            AccountOptionRow(title: "شروط الخدمة", icon: "doc.text")
            AccountOptionRow(title: "سياسة الخصوصية", icon: "lock.shield")
            
            Button(action: {
            }) {
                Text("إلغاء الحساب")
                    .font(.headline)
                    .foregroundColor(Color(red: 181/255, green: 72/255, blue: 77/255)) 
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
        }
    }
}

#Preview {
    AccountOptionsListView()
}
