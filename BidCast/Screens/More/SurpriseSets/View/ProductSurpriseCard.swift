//
//  ProductSurpriseCard.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 05/02/26.
//

import SwiftUI

// MARK: - Product Surprise Card
struct ProductSurpriseCard: View {
    let data: ProductSurpriseData
    var onManageProducts: (() -> Void)?
    var onPin: (() -> Void)?
    var onTap: (() -> Void)?
    
    @State private var isPinned: Bool = false
    
    private var totalItems: Int {
        data.items?.reduce(0) { $0 + ($1.quantity ?? 0) } ?? 0
    }
    
    private var soldItems: Int {
        data.items?.filter { $0.status == "sold" }.reduce(0) { $0 + ($1.quantity ?? 0) } ?? 0
    }
    
    private var availableItems: Int {
        totalItems - soldItems
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Pin Button
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(data.name?.capitalizingFirstLetter() ?? "Untitled")
                        .font(.custom(poppinsSemiBold, size: 16.0))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    if let price = data.price, data.type == "buy_it_now" {
                        Text("Price: \(Double(price).compactCurrency())")
                            .font(.custom(poppinsRegular,size: 13.0))
                            .foregroundColor(.black)
                    }
                    if let description = data.description, !description.isEmpty {
                        Text(description)
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                VStack(alignment: .trailing){ // Items Counter
                    
                    HStack(spacing: 8) {
                        Image(systemName: "cube.box.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        
                        Text("\(availableItems)/\(totalItems) left")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 16)
                    
                    Button(action: {
                        isPinned.toggle()
                        onPin?()
                    }) {
                        Image(systemName: isPinned ? "pin.fill" : "pin")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.defaultTheme)
                            .frame(width: 24, height: 24)
                            .background(.defaultThemeLight)
                            .clipShape(Circle())
                    }
                    .padding(.horizontal, 12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Type Badge
            if let type = data.type {
                HStack(spacing: 6) {
                    Image(systemName: type == "auction" ? "gavel.fill" : "cart.fill")
                        .font(.system(size: 12))
                    
                    Text(type == "auction" ? "Auction" : "Buy It Now")
                        .font(.custom(poppinsRegular, size: 12))
                }
                .foregroundColor(.defaultTheme)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.defaultThemeLight)
                .cornerRadius(12)
                .padding(.horizontal, 12)
                .padding(.top, 12)
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    onManageProducts?()
                }) {
                    HStack {
                        Text("Manage Products")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .foregroundColor(.defaultTheme)
                        
                        Image(systemName: "chevron.right")
                            .font(.custom(poppinsSemiBold, size: 12))
                            .foregroundColor(.defaultTheme)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.defaultThemeLight)
                    .cornerRadius(12)
                }
                
                Button(action: {
                    onTap?()
                }) {
                    Text("Start Auction")
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.defaultTheme)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
    }
}
