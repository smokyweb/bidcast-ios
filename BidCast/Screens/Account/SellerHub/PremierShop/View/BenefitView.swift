//
//  BenefitView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct BenefitView: View {
    let benefit: Benefit

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: benefit.icon)
                .font(.title2)
                .foregroundColor(.red)
            Text(benefit.title)
                .font(.headline)
            Text(benefit.description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

