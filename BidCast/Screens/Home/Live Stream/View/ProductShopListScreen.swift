//
//  ProductShopListScreen.swift
//  BidCast
//
//  Created by JamTech on 24/11/25.
//
import SwiftUI

// MARK: - Product Model
struct Product1: Identifiable {
    let id: UUID = UUID()
    let title: String
    let quantityText: String
    let priceText: String
    let shippingText: String
    let bidsText: String?
    let imageFilePath: String?
    let badgeCount: Int?
    let isBuyNow: Bool
}

// MARK: - Image Loader
final class LocalImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    func load(fromFilePath path: String?, defaultName: String = "default_product") {
        guard let path = path else {
            image = UIImage(named: defaultName)
            return
        }
        let url = URL(fileURLWithPath: path)
        if let data = try? Data(contentsOf: url), let ui = UIImage(data: data) {
            image = ui
        } else {
            image = UIImage(named: defaultName)
        }
    }
}

// MARK: - Shimmer Modifier
struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var isActive: Bool
    
    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    GeometryReader { proxy in
                        let gradient = LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.25),
                                Color.white.opacity(0.7),
                                Color.white.opacity(0.25)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Rectangle()
                            .fill(gradient)
                            .rotationEffect(.degrees(0))
                            .offset(x: -proxy.size.width * 1.5 + phase * proxy.size.width * 3)
                    }
                    .clipped()
                )
                .mask(content)
                .onAppear {
                    withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }
}

extension View {
    func shimmer(if active: Bool) -> some View {
        modifier(Shimmer(isActive: active))
    }
}

// MARK: - Product List Item
struct ProductListItem: View {
    @Binding var product: ProductData
    @State private var showBadge = true
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            
            // MARK: - Product Image
            ZStack(alignment: .topTrailing) {
                CustomProfileImage(
                    url: product.image ?? "",
                    isCircular: false,
                    cornerRadius: 12,
                    size: 120,
                    height: 120,
                    defaultImage: "photo"
                ) {}
                .frame(width: 120, height: 120)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.black.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
                
                // Bell badge
                if showBadge {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black.opacity(0.85))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.gray.opacity(0.3), lineWidth: 0.6))
                        .padding(.trailing, 6)
                        .padding(.top, 6)
                }
            }
            
            // MARK: - Right Content
            VStack(alignment: .leading, spacing: 6) {
                Text(product.name ?? "Product")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Text("Quantity: \(product.quantity ?? "0")")
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.gray)
                    
                    Text("New")
                        .font(.custom("Poppins-SemiBold", size: 10))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 4) {
                    Text("$\(product.price ?? "0.0")")
                        .font(.custom("Poppins-Bold", size: 18))
                        .foregroundColor(.black)
                    
                    Text("• Ships from United States")
                        .font(.custom("Poppins-Regular", size: 12))
                        .foregroundColor(.gray)
                }
                
                // Buy Now button
                Button(action: {}) {
                    Text("Buy Now")
                        .font(.custom("Poppins-SemiBold", size: 15))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.sRGB, red: 0.98, green: 0.96, blue: 0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                .foregroundColor(.black.opacity(0.85))
            }
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
    }
}

// MARK: - Product List Heading
struct ProductListHeading: View {
    let count: Int
    
    var body: some View {
        Text("Products (\(count))")
            .font(.custom("Poppins-Bold", size: 20))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
    }
}

// MARK: - Main Screen
struct ProductShopListScreen: View {
    @State var searchText: String = ""
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedIndex: Int = 0
    @State private var isLoading: Bool = false
    
    @Binding var productData: [ProductData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Search Bar + Close Button
            HStack {
                SearchBarView(placeholder: "Search shop...") { text in
                    self.searchText = text
                }
                .padding(.leading, 12)
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.gray)
                }
                .padding(12)
            }
            
            // MARK: - Pills Selector
            PillsSelectorView(
                titles: ["Sort", "Auction", "Buy Now", "Giveaway", "Sold"],
                selectedIndex: $selectedIndex,
                backgroundStyle: .roundedRect,
                underlineEnabled: false,
                showFilterButton: true,
                showSortDropdown: true,
                onSelectionChanged: { _, _ in }
            )
            
            // MARK: - Heading
            ProductListHeading(count: productData.count)
            
            // MARK: - Product List / Shimmers
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    if isLoading {
                        ForEach(0..<8) { _ in
                            PurchasesViewShimmerView()
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                        }
                    } else if productData.isEmpty {
                        NoDataView(message: "No Product Found")
                    } else {
                        ForEach($productData, id: \.id) { $data in
                            ProductListItem(product: $data)
                                .padding(.vertical, 4)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
    }
}
