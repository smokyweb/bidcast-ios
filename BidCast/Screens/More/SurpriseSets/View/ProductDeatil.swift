
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
    
    var body: some View {
        
        VStack{
            
            PrimaryHeader(
                title: "Product Deatil",
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
                    Text("Test")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("est")
                        .foregroundColor(.gray)
                    
                    // Progress Bar
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: 0.6)
                            .tint(.green)
                        
                        Text("3/5 left")
                            .foregroundColor(.gray)
                            .font(.subheadline)
                    }
                    
                    Text("Starting from $5.00")
                        .foregroundColor(.gray)
                }
                
                // MARK: - Seller Card
                VStack(spacing: 0) {
                    
                    HStack {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                        
                        Text("androiduser")
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding()
                    
                    Divider()
                    HStack(spacing: 0) {
                        SellerStatView(icon: "star.fill", value: "0.0", title: "Rating")
                        
                        Divider()
                            .frame(height: 40)
                        
                        SellerStatView(value: "0", title: "Reviews")
                        
                        Divider()
                            .frame(height: 40)
                        
                        SellerStatView(value: "6.0", title: "Sold")
                        
                        Divider()
                            .frame(height: 40)
                        
                        SellerStatView(icon: "truck", value: "0", title: "Avg ship")
                    }
                    .frame(height: 70)

                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(20)
                
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
        ProductDetail()
    }
}

extension ProductDetail {
    
    var productView: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Items Section
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Items (3)")
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
                    HStack {
                        VStack(alignment: .leading) {
                            Text("tes")
                            Text("Qty: 3")
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("Available")
                    }
                }
            }
            
            // Sold Section
            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    Text("Sold (2)")
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
                    HStack {
                        Text("#327")
                        Spacer()
                        Text("$5.00")
                    }
                    
                    HStack {
                        Text("#328")
                        Spacer()
                        Text("$2.00")
                    }
                }
            }
            
            Text("Posted 6 days ago")
                .foregroundColor(.gray)
                .padding(.top)
        }
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
