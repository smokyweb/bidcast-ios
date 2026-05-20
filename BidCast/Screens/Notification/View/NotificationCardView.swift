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
    // QA #39 — typed icon per notification kind (purchase / sold / message / bid / order / generic).
    // Backend wave-4 fans these out via the notifications API; iOS just needs to render them distinguishably.
    var type: String? = nil
    // QA #39 — unread highlight: when the backend marks is_seen=0, surface that visually.
    var isUnread: Bool = false
    
    private var iconForType: String {
        switch (type ?? "").lowercased() {
        case let t where t.contains("purchase") || t.contains("order"):
            return "bag.fill"
        case let t where t.contains("sold") || t.contains("sale"):
            return "dollarsign.circle.fill"
        case let t where t.contains("message") || t.contains("chat"):
            return "bubble.left.and.bubble.right.fill"
        case let t where t.contains("bid") || t.contains("offer"):
            return "hammer.fill"
        case let t where t.contains("follow"):
            return "person.crop.circle.badge.plus"
        case let t where t.contains("show") || t.contains("stream") || t.contains("live"):
            return "dot.radiowaves.left.and.right"
        default:
            return "bell.fill"
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // QA #39 — leading icon disc varies by notification type so users can tell categories apart.
            ZStack {
                Circle()
                    .fill(Color.defaultTheme.opacity(isUnread ? 0.18 : 0.10))
                    .frame(width: 36, height: 36)
                Image(systemName: iconForType)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.defaultTheme)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(title)
                        // QA #39 — bolder weight when unread.
                        .font(.custom(isUnread ? poppinsBold : poppinsSemiBold, size: 14))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    if isUnread {
                        Circle()
                            .fill(Color.defaultTheme)
                            .frame(width: 7, height: 7)
                    }
                    Spacer()
                    Text(timeAgo)
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                }
                Text(message)
                    .font(.custom(poppinsRegular, size: 13))
                    .foregroundColor(isUnread ? .primary : .gray)
            }
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
