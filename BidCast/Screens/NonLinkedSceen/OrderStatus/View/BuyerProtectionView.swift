//
//  BuyerProtectionView.swift
//  BidCast
//
//  Created by JAM_E_329 on 29/05/25.
//

import SwiftUI

struct BuyerProtectionView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "shield.lefthalf.fill")
                .font(.custom(poppinsSemiBold, size: 20))
                .foregroundColor(.defaultTheme)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 4) {
                Text("SwiftBid Buyer Protection")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.black)

                Text("Get full refund if the item is not as described or if it is not delivered.")
                    .font(.system(size: 13))
                    .foregroundColor(.darkGray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
    }
}

