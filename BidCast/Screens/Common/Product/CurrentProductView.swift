//
//  ProductDetailsView.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 13/10/25.
//

import SwiftUI

struct CurrentProductView: View {
    
    let product: ProductDataModel1
    
    @Binding var currentPrice: Double
    @Binding var bidTime: String
    @Binding var userName: String
    @Binding var userImage: String
    @Binding var categoryName : String
    @Binding var hasWon : Bool
    @State var lastBid: Double = 0
    @State var showBidAmount = true
    @State private var animate = true
    var onTap: (() -> Void)?
    var onTapRunNext: (() -> Void)?
    var body: some View {
        
        VStack(alignment: .leading) {
            if let price = product.pricing, let priceInDouble = Double(price) {
                if !userName.isEmpty && currentPrice > priceInDouble {
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
            }
                HStack(spacing: 12) {
                    CustomProfileImage(
                        url: product.images?.first,
                        isCircular: false,
                        cornerRadius: 8.0,
                        size: 80.0
                    )
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(product.title?.capitalizingFirstLetter() ?? "")
                            .font(.custom(poppinsBold, size: 13.0))
                            .foregroundColor(.white)
                        if !categoryName.isEmpty{
                            Text(categoryName)
                                .font(.custom(poppinsSemiBold, size: 12.0))
                                .padding(4)
                                .foregroundColor(.white)
                        }
                        
                        Text("Price : $\(product.pricing ?? "0.0")")
                            .font(.custom(poppinsSemiBold, size: 12.0))
                            .padding(4)
                            .foregroundColor(.white)
                        //                    Text("Quantity : \(product.quantity ?? "")")
                        //                        .font(.custom(poppinsSemiBold, size: 12.0))
                        //                        .padding(4)
                        //                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    //Price and Timer
                    VStack(spacing: 2) {
                        Text("$\(String(format: "%.2f", currentPrice))")
                            .font(.custom(poppinsBold, size: 13))
                            .foregroundColor(.white)
                        if hasWon{
                            Text("sold")
                                .font(.custom(poppinsBold, size: 13))
                                .foregroundColor(.danger)
                        }else{
                            HStack(spacing: 4) {
                                Text("💀")
                                    .font(.custom(poppinsSemiBold, size: 13))
                                
                                Text(bidTime)
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(timeToSeconds(bidTime) < 10 ? .red : .white)
                            }
                        }
                        //                    Text(bidTime)
                        //                        .font(.custom(poppinsSemiBold, size: 13))
                        //                        .foregroundColor(.white)
                    }
                    .frame(width: 100, height: 50)
//                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    
                    
                }
            if hasWon{
                Button(action: {
                    print("Run next tapped")
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
                .background(.defaultTheme)
                .cornerRadius(8)
                .padding(.horizontal,0)
            }
        }
        
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            print("Whole product card tapped!")
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
    func timeToSeconds(_ time: String) -> Int {
        let parts = time.split(separator: ":")
        if parts.count == 2 {
            let minutes = Int(parts[0]) ?? 0
            let seconds = Int(parts[1]) ?? 0
            return minutes * 60 + seconds
        }
        return 0
    }
}

//#Preview {
//    CurrentProductView(product:ProductDataModel1(), currentPrice: .constant(0.0), bidTime: .constant("12"), userName: .constant("teest"), userImage: .constant("sdf"), categoryName: .constant("sfd"), hasWon:false, lastBid:12.0, showBidAmount:true, onTap: {
//        
//    }, onTapRunNext: {
//        
//    })
//}
