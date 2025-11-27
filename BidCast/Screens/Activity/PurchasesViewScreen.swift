//
//  PurchasesView.swift
//  BidCast
//
//  Created by JamTech on 18/11/25.
//

import SwiftUI

struct PurchasesViewScreen: View {
    var purchaseList: OfferListModel?
    @State private var navigateToUserProfile: Bool = false
    
    @State private var userId: String = ""
    @State private var userImage: String = ""
    @State private var userName: String = ""
    
    @State private var navigateToOrderTracking: Bool = false
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // MARK: - Product Image
            if let imageURL = purchaseList?.product?.images?.first, !imageURL.isEmpty {
                URLImageView(url: imageURL, cornerRadius: 10, height: 80,)
                    .frame(width: 80, height: 80, alignment: .center)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.black.opacity(0.1), lineWidth: 1)
                    )
//                    .padding(.horizontal, 6)
                    .padding(.trailing, 4)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
            }
            
            // MARK: - Order Details
            VStack(alignment: .leading, spacing: 2) {
                // Status Badge
                Text(purchaseList?.status?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsSemiBold, size: 12.0))
                    .foregroundColor(.green)
//                    .padding(.bottom, 2)
                    .padding(.horizontal, 10)
                    .background(.green.opacity(0.2))
//                    .padding(.vertical, 2)
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
                        Text(price.formattedPrice())
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
                    Button {
                        userId = "\(purchaseList?.user?.id ?? 0)"
                        userImage = purchaseList?.user?.profileImage ?? ""
                        userName = purchaseList?.user?.name ?? ""
                        navigateToUserProfile = true
                    } label: {
                        Text(purchaseList?.user?.name ?? "")
                            .font(.custom(poppinsMedium, size: 12.0))
                            .foregroundColor(.blue)
                    }

                   
                }
            }
    
            Spacer()
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.28)) {
                let orderId = "12345"          // set required parameter
                navigateToOrderTracking = true
            }
        }
        
        .padding(4)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        CusNavLink(doNavigate: $navigateToUserProfile,
                   destination: ProfileScreen(id:$userId,
                                              isComeFrom: .constant(""),
                                              userName: $userName,
                                              userImage: $userImage))
        CusNavLink(
            doNavigate: $navigateToOrderTracking,
            destination: OrderTrackingView()
        )

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
//
extension String {
    func formattedPrice() -> String {
        // Remove unwanted characters
        let clean = self.replacingOccurrences(of: "[^0-9.]", with: "", options: .regularExpression)

        // Convert to Double
        guard let value = Double(clean) else { return "$0.00" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }
}
