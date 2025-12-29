//
//  SalesFormatScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import AlertToast

struct SalesFormatScreen: View {
    @State private var selectedFormat: SalesFormat = .auction
    @State private var startingBid: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var allowOffers: Bool = false
    @State var navigateToProductWeight = false
    @State private var weight: String = ""
    @State private var selectedUnit: String = "lbs"
    @State private var isHazardous: Bool = false
    let unitOptions = ["lbs", "kg", "oz"]
    let quickWeights = ["1 oz", "5 oz", "10 oz", "1 lb", "5 lb", "10 lb"]
    @Binding var request : StoreProductParam
    @Binding var storeScheduleRequest : StoreScheduleShowRequest
    
    @Binding var imageUrls: [String]
    @Binding var videoUrls: [String]
    
    @Binding var thumbNail : String
    @Binding var backToPrepare : Bool
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    
   
    
    
    @State var isTappedFlash: Bool = false
    @State var isTappedAccept: Bool = false
    @State var isTappedReserve: Bool = false
    
    @Binding var fromPrepare : Bool
    @Binding var backToCreateProduct : Bool
    @Binding var productId : String
    var didTapBack : ((Bool) -> Void)?
    var didTapEdit : ((ProductDataModel1) -> Void)?
    var delegate: ShowStepDelegate?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            VStack{
                PrimaryHeader(
                    title: "Sales Format".localized,
                    isForLogo : false ,leadingImgArr: ["chevron.left"],
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
                        .foregroundColor(.defaultTheme)
                    
                    Text("Set a competitive starting price that will attract potential buyers. A well-priced item increases your chances of a successful sale and can lead to better bidding activity.")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.black)
                }
                .padding()
                .background(Color.defaultThemeLight)
                .cornerRadius(12)
                .padding(.horizontal)
                Spacer()
                VStack(alignment: .leading){
                    // Select Format Label
                    Text("Select Format")
                        .font(.custom(poppinsSemiBold, size: 13.0))
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
                
                VStack(alignment: .leading, spacing: 12) {
                    AuthTextField(floatingLabel: "Starting Bid".localized, placeholder: "$0.0".localized, icon: .menuProfile, text: $request.pricing,isIconDisplay : false, isForPrice:true,
                                  custFontName : poppinsSemiBold,
                                  custFontSize : 13.0,
                                  enteredText:  { price in
                        request.pricing = price
                    })
                    .keyboardType(.decimalPad)
                    
                    Text("Minimum starting bid is $1.00")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                        .padding(.horizontal , 16)
                }
                
                if selectedFormat == .auction {
                    VStack(spacing: 12) {
                        EnhancedToggleCard(
                            title: "Reserve for Live",
                            subtitle: "Save for live auction only",
                            icon: "video.fill",
                            iconColor: Color.defaultTheme,
                            isOn: $isTappedReserve
                        )
                    }
                    .padding(.horizontal, 16)
                    .onChange(of: isTappedReserve) { newValue in
                        if newValue {
                            request.reserve_for_live = "1"
                        } else {
                            request.reserve_for_live = "0"
                        }
                    }
                    
                }else{
                    VStack(spacing: 12) {
                        EnhancedToggleCard(
                            title: "Flash Sale",
                            subtitle: "Limited time offer",
                            icon: "bolt.fill",
                            iconColor: Color.defaultTheme,
                            isOn: $isTappedFlash
                        )
                        EnhancedToggleCard(
                            title: "Accept Offers",
                            subtitle: "Allow buyers to make offers",
                            icon: "hand.raised.fill",
                            iconColor: Color.defaultTheme,
                            isOn: $isTappedAccept
                        )
                    }
                    .padding(.horizontal, 16)
                    .onChange(of: isTappedFlash) { newValue in
                        if newValue {
                            request.flash_sale = "1"
                        } else {
                            request.flash_sale = "0"
                        }
                    }
                    .onChange(of: isTappedAccept) { newValue in
                        if newValue {
                            request.accept_offers = "1"
                        } else {
                            request.accept_offers = "0"
                        }
                    }
                }
                
                Spacer()
            }
            // Continue Button
            Button(action: {
                guard !request.pricing.isEmpty else{
                    hudMsg = "Please enter bid amount"
                    showhud = true
                    return
                }
                navigateToProductWeight = true
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
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            }
            
        }
        .edgesIgnoringSafeArea(.bottom)
        CusNavLink(
            doNavigate: $navigateToProductWeight,
            destination: ProductWeightScreen(
                weight: $weight,
                selectedUnit: $selectedUnit,
                isHazardous: $isHazardous,
                unitOptions: unitOptions,
                quickWeights: quickWeights,
                imageUrls : $imageUrls,
                videoUrls: $videoUrls,
                request : $request,storeScheduleRequest: $storeScheduleRequest,
                thumbNail: $thumbNail,
                backToPrepare: $backToPrepare,
                fromPrepare:$fromPrepare,
                backToCreateProduct: $backToCreateProduct,
                productId: $productId,
                didTapBack:{ value in
                    didTapBack?(value)
                },didTapEdit:{ product in
                    didTapEdit?(product)
                },
                delegate:delegate,
                onContinue: {
                    request.pricing = startingBid
                    request.weight = weight + " " + selectedUnit
                    presentationMode.wrappedValue.dismiss()
                }
            )
        )
        
    }
    
    // Format Button View
    private func formatButton(title: String, systemImage: String, isSelected: Bool) -> some View {
        VStack {
            Image(systemName: systemImage)
                .font(.custom(poppinsSemiBold, size: 13.0))
                .padding(.bottom, 4)
            Text(title)
                .font(.custom(poppinsSemiBold, size: 13.0))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.defaultThemeLight : Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
        )
        .cornerRadius(12)
    }
}

enum SalesFormat {
    case auction, buyItNow
}
