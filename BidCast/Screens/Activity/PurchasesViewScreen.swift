//
//  PurchasesView.swift
//  BidCast
//
//  Created by JamTech on 18/11/25.
//

import SwiftUI

struct PurchasesViewScreen: View {
    var purchaseList: OfferListModel?
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // MARK: - Product Image
            if let imageURL = purchaseList?.product?.images?.first, !imageURL.isEmpty {
                URLImageView(url: imageURL, cornerRadius: 14, height: 80,)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 6)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
            
            // MARK: - Order Details
            VStack(alignment: .leading, spacing: 4) {
                // Status Badge
                Text(purchaseList?.status?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsSemiBold, size: 12.0))
                    .foregroundColor(.green)
                    .padding(.bottom, 2)
                    .padding(4)
                    .background(.green.opacity(0.2))
                    .clipShape(Capsule())
                
                // Product Name
                Text(purchaseList?.product?.title?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsBold, size: 14.0))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                // Price
                HStack(spacing: 4) {
                    Text("Price:")
                        .font(.custom(poppinsBold, size: 12.0))
                        .foregroundColor(.gray)
                    if let price = purchaseList?.product?.pricing {
                        Text("$\(Double(price))")
                            .font(.custom(poppinsBold, size: 12.0))
                            .foregroundColor(.black)
                    }
                }
                
                // Purchase Date
                HStack(spacing: 4) {
                    Text("Purchased:")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.gray)
                    
                    Text(purchaseList?.created_at?.toDateString() ?? "N/A")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.black)
                }
                
                // Seller
                HStack(spacing: 4) {
                    Text("From:")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.gray)
                    
                    Text(purchaseList?.user?.name ?? "")
                        .font(.custom(poppinsMedium, size: 12.0))
                        .foregroundColor(.blue)
                }
            }
    
            Spacer()
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
    
    func formattedDate(_ isoDate: String?) -> String {
        guard let isoDate = isoDate,
              let date = ISO8601DateFormatter().date(from: isoDate) else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

//// MARK: - Preview
//struct OrderItemView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            PurchasesViewScreen(
//                status: "Completed",
//                productName: "ACER charger #34",
//                price: "$15.97",
//                purchaseDate: "12/22/24",
//                seller: "blowout_tech_sales",
//                imageURL: nil
//            )
//            .padding()
//        }
//        .background(Color.gray.opacity(0.1))
//    }
//}

struct PurchasesViewShimmerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            
            // Image shimmer
            PulseShimmerView()
                .frame(width: 80, height: 80)
                .cornerRadius(14)
                .padding(.horizontal, 6)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
            
            VStack(alignment: .leading, spacing: 8) {
                
                // Status shimmer
                PulseShimmerView()
                    .frame(width: 60, height: 14)
                    .cornerRadius(6)
                
                // Product Name shimmer
                PulseShimmerView()
                    .frame(width: 140, height: 14)
                    .cornerRadius(6)
                
                // Price shimmer
                PulseShimmerView()
                    .frame(width: 100, height: 12)
                    .cornerRadius(6)
                
                // Date shimmer
                PulseShimmerView()
                    .frame(width: 120, height: 12)
                    .cornerRadius(6)
                
                // Seller shimmer
                PulseShimmerView()
                    .frame(width: 90, height: 12)
                    .cornerRadius(6)
            }
            
            Spacer()
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}
