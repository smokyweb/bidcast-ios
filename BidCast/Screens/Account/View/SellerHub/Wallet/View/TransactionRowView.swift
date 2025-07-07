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
    let transaction: Transaction
 
    var body: some View {
        HStack {
            if isComeFrom != "Wallet"{
                
                        Image("user_dummy" )
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .applyClip(isCircular: true, cornerRadius: 8)
                    
            }
            
//                .fill(Color(.systemGray6))
//                .frame(width: 40, height: 40)
//                .overlay(
//                    Image(systemName: transaction.isOutgoing ? "arrow.right.arrow.left" : "arrow.left.arrow.right")
//                        .foregroundColor(.red)
//                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .foregroundColor(.primary)
                Text(transaction.date, style: .date)
                    .font(.custom(poppinsSemiBold, size: 12.0))
                    .foregroundColor(.gray)
            }
 
            Spacer()
 
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.custom(poppinsSemiBold, size: 14.0))
                .foregroundColor(.darkGreen)
        }
        .padding(.vertical, 8)
    }
}
 
 
 
