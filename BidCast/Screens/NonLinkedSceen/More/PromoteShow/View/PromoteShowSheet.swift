//
//  PromoteShowSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct ShowBoost: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let price: String
    let iconName: String
    let gradient: LinearGradient
    let action: () -> Void
}

struct PromoteShowSheet: View {
    let boosts: [ShowBoost]
    var onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Promote Show")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(boosts) { boost in
                        BoostCardView(boost: boost)
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}
