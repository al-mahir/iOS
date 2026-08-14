//
//  ActiveCircleRow.swift
//  Home
//
//  Created by Alaa Ayman on 07/02/1448 AH.
//



import SwiftUI
import Common
import Circles

struct ActiveCircleRow: View {
    let circle: CircleModel
    let onJoin: () -> Void

    var body: some View {
        CircleCardView(circle: circle, onJoinTap: onJoin)
    }
}
