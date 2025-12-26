//
//  ShowDetailsScreen.swift
//  BidCast
//
//  Created by JamTech on 26/12/25.
//

import SwiftUI

struct ShowDetailsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Show Data
    @State var show: ShowModel
    @State var products: [ProductDataModel1] = []
    
    // States
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Show Header Card
                    showHeaderCard
                    
                    // Basic Info Card
                    basicInfoCard
                    
                    // Content Info Card
                    contentInfoCard
                    
                    // Added Products Card
                    addedProductsCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            
            // Bottom Action Buttons
            bottomActionButtons
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .onAppear {
            self.products = ProductDataModel1.sampleProducts
        }
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Show Details")
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Show Header Card
    private var showHeaderCard: some View {
        HStack(spacing: 16) {
            // Show Thumbnail
            if let thumbnail = show.thumbnail {
                CustomProfileImage(url: thumbnail, isCircular: false, size: 100)
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                    )
            }
            
            // Show Info
            VStack(alignment: .leading, spacing: 6) {
                Text(show.title ?? "Show Title")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(show.category?.name ?? "Category")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
//                    Image(systemName: "calendar")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
                    
                    Text(formatDate(show.date?.formattedDate() ?? "12-22-2025"))
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
//                    Image(systemName: "clock")
//                        .font(.system(size: 12))
//                        .foregroundColor(.secondary)
                    
                    Text(show.time ?? "12:00 AM")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Basic Info Card
    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                InfoRowView(
                    label: "Auction Type",
                    value: show.auctionType?.name ?? "Live Auction"
                )
                
                InfoRowView(
                    label: "Repeat Mode",
                    value: show.isRepeat == true ? show.repeatValue ?? "None" : "None"
                )

                
                InfoRowView(
                    label: "Discoverability",
                    value: show.showDiscoverability?.capitalized ?? "Public"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Content Info Card
    private var contentInfoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content Info")
                .font(.custom(poppinsBold, size: 18))
                .foregroundColor(.primary)
            
            VStack(spacing: 8) {
                InfoRowView(
                    label: "Explicit Content",
                    value: show.isExplicit == true ? "Yes" : "No"
                )
                
                InfoRowView(
                    label: "Primary Language",
                    value: show.language?.capitalized ?? "English"
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Added Products Card
    private var addedProductsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Added Products")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(products.count)/100")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.secondary)
            }
            
            if products.isEmpty {
                emptyProductsView
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(products.enumerated()), id: \.element.id) { index, product in
                        ProductRowItem(product: product)
                            .padding(.vertical, 8)
                        if index < products.count - 1 {
                            Divider()
//                                .padding(.leading, 90)
                                .frame(height: 2)
                        }
                    }
                }
            }
            
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // MARK: - Empty Products View
    private var emptyProductsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cube.box")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.4))
            
            Text("No Products Added")
                .font(.custom(poppinsMedium, size: 16))
                .foregroundColor(.secondary)
            
            Text("Add products to your show")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    // MARK: - Bottom Action Buttons
    private var bottomActionButtons: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Edit Show Button
                Button(action: {
                    // Handle edit show
                }) {
                    Text("Edit Show")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.defaultTheme)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 34)
                                .fill(Color.defaultTheme.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 34)
                                .stroke(Color.defaultTheme, lineWidth: 1.5)
                        )
                }
                
                // Start Show Button
                Button(action: {
                    // Handle start show
                }) {
                    Text("Start Show")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 34)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(color: Color.defaultTheme.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helper Functions
    private func formatDate(_ dateString: String) -> String {
        // Format: 12-25-2025
        let components = dateString.split(separator: "-")
        guard components.count == 3 else { return dateString }
        
        let month = components[0]
        let day = components[1]
        let year = components[2]
        
        return "\(month)-\(day)-\(year)"
    }
}

// MARK: - Info Row Component
struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.custom(poppinsRegular, size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Product Row Item Component
struct ProductRowItem: View {
    let product: ProductDataModel1
    
    var body: some View {
        HStack(spacing: 12) {
            // Product Image
            VStack(alignment: .leading) {
                if let imageUrl = product.images?.first {
                    CustomProfileImage(url: imageUrl, isCircular: false, size: 80)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray.opacity(0.5))
                        )
                }
            }
            
            // Product Info
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title ?? "")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                HStack(spacing: 4) {
                    Text(product.productCondition ?? "New")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(product.category?.name ?? "Category")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("$\(product.pricing ?? "0.00")")
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 0) {
                        Text("\(product.bidCount ?? 0) bids")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("Stock: \(product.quantity ?? "0")")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Show Model (Example - Adjust to your actual model)
struct ShowModel {
    var id: Int?
    var title: String?
    var thumbnail: String?
    var category: CategoryDataModel?
    var date: String?
    var time: String?
    var auctionType: AuctionType?
    var isRepeat: Bool?
    var repeatValue: String?
    var showDiscoverability: String?
    var isExplicit: Bool?
    var language: String?
}

struct AuctionType {
    var name: String?
}

// MARK: - Loading Shimmer View
struct ShowDetailsShimmer: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Header Card Shimmer
                HStack(spacing: 16) {
                    ShimmerView()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ShimmerView()
                            .frame(width: 200, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        ShimmerView()
                            .frame(width: 150, height: 14)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        ShimmerView()
                            .frame(width: 180, height: 13)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                )
                
                // Info Cards Shimmer
                ForEach(0..<3) { _ in
                    VStack(alignment: .leading, spacing: 16) {
                        ShimmerView()
                            .frame(width: 120, height: 18)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        VStack(spacing: 12) {
                            ForEach(0..<2) { _ in
                                HStack {
                                    ShimmerView()
                                        .frame(width: 100, height: 15)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                    
                                    Spacer()
                                    
                                    ShimmerView()
                                        .frame(width: 80, height: 15)
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }
}


#Preview {
    ShowDetailsScreen(show: ShowModel())
}
