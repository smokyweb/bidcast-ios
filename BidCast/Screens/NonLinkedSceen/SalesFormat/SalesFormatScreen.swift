//
//  SalesFormatScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

import SwiftUI

struct SalesFormatScreen: View {
    @State private var selectedFormat: SalesFormat = .auction
    @State private var startingBid: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    @State private var allowOffers: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack{
                PrimaryHeader(
                    title: "Choose Sales Format".localized,
                    isForLogo : false ,leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }.frame(height:40)
                .background(.white)
            
            ScrollView{
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    
                    Text("Set a competitive starting price that will attract potential buyers. A well-priced item increases your chances of a successful sale and can lead to better bidding activity.")
                        .font(.footnote)
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                Spacer()
                VStack(alignment: .leading){
                    // Select Format Label
                    Text("Select Format")
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    // Format Buttons
                    HStack(spacing: 12) {
                        formatButton(title: "Auction", systemImage: "hammer.fill", isSelected: selectedFormat == .auction)
                            .onTapGesture {
                                selectedFormat = .auction
                            }
                        
                        formatButton(title: "Buy It Now", systemImage: "tag.fill", isSelected: selectedFormat == .buyItNow)
                            .onTapGesture {
                                selectedFormat = .buyItNow
                            }
                    }
                    .padding(.horizontal)
                }
                Spacer()
                // Starting Bid
                if selectedFormat == .auction {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Starting Bid")
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("$")
                            TextField("0.00", text: $startingBid)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        
                        Text("Minimum starting bid is $1.00")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                }else{
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Starting Bid")
                            .fontWeight(.semibold)
                        
                        HStack {
                            Text("$")
                            TextField("0.00", text: $startingBid)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                        
                        Text("Minimum starting bid is $1.00")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    VStack(alignment: .leading, spacing: 6) {
                                       Toggle(isOn: $allowOffers) {
                                           Text("Allow Offers")
                                               .fontWeight(.medium)
                                       }

                                       Text("Enable Allow Offers to let buyers offer a different price for your product. You may counter, accept, or simply decline the offer.")
                                           .font(.footnote)
                                           .foregroundColor(.gray)
                                   }
                                   .padding(.horizontal)
                }
                
                Spacer()
            }
                // Continue Button
                Button(action: {
                    // Continue action
                }) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.defaultTheme)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding([.horizontal, .bottom])
                
            
        }
        
    }

    // Format Button View
    private func formatButton(title: String, systemImage: String, isSelected: Bool) -> some View {
        VStack {
            Image(systemName: systemImage)
                .font(.title2)
                .padding(.bottom, 4)
            Text(title)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(12)
    }

    enum SalesFormat {
        case auction, buyItNow
    }
}

#Preview {
    SalesFormatScreen()
}
