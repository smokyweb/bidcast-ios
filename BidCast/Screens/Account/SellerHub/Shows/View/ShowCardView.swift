//
//  ShowCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

// MARK: - Show Card View
struct ShowCardView: View {
    let show: Show

    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 5) {
                Text(show.title)
                    .fontWeight(.semibold)

                Text(show.date)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Label(show.time, systemImage: "clock")
                        .font(.caption)
                    Label("\(show.rsvps) RSVPs", systemImage: "person.3")
                        .font(.caption)
                }
            }
            Spacer()
            Image(systemName: "ellipsis")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
