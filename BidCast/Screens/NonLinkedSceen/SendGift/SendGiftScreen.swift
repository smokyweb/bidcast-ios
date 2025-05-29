//
//  SendGiftScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

import SwiftUI

struct SendGiftScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var friendSearch = ""
    @State private var giftMessage = ""

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                // Header
                VStack{
                    PrimaryHeader(
                        title: "Send as a Gift".localized,
                        isForLogo : false ,
                        trailingImgArr: [.cancel],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }.frame(height:40)
                .background(.white)

                // Gift icon and title
                VStack(spacing: 8) {
                    Image(systemName: "gift.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red.opacity(0.8))
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())

                    Text("Gift to a Friend")
                        .font(.title3).bold()

                    Text("Send this purchase as a gift to someone special")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                }

                // Friend Search
                VStack(alignment: .leading, spacing: 6) {
                    Text("Find your friend")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    HStack {
                        TextField("Search by username or email", text: $friendSearch)
                            .padding(12)
                            .background(.white)

                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                    .background(Color(.white))
                    .cornerRadius(10)
                }
                .padding(.horizontal)

                // Message
                VStack(alignment: .leading, spacing: 6) {
                    Text("Add a gift message (optional)")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    TextEditor(text: $giftMessage)
                        .frame(height: 100)
//                        .padding(10)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.systemGray4), lineWidth: 0.5)
                        )
                }
                .padding(.horizontal)

                Spacer()

                // Continue Button
                Button(action: {
                    // Continue action
                }) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }

            
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
