//
//  AuctionSheetView.swift
//  BidCast
//
//  Created by JamTech on 12/12/25.
//

import SwiftUI

struct AuctionSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var startingBid: String = "1"
    @State private var selectedRequiredTime: Int = 30
    @State private var selectedCounterBidTime: Int = 10
    @State private var isSuddenDeathEnabled: Bool = false
    
    @State private var showTimeDropdown: Bool = false
    
    let requiredTimeOptions = [15, 30, 45, 60, 90, 120]
    let counterBidTimeOptions = [5, 7, 10]
    
    var onStartAuction: ((String, Int, Int, Bool) -> Void)?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Title
                Text("Auction Settings")
                    .font(.custom(poppinsBold, size: 18))
                    .padding(.top, 12)
                    .padding(.bottom, 12)
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Starting Bid & Required Time
                        HStack(spacing: 12) {
                            startingBidField
                            requiredTimeField
                        }
                        
                        // Counter-Bid Time
                        counterBidTimeSection
                        
                        // Sudden Death
                        suddenDeathSection
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 40)
                }
                
                Spacer()
            }
            
            // Bottom Buttons
            VStack {
                Spacer()
                
                HStack(spacing: 12) {
                    // Cancel Button
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.primary)
//                            .frame(maxWidth: .infinity)
                            .frame(width: 120, height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Start Auction Button
                    Button(action: {
                        onStartAuction?(startingBid, selectedRequiredTime, selectedCounterBidTime, isSuddenDeathEnabled)
                        dismiss()
                    }) {
                        Text("Start Auction")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.defaultTheme, .defaultTheme.opacity(0.9)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.2), radius: 12, x: 0, y: 4)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.systemBackground).opacity(0),
                            Color(.systemBackground)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    .offset(y: -32)
                )
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Starting Bid Field
    private var startingBidField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Starting Bid")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.primary)
            
            HStack {
                Text("$")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.primary)
                
                TextField("1", text: $startingBid)
                    .font(.custom(poppinsRegular, size: 14))
                    .keyboardType(.decimalPad)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Required Time Field
    private var requiredTimeField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Required Time")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.primary)
            
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    showTimeDropdown.toggle()
                }
            }) {
                HStack {
                    Text("\(selectedRequiredTime)s")
                        .font(.custom(poppinsRegular, size: 14))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.custom(poppinsSemiBold, size: 12))
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(showTimeDropdown ? 180 : 0))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
            }
            
            if showTimeDropdown {
                VStack(spacing: 0) {
                    ForEach(requiredTimeOptions, id: \.self) { time in
                        Button(action: {
                            selectedRequiredTime = time
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                showTimeDropdown = false
                            }
                        }) {
                            HStack {
                                Text("\(time)s")
                                    .font(.custom(poppinsRegular, size: 14))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if time == selectedRequiredTime {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 12)
                            .background(time == selectedRequiredTime ? Color.blue.opacity(0.08) : Color.clear)
                        }
                        
                        if time != requiredTimeOptions.last {
                            Divider()
                                .padding(.leading, 12)
                        }
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.15), lineWidth: 1)
                )
                .padding(.top, 4)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
            }
        }
    }
    
    // MARK: - Counter-Bid Time Section
    private var counterBidTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text("Counter-Bid Time")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.primary)
                
                Button(action: {
                    // Show info
                }) {
                    Image(systemName: "info.circle")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Text("When the auction has less than 10 seconds remaining, any new bids will reset the timer to the selected amount.")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 12) {
                ForEach(counterBidTimeOptions, id: \.self) { time in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCounterBidTime = time
                        }
                    }) {
                        Text("\(time)s")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(selectedCounterBidTime == time ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedCounterBidTime == time ? Color.defaultTheme : Color(.systemGray6))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        selectedCounterBidTime == time ? Color.clear : Color.gray.opacity(0.15),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: selectedCounterBidTime == time ? Color.black.opacity(0.15) : Color.clear,
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                            .scaleEffect(selectedCounterBidTime == time ? 1.05 : 1.0)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // MARK: - Sudden Death Section
    private var suddenDeathSection: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Sudden Death")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.primary)
                
                Text("This means when you're down to 00:01, the last person to bid wins!")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
            
            Toggle("", isOn: $isSuddenDeathEnabled)
                .labelsHidden()
                .tint(.black)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}



//#Preview {
//    AuctionSettingsSheet(
//        onStartAuction: { bid, reqTime, counterTime, suddenDeath in
//            print("Starting Bid: $\(bid)")
//            print("Required Time: \(reqTime)s")
//            print("Counter-Bid Time: \(counterTime)s")
//            print("Sudden Death: \(suddenDeath)")
//        }
//    )
//}
