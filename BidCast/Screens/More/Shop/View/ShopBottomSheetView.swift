//
//  ShowSummarySheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

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

//struct ShopBottomSheetView: View {
//    @Binding var isPresented: Bool
//    @State  var searchText = ""
//    @State  var selectedTab: ShopTab = .auction
//    @StateObject var viewModel = ProfileViewModel()
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    var filteredProducts: [ProductListingDataModel] {
//        viewModel.productDetailsResponseDict?.data.filter {
//            searchText.isEmpty || (($0.title?.localizedCaseInsensitiveContains(searchText)) != nil)} ?? [ProductListingDataModel]()
//      }
////    @Binding var userId : String
//    @State var showhud: Bool = false
//    @State var hudMsg: String = ""
//    
//    
//    @Binding var productData : [ProductData]
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            
//            // Header
//            HStack {
//                Text("Shop")
//                    .font(.custom(poppinsBold, size: 15))
//                Spacer()
//                Button {
//                    isPresented = false
//                } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.black)
//                }
//            }
//            
//            // Search
//            HStack {
//                Image(systemName: "magnifyingglass")
//                    .foregroundColor(.gray)
//                TextField("Search products...", text: $searchText)
//                    .font(.custom(poppinsSemiBold, size: 13))
//            }
//            .padding(.horizontal)
//            .frame(height: 40)
//            .background(Color(.systemGray6))
//            .cornerRadius(10)
//            
//            // Tabs
//            HStack(spacing: 10) {
//                ForEach(ShopTab.allCases, id: \.self) { tab in
//                    Button {
//                        selectedTab = tab
//                    } label: {
//                        Text(tab.rawValue)
//                            .font(.custom(poppinsSemiBold, size: 13))
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 10)
//                            .background(selectedTab == tab ? Color.defaultTheme : Color(.systemGray5))
//                            .foregroundColor(selectedTab == tab ? .white : .black)
//                            .cornerRadius(20)
//                    }
//                }
//            }
//            
//            Divider()
//            
//            ScrollView {
//                LazyVStack(spacing: 12) {
//                    ForEach(productData.indices, id: \.self) { index in
//                        productRow(productData[index])
//                    }
//                }
//            }
//            
//            // Add Product
//            HStack {
//                Spacer()
//                Button {
//                    // Add new product action
//                } label: {
//                    Image(systemName: "plus")
//                        .foregroundColor(.white)
//                        .frame(width: 40, height: 40)
//                        .background(Color.defaultTheme)
//                        .clipShape(Circle())
//                        .shadow(radius: 4)
//                }
//            }
//            .padding(.bottom)
//            
//        }
//        .edgesIgnoringSafeArea(.top)
//        .padding()
//        .background(.white)
//        .cornerRadius(20)
////        .onAppear {
//////            Task{
//////               guard Reachability.isConnectedToNetwork() else {
//////                    hudMsg = "No Internet Connection"
//////                    showhud = true
//////                    return
//////                }
////////                SVProgressHUD.show()
////////                await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(userId) ?? 0, page: 1))
////////                await SVProgressHUD.dismiss()
////////                if self.viewModel.errorMessage == nil {
////////                    filteredProducts = self.viewModel.productDetailsResponseDict?.data ?? [ProductListingDataModel]()
////////                }
//////            }
////        }
//    }
//    
//
//    
//    func productRow(_ product: ProductData) -> some View {
//            HStack(spacing: 12) {
//                CustomProfileImage(url: product.image,isCircular: false,cornerRadius: 8,size: 60)
//
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(product.name)
//                        .font(.custom(poppinsSemiBold, size: 13.0))
////                    Text(product.description ?? "")
////                        .font(.subheadline)
////                        .foregroundColor(.gray)
//                    Text(product.category)
//                        .font(.custom(poppinsRegular, size: 11.0))
////                        .foregroundColor(product.status == "active" ? .darkGreen : .red)
//                }
//
//                Spacer()
//
//                Button {
//                    // Edit action
//                } label: {
//                    Image(systemName: "square.and.pencil")
//                }
//
//                Button {
//                    // Delete action
//                } label: {
//                    Image(systemName: "trash")
//                }
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(12)
//        }
//}
struct ShopBottomSheetView: View {
    @Binding var isPresented: Bool
    @Binding var productData: [ProductData]
    var NavFrom: String = ""
    var onLiveStreamStart: ((String) -> Void)?
    var onAddProduct: ((String) -> Void)?
    
    @State private var searchText = ""
    @State private var selectedTab: ShopTab = .auction
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // New: store initial selected product ID
    var initialSelectedProductId: String? = nil

    // Toast states
    @State private var showToast = false
    @State private var toastMessage = ""
    
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: Header
            HStack {
                Text(NavFrom == "" ? "Select Next Product For Auction" : "Shop")
                    .font(.custom(poppinsBold, size: 15))
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            
            // MARK: Search
            if NavFrom != ""{
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search products...", text: $searchText)
                        .font(.custom(poppinsSemiBold, size: 13))
                }
                .padding(.horizontal)
                .frame(height: 40)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                // MARK: Tabs
                HStack(spacing: 10) {
                    ForEach(ShopTab.allCases, id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            Text(tab.rawValue)
                                .font(.custom(poppinsSemiBold, size: 13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == tab ? Color.defaultTheme : Color(.systemGray5))
                                .foregroundColor(selectedTab == tab ? .white : .black)
                                .cornerRadius(20)
                        }
                    }
                }
            }
            
            Divider()
            
            // MARK: Product List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(productData.indices, id: \.self) { index in
                        productRow(productData[index], index: index)
                    }
                }
            }
            
            // MARK: Action Buttons
            if NavFrom != "Shop" {
                if productData.contains(where: { $0.isCurrent ?? false }) {
                    if NavFrom == "Rehearsal" {
                        if let selectedProduct = productData.first(where: { $0.isCurrent ?? false }) {
                            Button(action: {
                                isPresented = false
                                onLiveStreamStart?(selectedProduct.id ?? "")
                            }) {
                                Text("Start Live Stream")
                                    .font(.custom(poppinsSemiBold, size: 14))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.defaultTheme)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    } else if NavFrom.isEmpty {
                        if let selectedProduct = productData.first(where: { $0.isCurrent }) {
                            Button(action: {
                                // Case 1: Product already in a bid
                                if selectedProduct.id == initialSelectedProductId {
                                    // Case 2: Check sold products
                                    if productData.count == 1 && selectedProduct.status == "sold" {
                                        // Only one product and it's sold
                                        toastMessage = "Product Sold"
                                        showToast = true
                                        return
                                    }
                                    toastMessage = "Product already in a bid"
                                    showToast = true
                                    return
                                }
                               
                                // Case 2:
                                   if productData.count > 1 && productData.allSatisfy({ $0.status == "sold" }) {
                                       // Multiple products and all are sold
                                       toastMessage = "All Products Sold"
                                       showToast = true
                                       return
                                   }

                                   // Case 3: Valid product to add
                                   isPresented = false
                                   onAddProduct?(selectedProduct.id ?? "")
                            }) {
                                Text("Add Product")
                                    .font(.custom(poppinsSemiBold, size: 14))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.defaultTheme)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .toast(isPresenting: $showToast) {
            AlertToast(type: .regular, title: toastMessage)
        }
    }
    
    // MARK: - Product Row
    func productRow(_ product: ProductData, index: Int) -> some View {
        HStack(spacing: 12) {
            if NavFrom != "Shop" && product.status != "sold" {
                Button(action: {
                    for i in productData.indices {
                        productData[i].isCurrent = (i == index)
                    }
                }) {
                    Image(systemName: product.isCurrent ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(product.isCurrent ? .blue : .gray)
                }
            }
            
            CustomProfileImage(url: product.image, isCircular: false, cornerRadius: 8, size: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack{
                    Text(product.name ?? "")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Spacer()
                    // ✅ Show Live label if this is the initial selected product
                    if product.id == initialSelectedProductId && product.status != "sold"{
                        Text("LIVE")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.defaultTheme)
                            .padding(.trailing, -20)
                    }
                }
                Text("Price : $\(product.price)")
                    .font(.custom(poppinsRegular, size: 11.0))
                Text("Status: \(product.status)")
                    .font(.custom(poppinsRegular, size: 11.0))
                    .foregroundColor(product.status == "sold" ? .red : .black)
            }
            
            Spacer()
        
            
            // Hide edit/delete in Shop mode or if sold
            if NavFrom != "Shop" && product.status != "sold" && NavFrom != "" {
                Button {
                    // Edit action
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                
                Button {
                    // Delete action
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(product.status == "sold" ? Color(.systemGray6) : Color(.white))
                .shadow(color: product.status == "sold" ? .clear : Color.squirrelGrey.opacity(0.5),
                        radius: 2, x: 0, y: 0)
        )
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .opacity(product.status == "sold" ? 0.6 : 1)
    }
}
