
//
//  ProductDetail.swift
//  BidCast
//
//  Created by TABISH on 17/02/26.
//

import SwiftUI

struct ProductDetail: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: Int = 0
    @State private var showItems: Bool = true
    @State private var showSold: Bool = true
    let surprise: ProductSurpriseData?
    
    private var items: [ProductItemResponse] {
        surprise?.items ?? []
    }
    
    private var availableItems: [ProductItemResponse] {
        items.filter { item in
            let remaining = (item.quantity ?? 0) - (item.soldQuantity ?? 0)
            return remaining > 0 && item.status?.lowercased() != "sold"
        }
    }
    
    private var soldItems: [ProductItemResponse] {
        items.filter { item in
            let remaining = (item.quantity ?? 0) - (item.soldQuantity ?? 0)
            return remaining <= 0 || item.status?.lowercased() == "sold"
        }
    }
    
    private var totalQuantity: Int {
        items.reduce(0) { $0 + ($1.quantity ?? 0) }
    }
    
    private var soldQuantity: Int {
        items.reduce(0) { $0 + ($1.soldQuantity ?? 0) }
    }
    
    private var progressValue: Double {
        guard totalQuantity > 0 else { return 0 }
        return min(max(Double(soldQuantity) / Double(totalQuantity), 0), 1)
    }
    
    var body: some View {
        
        VStack{
            
            PrimaryHeader(
                title: "Surprise Set Detail",
                isForLogo : false, leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
        }
        .frame(height:  50)
        .background(Color.white)
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // MARK: - Title
                VStack(alignment: .leading, spacing: 6) {
                    Text(surprise?.name?.capitalizingFirstLetter() ?? "Surprise Set")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(surprise?.description ?? "No description available")
                        .foregroundColor(.gray)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: progressValue)
                            .tint(.green)
                        
                        Text("\(max(totalQuantity - soldQuantity, 0))/\(totalQuantity) left")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    Text("Starting from \((surprise?.price ?? 0).description.toDouble?.compactCurrency() ?? "$0.00")")
                        .foregroundColor(.gray)
                }
                
                summaryCard
                
                // MARK: - Tabs
                HStack {
                    Button {
                        selectedTab = 0
                    } label: {
                        VStack {
                            Text("Products")
                                .foregroundColor(selectedTab == 0 ? .black : .gray)
                                .fontWeight(.semibold)
                            
                            if selectedTab == 0 {
                                Capsule()
                                    .fill(Color.black)
                                    .frame(height: 3)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedTab = 1
                    } label: {
                        VStack {
                            Text("How it Works")
                                .foregroundColor(selectedTab == 1 ? .black : .gray)
                                .fontWeight(.semibold)
                            
                            if selectedTab == 1 {
                                Capsule()
                                    .fill(Color.black)
                                    .frame(height: 3)
                            } else {
                                Capsule()
                                    .fill(Color.clear)
                                    .frame(height: 3)
                            }
                        }
                    }
                }
                
                // MARK: - Tab Content
                if selectedTab == 0 {
                    productView
                } else {
                    howItWorksView
                }
                
            }
            .padding()
            .background(.background)

        }
        .navigationBarBackButtonHidden(true)

    }
    
}

#Preview {
    NavigationStack {
        ProductDetail(surprise: nil)
    }
}

extension ProductDetail {
    
    var productView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Items Section
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Items (\(availableItems.count))")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: showItems ? "chevron.up" : "chevron.down")
                        .onTapGesture {
                            withAnimation {
                                showItems.toggle()
                            }
                        }
                }
                
                if showItems {
                    if availableItems.isEmpty {
                        Text("No available items")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(availableItems, id: \.id) { item in
                            itemRow(item: item, statusText: "Available")
                        }
                    }
                }
            }
            
            // Sold Section
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Sold (\(soldItems.count))")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: showSold ? "chevron.up" : "chevron.down")
                        .onTapGesture {
                            withAnimation {
                                showSold.toggle()
                            }
                        }
                }
                
                if showSold {
                    if soldItems.isEmpty {
                        Text("No sold items")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(soldItems, id: \.id) { item in
                            itemRow(item: item, statusText: "Sold")
                        }
                    }
                }
            }
            
            Text((surprise?.type ?? "surprise_set").replacingOccurrences(of: "_", with: " ").capitalized)
                .foregroundColor(.gray)
                .padding(.top)
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: 0) {
            HStack {
                Circle()
                    .fill(Color.defaultTheme.opacity(0.14))
                    .overlay(
                        Image(systemName: "gift.fill")
                            .foregroundColor(.defaultTheme)
                    )
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(surprise?.name?.capitalizingFirstLetter() ?? "Surprise Set")
                        .font(.headline)
                    Text("\(totalQuantity) total items")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding()
            
            Divider()
            HStack(spacing: 0) {
                SellerStatView(icon: "shippingbox", value: "\(availableItems.count)", title: "Available")
                
                Divider()
                    .frame(height: 40)
                
                SellerStatView(value: "\(soldItems.count)", title: "Sold")
                
                Divider()
                    .frame(height: 40)
                
                SellerStatView(icon: "dollarsign.circle", value: (surprise?.price ?? 0).description.toDouble?.compactCurrency() ?? "$0.00", title: "Start")
            }
            .frame(height: 70)
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(20)
    }
    
    private func itemRow(item: ProductItemResponse, statusText: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name?.capitalizingFirstLetter() ?? "Item #\(item.id)")
                    .font(.custom(poppinsSemiBold, size: 14))
                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                }
                Text("Qty: \(item.quantity ?? 0) | Sold: \(item.soldQuantity ?? 0)")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(statusText)
                .font(.custom(poppinsSemiBold, size: 12))
                .foregroundColor(statusText == "Sold" ? .gray : .defaultTheme)
        }
        .padding(.vertical, 8)
    }
}

extension ProductDetail {
    
    var howItWorksView: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Surprise items is a format where a set of items are each sold at random — the buyer finds out which of the items they will receive live. You can see all available items in this format in the Items tab.")
            
            Text("What To Expect?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Text("Surprise Sets go through two main stages:")
            
            HStack(alignment: .top) {
                Text("⏳")
                VStack(alignment: .leading) {
                    Text("Filling + Running")
                        .fontWeight(.semibold)
                    
                    Text("The excitement begins! This is the time when you can purchase a surprise item. You can always see how many spots are left and what items have been sold.")
                        .foregroundColor(.gray)
                }
            }
            
            HStack(alignment: .top) {
                Text("✅")
                VStack(alignment: .leading) {
                    Text("Completed")
                        .fontWeight(.semibold)
                    
                    Text("The sale is over. All of the available items have been sold and revealed, and the seller will ship to you as soon as they can.")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct SellerStatView: View {
    var icon: String? = nil
    var value: String
    var title: String
    
    var body: some View {
        VStack(spacing: 4) {
            if let icon = icon {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                    Text(value)
                }
            } else {
                Text(value)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}
