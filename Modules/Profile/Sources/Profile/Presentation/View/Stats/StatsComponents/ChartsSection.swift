//
//  SwiftUIView.swift
//  
//
//  Created by Esraa Ehab on 20/07/2026.
//

import SwiftUI

struct ChartsSection: View {
    let primaryGreen: Color
    
    var body: some View {
        VStack(spacing: 16) {
            ChartCard(title: "Pages", primaryGreen: primaryGreen)
            ChartCard(title: "Total time Ta'ahud the Quran", primaryGreen: primaryGreen)
        }
    }
}
