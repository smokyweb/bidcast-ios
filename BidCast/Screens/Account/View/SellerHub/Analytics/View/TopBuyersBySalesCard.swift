//
//  TopBuyersView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/12/25.
//

import SwiftUI

// MARK: - Models


// MARK: - Top Buyers Card View
struct TopBuyersBySalesCard: View {
    let title : String
    let buyers: [TopBuyerBySales]
    let orders: [TopBuyerByOrders]
    let onExportData: () -> Void
    var forBuyers : Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Title
            Text(title)
                .font(.custom(poppinsSemiBold, size: 14.0))
                .foregroundColor(.black)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            
            // Buyers List
            VStack(spacing: 16) {
                if forBuyers{
                    if buyers.isEmpty {
                        EmptyBuyersView()
                    } else {
//                        ForEach(Array(buyers.prefix(3).enumerated()), id: \.element.user_id) { index, buyer in
//                            TopBuyerRow(buyer: buyer, order: TopBuyerByOrders(), rank: index + 1)
//                        }
                        ForEach(Array(buyers.prefix(3).enumerated()), id: \.element.user_id) { index, buyer in
                            VStack(spacing: 0) {
                                TopBuyerRow(
                                    buyer: buyer,
                                    order: TopBuyerByOrders(),
                                    rank: index + 1
                                )

                                if index < buyers.prefix(3).count - 1 {
                                    Divider()
                                        .padding(.top,12)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }else{
                    if orders.isEmpty {
                        EmptyBuyersView()
                    } else {
//                        ForEach(Array(orders.prefix(3).enumerated()), id: \.element.user_id) { index, order in
//                            TopBuyerRow(buyer: TopBuyerBySales(), order: order,forBuyer: false, rank: index + 1)
//                        }
                        ForEach(Array(orders.prefix(3).enumerated()), id: \.element.user_id) { index, order in
                            VStack(spacing: 0) {
                                TopBuyerRow(
                                    buyer: TopBuyerBySales(),
                                    order: order,
                                    forBuyer: false,
                                    rank: index + 1
                                )

                                if index < orders.prefix(3).count - 1 {
                                    Divider()
                                        .padding(.top,12)
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            
            // Export Button
            Button(action: onExportData) {
                Text("Export Data")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.defaultTheme.opacity(0.1))
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.defaultTheme, lineWidth: 2)
                    )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
    }
}

// MARK: - Top Buyer Row
struct TopBuyerRow: View {
    let buyer: TopBuyerBySales
    let order : TopBuyerByOrders?
    var forBuyer : Bool = true
    let rank: Int
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 20)
            if forBuyer{
                // Profile Image
                if let profileURL = buyer.user?.profile_image, !profileURL.isEmpty {
                    AsyncImage(url: URL(string: profileURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.defaultTheme.opacity(0.2))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.defaultTheme.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        )
                }
                
                // Username
                Text(buyer.user?.username ?? buyer.user?.name ?? "Unknown User")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Sales Amount
                Text("$\(buyer.total ?? "0.00")")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
            }else{
                if let profileURL = order?.user?.profile_image, !profileURL.isEmpty {
                    AsyncImage(url: URL(string: profileURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.defaultTheme.opacity(0.2))
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.blue)
                            )
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.defaultTheme.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        )
                }
                
                // Username
                Text(order?.user?.username ?? order?.user?.name ?? "Unknown User")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Sales Amount
                Text("\(order?.total_orders ?? 0)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
            }
        }
    }
}

// MARK: - Empty State
struct EmptyBuyersView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No buyers data available")
                .font(.custom(poppinsSemiBold, size: 16.0))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
    }
}

//#Preview {
//    TopBuyersView()
//}
