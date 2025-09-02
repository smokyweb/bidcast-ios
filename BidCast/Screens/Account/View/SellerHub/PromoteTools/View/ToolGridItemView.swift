//
//  ToolGridItemView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUI

struct ToolGridItemView: View {
    let feature: Feature

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: feature.icon ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            } placeholder: {
                ProgressView()
                    .frame(width: 24, height: 24)
            }
            
            Text(feature.title ?? "")
                .font(.custom(poppinsSemiBold, size: 16.0))
            
            Text(feature.description ?? "")
                .font(.custom(poppinsRegular, size: 14.0))
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
