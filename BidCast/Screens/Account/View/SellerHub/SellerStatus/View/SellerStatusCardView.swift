//
//  SellerStatusCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 27/05/25.
//

import SwiftUICore

// MARK: - Reusable Card View
struct SellerStatusCardView: View {
    @State var title = ""
    @State var status = ""
    @State var icon = ""
    @State var subtitle = ""
    @State var statusColor = Color.darkGreen
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 16.0))
                Spacer()
                Text(status.capitalizingFirstLetter())
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .frame(width: 80,height: 32)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(10)
                  
            }

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 20, height: 16)
                    .foregroundColor(.gray)
                Text(subtitle)
                    .font(.custom(poppinsRegular, size: 12.0))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .padding([.leading,.trailing] , 12)
    }
}
