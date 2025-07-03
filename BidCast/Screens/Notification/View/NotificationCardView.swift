//
//  NotificationCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 25/06/25.
//

import SwiftUI


struct NotificationCardView: View {
    var title: String
    var message: String
    var timeAgo: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Spacer()

                Text(timeAgo)
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }

            Text(message)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 0)
        .contentShape(Rectangle())
    }
}


extension String {
    func convertToTimeAgo() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = formatter.date(from: self) else {
            return self
        }

        let interval = Date().timeIntervalSince(date)
        let minutes = Int(interval / 60)
        let hours = minutes / 60
        let days = hours / 24

        if minutes < 60 {
            return "\(minutes) min ago"
        } else if hours < 24 {
            return "\(hours) hr ago"
        } else {
            return "\(days) day\(days > 1 ? "s" : "") ago"
        }
    }
}
