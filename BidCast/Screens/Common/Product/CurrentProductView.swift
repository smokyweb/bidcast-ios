//
//  ProductDetailsView.swift
//  BidCast
//
//  Created by JamTech on 13/10/25.
//

import SwiftUI

struct CurrentProductView: View {
    
    let product: ProductData
    
    @Binding var currentPrice: Double
    @Binding var bidTime: String
    @Binding var userName: String
    @Binding var userImage: String
    @Binding var categoryName : String
    @State var hasWon = false
    @State var lastBid: Double = 0
    @State var showBidAmount = true
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if !userName.isEmpty {
                // Text with different colors for username and "Winning"
                HStack(spacing: 0) {
                    CustomProfileImage(url: userImage,isCircular: true,size: 13.0)
                    Text(hasWon ? "\(userName) has " : "\(userName) is ")
                        .foregroundColor(.white)
                        .font(.custom(poppinsRegular, size: 13.0))
                    +
                    Text(hasWon ? "Won" : "Winning")
                        .foregroundColor(.yellow)
                        .font(.custom(poppinsBold, size: 13.0))
                    Spacer()
                    if showBidAmount {
                        (
                            Text("Bid Amount: ")
                                .foregroundColor(.white)
                                .font(.custom(poppinsRegular, size: 13.0))
                            +
                            Text("\(String(format: "%.2f", currentPrice))")
                                .foregroundColor(.yellow)
                                .font(.custom(poppinsBold, size: 13.0))
                        )
                        .transition(.opacity)
                    }
                }
                .onChange(of: currentPrice) { newValue in
                    // Ensure valid positive value (adjust rule if zero is valid)
                    guard newValue > 0 else { return }
                    
                    showBidAmount = true
                    lastBid = newValue
                    
                    // Hide after 1 second unless a newer bid arrives
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        if lastBid == newValue {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showBidAmount = false
                            }
                        }
                    }
                }
                
            }
            
            HStack(spacing: 12) {
                CustomProfileImage(
                    url: product.image,
                    isCircular: false,
                    cornerRadius: 8.0,
                    size: 90.0
                )
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(product.name?.capitalizingFirstLetter() ?? "")
                        .font(.custom(poppinsBold, size: 13.0))
                        .foregroundColor(.white)
                    
                    Text(categoryName)
                        .font(.custom(poppinsSemiBold, size: 12.0))
                        .padding(4)
                        .foregroundColor(.white)
                    
                    Text("Price : $\(product.price ?? "0.0")")
                        .font(.custom(poppinsSemiBold, size: 12.0))
                        .padding(4)
                        .foregroundColor(.white)
                    Text("Quantity : \(product.quantity ?? "")")
                        .font(.custom(poppinsSemiBold, size: 12.0))
                        .padding(4)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                //Price and Timer
                VStack(spacing: 2) {
                    Text("$\(String(format: "%.2f", currentPrice))")
                        .font(.custom(poppinsBold, size: 13))
                        .foregroundColor(.white)
                    
                    Text(bidTime)
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.white)
                }
                .frame(width: 70, height: 50)
                .background(Color.black.opacity(0.3))
                .cornerRadius(10)
            }
        }
        .padding()
    }
}
