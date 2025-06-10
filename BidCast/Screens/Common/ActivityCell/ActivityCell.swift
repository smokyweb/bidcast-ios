//
//  ActitivityCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 13/05/25.
//

import SwiftUI

struct ActivityCell: View {
    var offerListing: OfferListModel?
    var isFor: String?
    var onDecline: (() -> Void)?
    var onAccept: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 10) {
            // ── First row ─────────────────────────────
            if isFor == "Message" || isFor == "Bids" || isFor == "Offers" || isFor == "OffersScreen" {
                HStack(alignment: .center, spacing: 10) {
                    AsyncImage(url: URL(string: offerListing?.user?.profileImage ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .padding(.leading, 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TitleWithLine(title: offerListing?.user?.name ?? "Unknown", lineLength: 0, textColor: .black, fontName: robotoMedium, fontValue: 16, divderHeight: 0)
                        if let dateString = offerListing?.createdAt,
                           let date = parseISO8601Date(dateString) {
                            let timeAgo = timeAgoSinceDate(date)
                            TitleWithLine(title: "Placed an Offer • \(timeAgo)", lineLength: 0, textColor: .lightGray, fontName: robotoRegular, fontValue: 14, divderHeight: 0)
                    
                        }
                    }

                    if isFor != "OffersScreen" {
                        Spacer()
                        Text("₹\(offerListing?.amount ?? 0)")
                            .font(.custom(poppinsSemiBold, fixedSize: 12.0))
                            .foregroundStyle(.text)
                            .foregroundColor(.black)
                            .padding(.trailing, 12)
                    }
                }
                .frame(height: 50)
                .padding([.top, .bottom], 12)
            }
            
            // ── Second row ─────────────────────────────
            if isFor == "Bids" || isFor == "Offer" || isFor == "Purchases" || isFor == "Saved Items" || isFor == "Offers" || isFor == "OffersScreen"  {
                HStack(alignment: .center, spacing: 10) {
                    AsyncImage(url: URL(string: offerListing?.product?.images?.first ?? "")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray.opacity(0.2)
                    }
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                    .padding(.leading, 16)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        TitleWithLine(title: offerListing?.product?.title ?? "Product", lineLength: 0, textColor: .black, fontName: robotoMedium, fontValue: 16, divderHeight: 0)
                        TitleWithLine(title: "Asking Price: ₹\(offerListing?.product?.pricing ?? 0)", lineLength: 0, textColor: .lightGray, fontName: robotoRegular, fontValue: 14, divderHeight: 0)
                        
                        if isFor == "OffersScreen" {
                            TitleWithLine(title: "Placed on: \(formattedDate(offerListing?.createdAt))", lineLength: 0, textColor: .lightGray, fontValue: 12, divderHeight: 0)
                        }
                    }
                    
                    if isFor != "OffersScreen" && isFor !=  "Offers"{
                        
                        SingleTitleLabel(title: "₹\(offerListing?.amount ?? 0)", lineLength: 0, textColor: .success, fontValue: 12)
                            .padding(.trailing, 8)
                        
                    }
                }
                .padding([.top, .bottom], 16)
            }

            // ── Third row ─────────────────────────────
            if isFor == "Offers" || isFor == "OffersScreen" {
                HStack(alignment: .center, spacing: 10) {
                    // Assuming TwoButton supports actions
                    TwoButton(
                        onFirstButtonClick: { onDecline?() },
                        onSecButtonClick: { onAccept?() }
                    )
                }
                .frame(height: 50)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .cornerRadius(12)
        .padding(5)
        .shadow(color: Color(.squirrelGrey).opacity(0.5), radius: 2, x: 0, y: 0)
    }

    func formattedDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate,
              let date = ISO8601DateFormatter().date(from: isoDate) else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

func timeAgoSinceDate(_ date: Date) -> String {
    let now = Date()
    let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date, to: now)
    
    if let year = components.year, year > 0 {
        return "\(year) year\(year > 1 ? "s" : "") ago"
    }
    if let month = components.month, month > 0 {
        return "\(month) month\(month > 1 ? "s" : "") ago"
    }
    if let day = components.day, day > 0 {
        return "\(day) day\(day > 1 ? "s" : "") ago"
    }
    if let hour = components.hour, hour > 0 {
        return "\(hour)h ago"
    }
    if let minute = components.minute, minute > 0 {
        return "\(minute)m ago"
    }
    return "Just now"
}


func parseISO8601Date(_ dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter.date(from: dateString)
}
