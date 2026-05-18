//
//  ReferralCodeCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct ReferralCodeCardView: View {
    var code: String
    var onShare: () -> Void

    // #50 cmpbdhpmn004g34hglsd8jpns: confirmation toast on copy
    @State private var showCopied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(Image(systemName: "link").foregroundColor(.purple))

                VStack(alignment: .leading, spacing: 2) {
                    Text(AppString.ShareYourLink)
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Text(AppString.InviteSellers)
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.gray)
                }
            }

            HStack {
                Text(code)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Button(action: {
                    UIPasteboard.general.string = code
                    // #50 cmpbdhpmn004g34hglsd8jpns: confirmation toast
                    withAnimation { showCopied = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation { showCopied = false }
                    }
                }) {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .foregroundColor(showCopied ? .green : .gray)
                }
                .padding(.trailing)
            }
            .frame(height: 44)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            Button(action: onShare) {
                Text(AppString.ShareInviteLink)
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .foregroundColor(.white)
                    .cornerRadius(32)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

