//
//  ReferEarnScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

struct ReferEarnScreen: View {
    @State private var referralLink = "https://bidcast.com/ref/user123"
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 20) {

            // Header
            VStack{
                PrimaryHeader(
                    title: "Refer a Friend".localized,
                    isForLogo : false ,leadingImgArr: [.icBack],
                    trailingImgArr: [.help],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }.frame(height:40)
                .background(.white)


            // Icon
            Image(systemName: "gift.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(Color.blue)
                .padding(.top)

            // Title & Subtitle
            VStack(spacing: 4) {
                Text("Share & Earn Rewards")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                   
                Text("Invite friends and earn rewards when they join")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal)

            // Referral Link Section
            HStack {
                TextField("", text: $referralLink)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(.vertical, 12)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(10)
                    .disabled(true)
                
                Button(action: {
                    UIPasteboard.general.string = referralLink
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                        Text("Copy")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.defaultTheme)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            // How It Works Section
            VStack(alignment: .leading, spacing: 14) {
                Text("How It Works")
                    .fontWeight(.semibold)

                InfoRow(icon: "square.and.arrow.up.fill", iconColor: .blue, title: "Share Your Link", subtitle: "Send your unique referral link to friends")
                InfoRow(icon: "person.2.fill", iconColor: .purple, title: "Friends Join", subtitle: "When they sign up using your link")
                InfoRow(icon: "dollarsign.circle.fill", iconColor: .green, title: "Earn Rewards", subtitle: "Get $10 credit for each friend who joins")
            }
            .padding(.horizontal)

            Spacer()

            // Continue Button
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Continue")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.defaultTheme)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .bottom])
        }
    }
}

struct InfoRow: View {
    var icon: String
    var iconColor: Color
    var title: String
    var subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 30, height: 30)
                .background(iconColor.opacity(0.1))
                .foregroundColor(iconColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                   
                Text(subtitle)
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .frame(width: 340)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

#Preview {
    ReferEarnScreen()
}
