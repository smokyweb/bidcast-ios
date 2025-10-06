//
//  TransactionRowView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let amount: Double
    let isOutgoing: Bool
}

import SwiftUI

struct TransactionRowView: View {
    var isComeFrom : String = ""
    let transaction: Tip
    
    var body: some View {
        HStack {
            if isComeFrom != "Wallet"{
                if let urlString = transaction.user?.profileImage, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Image("user_dummy" )
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .applyClip(isCircular: true, cornerRadius: 8)
                }
            }
            
            //                .fill(Color(.systemGray6))
            //                .frame(width: 40, height: 40)
            //                .overlay(
            //                    Image(systemName: transaction.isOutgoing ? "arrow.right.arrow.left" : "arrow.left.arrow.right")
            //                        .foregroundColor(.red)
            //                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.user?.name ?? "")
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .foregroundColor(.primary)
                Text((transaction.createdAt ?? "").stringISOToDate(), style: .date)
                    .font(.custom(poppinsSemiBold, size: 12.0))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(transaction.total?.toDouble ?? 0.0, format: .currency(code: "USD"))
                .font(.custom(poppinsSemiBold, size: 14.0))
                .foregroundColor(.darkGreen)
        }
        .padding(.vertical, 8)
    }
}



