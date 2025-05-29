//
//  BoostCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct BoostCardView: View {
    let boost: ShowBoost

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(boost.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(boost.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(boost.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: boost.iconName)
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Button(action: boost.action) {
                Text("Select • \(boost.price)")
                    .fontWeight(.bold)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .foregroundColor(.black)
                    .cornerRadius(20)
            }
        }
        .padding()
        .background(boost.gradient)
        .cornerRadius(20)
    }
}

