//
//  CurrentSurpriseSetView.swift
//  BidCast
//
//  Created by Ankit-JAM_E-294 on 06/02/26.
//

import SwiftUI

struct CurrentSurpriseSetView: View {
    
    let surpriseSet: ProductSurpriseData
    @Binding var currentPrice: Double
    @Binding var suddenDeath: Bool
    @Binding var bidTime: Int
    @Binding var userName: String
    @Binding var userImage: String
    @Binding var hasWon: Bool
    @Binding var sellerId: String
    
    @State var lastBid: Double = 0
    @State var showBidAmount = true
    @State private var animate = true
    
    var onTap: (() -> Void)?
    var onTapRunNext: (() -> Void)?
    
    // Computed properties
    private var totalItems: Int {
        surpriseSet.items?.reduce(0) { $0 + ($1.quantity ?? 0) } ?? 0
    }
    
    private var soldItems: Int {
        surpriseSet.items?.reduce(0) { $0 + ($1.soldQuantity ?? 0) } ?? 0
    }
    
    private var availableItems: Int {
        totalItems - soldItems
    }
    
    private var isAuctionType: Bool {
        surpriseSet.type == "auction"
    }
    
    private var formattedBidTime: String {
        let minutes = bidTime / 60
        let seconds = bidTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // MARK: - Winner/Bidding Status
            if let price = surpriseSet.price {
                if !userName.isEmpty {
                    HStack(spacing: 4) {
                        CustomProfileImage(url: userImage, isCircular: true, size: 13.0)
                        
                        Text(hasWon ? "\(userName) has " : "\(userName) is ")
                            .foregroundColor(.white)
                            .font(.custom(poppinsRegular, size: 13.0))
                        +
                        Text(hasWon ? "Won" : "Winning")
                            .foregroundColor(.defaultTheme)
                            .font(.custom(poppinsBold, size: 13.0))
                        
                        Spacer()
                        
                        if showBidAmount && isAuctionType {
                            (
                                Text("Bid Amount: ")
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsRegular, size: 13.0))
                                +
                                Text("$\(String(format: "%.2f", currentPrice))")
                                    .foregroundColor(.defaultTheme)
                                    .font(.custom(poppinsBold, size: 13.0))
                            )
                            .transition(.opacity)
                        }
                    }
                    .onChange(of: currentPrice) { newValue in
                        guard newValue > 0 else { return }
                        
                        showBidAmount = true
                        lastBid = newValue
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            if lastBid == newValue {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    showBidAmount = false
                                }
                            }
                        }
                    }
                }
            }
            
            // MARK: - Surprise Set Info
            HStack(spacing: 12) {
                
                // Surprise Set Icon/Image
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.defaultThemeLight)
                        .frame(width: 80, height: 80)
                    
                    VStack(spacing: 4) {
                        Image(systemName: "gift.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.defaultTheme)
                        
                        Text("\(availableItems)/\(totalItems)")
                            .font(.custom(poppinsSemiBold, size: 11))
                            .foregroundColor(.defaultTheme)
                    }
                }
                
                // Details
                VStack(alignment: .leading, spacing: 4) {
                    // Title
                    Text(surpriseSet.name?.capitalizingFirstLetter() ?? "Surprise Set")
                        .font(.custom(poppinsBold, size: 14.0))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(surpriseSet.description?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Price
                    Text("Quantity: \(surpriseSet.items?.first?.quantity ?? 0)")
                        .font(.custom(poppinsSemiBold, size: 11.0))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Price and Timer
                VStack(spacing: 4) {
                    Text("$\(String(format: "%.2f", currentPrice))")
                        .font(.custom(poppinsBold, size: 14))
                        .foregroundColor(.white)
                    
                    if hasWon {
                        if !userName.isEmpty {
                            Text("Sold")
                                .font(.custom(poppinsBold, size: 13))
                                .foregroundColor(.danger)
                        }
                    } else {
                        if isAuctionType {
                            HStack(spacing: 4) {
                                if suddenDeath {
                                    Text("💀")
                                        .font(.custom(poppinsSemiBold, size: 13))
                                }
                                
                                Text(formattedBidTime)
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(bidTime < 10 ? .red : .white)
                            }
                        }
                    }
                }
                .frame(width: 90)
            }
            
            // MARK: - Run Next Button
            if hasWon && (sellerId == "\(UserDefaults.userId)") {
                Button(action: {
                    print("Run next surprise set tapped")
                    onTapRunNext?()
                }) {
                    HStack(spacing: 6) {
                        Text("Run Next")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.white)
                        
                        chevronAnimation(offset: 3)
                        chevronAnimation(offset: 6)
                    }
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                }
                .background(Color.defaultTheme)
                .cornerRadius(32)
            }
        }
        .padding(12)
        .contentShape(Rectangle())
        .onTapGesture {
            print("Surprise set card tapped!")
            onTap?()
        }
    }
    
    @ViewBuilder
    private func chevronAnimation(offset: CGFloat) -> some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(.black)
            .opacity(animate ? 1 : 0.2)
            .offset(x: animate ? offset : 0)
    }
}
