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
                .font(.custom(poppinsSemiBold, size: 18.0))
                .foregroundColor(.red)
            Text(benefit.title)
                .font(.custom(poppinsSemiBold, size: 13.0))
            Text(benefit.description)
                .font(.custom(poppinsRegular, size: 12.0))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .aspectRatio(1, contentMode: .fill)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

