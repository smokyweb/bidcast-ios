//
//  ProductDetailSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import AlertToast

struct ProductDetailSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var showBuyNowSheet = false
    @State private var showMakeOfferSheet = false

    var userProfile: String
    var userName: String
    var verifiedOrNot: String
    var productImage: Image
    var productTitle: String
    var productPrice: Double
    var condition: String
    var location: String
    var postedTime: String
    var sellerName: String
    var sellerStatus: String

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            .padding()

            // Seller Info
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
                    .overlay(Text("S").font(.caption).bold())
                VStack(alignment: .leading) {
                    Text(sellerName).font(.subheadline.bold())
                    Text(sellerStatus).font(.caption).foregroundColor(.gray)
                }
                Spacer()
            }
            .padding(.horizontal)

            // Product Image
            productImage
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxHeight: 300)

            // Product Info
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(productTitle)
                        .font(.headline)
                    Spacer()
                    Text("$\(Int(productPrice))")
                        .font(.title3.bold())
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Condition")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(condition)
                            .font(.caption)
                    }

                    HStack {
                        Text("Location")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(location)
                            .font(.caption)
                    }

                    HStack {
                        Text("Posted")
                            .font(.caption.bold())
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text(postedTime)
                            .font(.caption)
                    }
                }

            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)

            Spacer()

            // Bottom Buttons
            HStack(spacing: 16) {
                Button(action: {
                    showBuyNowSheet.toggle()
                }) {
                    Text("Buy Now")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
                  .bottomSheet(isPresented: $showBuyNowSheet, height: screenHeight * 0.85) {
                           MakeOfferBottomSheet(
                               isPresented: $showBuyNowSheet,
                               listedPrice: productPrice,
                               offerOptions: [1039, 1104, 1169, 1234]
                           ) { selectedOffer in
                               print("User selected offer: \(selectedOffer ?? 0)")
                           }
                       }
                Button(action: {
                    showMakeOfferSheet.toggle()
                }) {
                    Text("Make Offer")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }
            }
            .padding()
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onFirstAppear {
            self.isLoading = true
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
}

