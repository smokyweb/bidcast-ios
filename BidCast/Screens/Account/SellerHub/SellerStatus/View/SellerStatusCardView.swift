//
//  SellerStatusCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

// MARK: - Reusable Card View
struct SellerStatusCardView: View {
    let section: SellerStatusSection

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(section.title)
                    .fontWeight(.semibold)
                Spacer()
                Text(section.statusText)
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(section.statusColor.opacity(0.2))
                    .foregroundColor(section.statusColor)
                    .cornerRadius(10)
            }

            HStack(alignment: .top, spacing: 8) {
                section.icon
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(.gray)
                Text(section.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding([.leading,.trailing] , 10)
    }
}
