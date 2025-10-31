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
    var profileImage: String
    var rating: Double
    var comment: String? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 1. Profile image
            CustomProfileImage(url: profileImage, isCircular: true, size: 70)

            // 2. Labels + Rating
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    // Username
                    Text(username)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    // Star Rating (Right aligned)
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: starType(for: index))
                                .resizable()
                                .frame(width: 12, height: 12)
                                .foregroundColor(index < Int(floor(rating)) ? .defaultTheme : .gray.opacity(0.4))
                        }
                    }
                }

                // Comment below
                if let comment = comment, !comment.isEmpty {
                    Text(comment)
                        .font(.system(size: 13))
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
        .background(.white)
        .cornerRadius(12)
        .padding(.horizontal)
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



