//
//  StatView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//


import SwiftUI

// MARK: - StatItem (for UI only)
struct StatItem {
    let label: String
    let value: String
}

// MARK: - StatView
struct StatView: View {
    let stat: StatItem

    var body: some View {
        VStack {
            Text(stat.value)
                .font(.custom(poppinsSemiBold, size: 20.0))
                .bold()
            Text(stat.label)
                .font(.custom(poppinsRegular, size: 11.0))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
