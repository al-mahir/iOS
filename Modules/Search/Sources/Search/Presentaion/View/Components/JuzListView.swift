//
//  JuzListView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//
//
//  JuzListView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI

struct JuzListView: View {
    let juz: [Juz]
    let onJuzSelected: ((Juz) -> Void)?
    
    public init(juz: [Juz], onJuzSelected: ((Juz) -> Void)? = nil) {
        self.juz = juz
        self.onJuzSelected = onJuzSelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All 30 Juz'")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
            
            ForEach(juz.prefix(20)) { juzItem in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Juz' \(juzItem.number)")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("Surah \(juzItem.surahRange) • Page \(juzItem.pageStart)-\(juzItem.pageEnd)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding()
                .background(AppColors.surface)
                .cornerRadius(12)
                .contentShape(Rectangle())
                .onTapGesture {
                    onJuzSelected?(juzItem)
                }
            }
        }
    }
}
