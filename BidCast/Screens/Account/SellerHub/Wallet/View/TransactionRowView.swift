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
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: transaction.isOutgoing ? "arrow.right.arrow.left" : "arrow.left.arrow.right")
                            .foregroundColor(.red)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(transaction.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
 
            Spacer()
 
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 8)
    }
}
 
 
 
