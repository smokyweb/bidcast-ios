//
//  BenefitView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
// MARK: - Benefit View
struct BenefitView: View {
    let benefit: PremierFeatureModel
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            AsyncImage(url: URL(string: benefit.icon ?? "")) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "star.fill")
                    .foregroundColor(.defaultTheme)
            }
            .frame(width: 32, height: 32)
            
            Text(benefit.title ?? "")
                .font(.custom(poppinsMedium, size: 16))
            Text(benefit.description ?? "")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity,maxHeight: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
