//
//  ShowSummarySheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct Product: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let detail: String
    let statusColor: Color
}

enum ShopTab: String, CaseIterable {
    case auction = "Auction"
    case buyNow = "Buy Now"
    case freebie = "Freebie"
    case sold = "Sold"
}

struct ShopBottomSheetView: View {
    @Binding var isPresented: Bool
    @State private var searchText = ""
    @State private var selectedTab: ShopTab = .auction

    let products: [Product]

    var filteredProducts: [Product] {
        products.filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Shop")
                    .font(.title2).bold()
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                        .imageScale(.large)
                }
            }

            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products...", text: $searchText)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)

            // Tabs
            HStack(spacing: 10) {
                ForEach(ShopTab.allCases, id: \.self) { tab in
                    Button(action: { selectedTab = tab }) {
                        Text(tab.rawValue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.red : Color(.systemGray5))
                            .foregroundColor(selectedTab == tab ? .white : .black)
                            .cornerRadius(20)
                    }
                }
            }

            Divider()

            // Product List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(filteredProducts) { product in
                        HStack(spacing: 12) {
                            Image(product.imageName)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .background(Color(.systemGray5))
                                .cornerRadius(10)

                            VStack(alignment: .leading) {
                                Text(product.title).bold()
                                Text(product.subtitle).font(.subheadline).foregroundColor(.gray)
                                Text(product.detail)
                                    .font(.subheadline)
                                    .foregroundColor(product.statusColor)
                            }

                            Spacer()

                            Button(action: {}) {
                                Image(systemName: "square.and.pencil")
                            }
                            Button(action: {}) {
                                Image(systemName: "trash")
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }

            Spacer()

            // Add Product Button
            HStack {
                Spacer()
                Button(action: {
                    // Handle action
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.title)
                        .frame(width: 60, height: 60)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.bottom)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
