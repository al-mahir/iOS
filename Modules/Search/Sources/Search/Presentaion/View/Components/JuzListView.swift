//
//  JuzListView.swift
//  Search
//
//  Created by Basmala Abuzied Ahmed on 18/07/2026.
//

import SwiftUI
import Common

struct JuzListView: View {
    @Environment(\.dsColors) private var dsColors
    
    let juz: [Juz]
    let onJuzSelected: ((Juz) -> Void)?
    
    public init(juz: [Juz], onJuzSelected: ((Juz) -> Void)? = nil) {
        self.juz = juz
        self.onJuzSelected = onJuzSelected
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.sm) {
            Text("All 30 Juz'")
                .dsFont(DSTypography.titleMedium)
                .foregroundColor(dsColors.textPrimary)
                .padding(.horizontal, DSSpacing.xs)
            
            ForEach(juz) { juzItem in
                JuzListItem(juz: juzItem)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onJuzSelected?(juzItem)
                    }
            }
        }
    }
}
