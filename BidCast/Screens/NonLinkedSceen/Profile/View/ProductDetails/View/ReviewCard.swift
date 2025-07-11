//
//  ReviewCard.swift
//  BidCast
//
//  Created by JAM_E_329 on 11/07/25.
//

import SwiftUI

struct ReviewModel: Identifiable {
    let id = UUID()
    let username: String
    let profileImageName: String 
    let rating: Double
}

struct ReviewCard: View {
    var username: String
    var profileImage: Image
    var rating: Double

    var body: some View {
        HStack(spacing: 12) {
            profileImage
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(username)
                    .font(.headline)

                HStack(spacing: 4) {
                    ForEach(0..<5) { index in
                        Image(systemName: starType(for: index))
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(index < Int(ceil(rating)) ? .defaultTheme : .gray.opacity(0.4))
                    }
                }
            }
            Spacer()
        }
        .padding()
        .background(Color(.white))
        .cornerRadius(12)
    }

    private func starType(for index: Int) -> String {
        if Double(index) + 1 <= rating {
            return "star.fill"
        } else if Double(index) + 0.5 <= rating {
            return "star.lefthalf.fill"
        } else {
            return "star"
        }
    }
}
