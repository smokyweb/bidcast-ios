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
    @Binding var categoryName : String
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            if !userName.isEmpty {
                // Text with different colors for username and "Winning"
                HStack(spacing: 0) {
                    Text("\(userName) is ")
                        .foregroundColor(.white)
                        .font(.custom(poppinsRegular, size: 13.0))
                    +
                    Text("Winning")
                        .foregroundColor(.yellow)
                        .font(.custom(poppinsBold, size: 13.0))
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
