//
//  ProductDetailsView.swift
//  BidCast
//
//  Created by Ankit-JAM_E-294 on 13/10/25.
//

import SwiftUI

struct CurrentProductView: View {
    
    let product: ProductDataModel1
    @Binding var auctionTypeId: Int
    @Binding var currentPrice: Double
    @Binding var suddenDeath : Bool
    @Binding var bidTime: String
    @Binding var userName: String
    @Binding var userImage: String
    @Binding var categoryName : String
    @Binding var hasWon : Bool
    @Binding var sellerId : String
    @State var lastBid: Double = 0
    @State var showBidAmount = true
    @State private var animate = true
    // Flips true the first time we observe a non-"00:00" bidTime for the current
    // product. Resets when the product (or auction) changes. Lets us distinguish
    // "timer hasn't started yet" (initial "00:00") from "timer ran and elapsed"
    // ("00:00" again, after one or more ticks). (MC: cmp55p2y8007b56kdfowbf5wr)
    @State private var hasObservedTimerTick: Bool = false
    var onTap: (() -> Void)?
    var onTapRunNext: (() -> Void)?

    // True when the auction bid timer has just elapsed. Used to surface the
    // host-side "Run Next" button even when no buyer ever placed a bid, so the
    // host isn't stuck staring at "00:00". (MC: cmp55p2y8007b56kdfowbf5wr)
    private var isBidTimerEnded: Bool {
        return auctionTypeId != 5
            && hasObservedTimerTick
            && timeToSeconds(bidTime) == 0
    }
    // Show the host-side "Run Next" CTA either when a winner is locked in
    // (existing behaviour) or when the timer ran out with no winner.
    private var shouldShowRunNext: Bool {
        let isHost = sellerId == "\(UserDefaults.userId)"
        return isHost && (hasWon || isBidTimerEnded)
    }
    var body: some View {
        
        VStack(alignment: .leading) {
            if let price = product.pricing, let priceInDouble = Double(price) {
                if !userName.isEmpty /*&& currentPrice > priceInDouble*/ {
                    // Text with different colors for username and "Winning"
                    HStack(spacing: 0) {
                        CustomProfileImage(url: userImage,isCircular: true,size: 13.0)
                        
                        Text(hasWon ? "\(userName) has " : "\(userName) is ")
                            .foregroundColor(.white)
                            .font(.custom(poppinsRegular, size: 13.0))
                        +
                        Text(hasWon ? "Won" : "Winning")
                            .foregroundColor(.defaultTheme)
                            .font(.custom(poppinsBold, size: 13.0))
                        Spacer()
                        if showBidAmount {
                            (
                                Text("Bid Amount: ")
                                    .foregroundColor(.white)
                                    .font(.custom(poppinsRegular, size: 13.0))
                                +
                                Text("\(String(format: "%.2f", currentPrice))")
                                    .foregroundColor(.defaultTheme)
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
                HStack(spacing: 8) {
                    // FIX cmp41hieh00rj4axy15wpcmqz: resolve relative image paths
                    // Android sends images[] as relative paths; prepend base URL.
                    let rawProductImg = product.images?.first(where: { !$0.isEmpty })
                        ?? product.thumbnail?.first(where: { !$0.isEmpty })
                        ?? ""
                    let resolvedProductImg: String = {
                        guard !rawProductImg.isEmpty else { return "" }
                        if rawProductImg.hasPrefix("http") { return rawProductImg }
                        return "https://backend.bidcast.betaplanets.com/" + rawProductImg
                    }()
                    CustomProfileImage(
                        url: resolvedProductImg.isEmpty ? nil : resolvedProductImg,
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
                                .font(.custom(poppinsSemiBold, size: 11.0))
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
                            if userName != ""{
                                Text("Sold")
                                    .font(.custom(poppinsBold, size: 13))
                                    .foregroundColor(.danger)
                            }
                        }else{
                            if auctionTypeId != 5{
                                HStack(spacing: 4) {
                                    if suddenDeath{
                                        Text("💀")
                                            .font(.custom(poppinsSemiBold, size: 13))
                                            .foregroundColor(timeToSeconds(bidTime) < 10 ? .red : .white)
                                    }
                                    
                                    Text(bidTime)
                                        .font(.custom(poppinsSemiBold, size: 13))
                                        .foregroundColor(timeToSeconds(bidTime) < 10 ? .red : .white)
                                }
                            }
                        }
                    }
                    .frame(width: 100, height: 50)
                    .cornerRadius(10)
                    
                    
                }
            if shouldShowRunNext {
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
                .cornerRadius(32)
                .padding(.horizontal,0)
            }
        }
        
        .padding()
        .contentShape(Rectangle())
        .onTapGesture {
            print("Whole product card tapped!")
            onTap?()                  
        }
        // Track the per-product timer lifecycle so the Run Next CTA can fire on
        // "timer elapsed with no winner" without firing during the initial
        // "00:00" before the server sends the first bid_timer_update tick.
        // (MC: cmp55p2y8007b56kdfowbf5wr)
        .onChange(of: bidTime) { newValue in
            if timeToSeconds(newValue) > 0 {
                hasObservedTimerTick = true
            }
        }
        .onChange(of: product.id) { _ in
            hasObservedTimerTick = false
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
