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

// Basecamp #7 (PWA refs 49fba598, cdb8fefb, 8096b426): live-shop tabs are
// All / Sold / Offers (dropped Auction/Buy Now/Freebie). Scoped to the show.
enum ShopTab: String, CaseIterable {
    case all = "All"
    case sold = "Sold"
    case offers = "Offers"
}

//struct ShopBottomSheetView: View {
//    @Binding var isPresented: Bool
//    @Binding var productData: [ProductData]
////    var NavFrom: String = ""
//    var productShowType: ProductShowType
//    var onLiveStreamStart: ((String) -> Void)?
//    var onAddProduct: ((String) -> Void)?
//    
//    @State private var searchText = ""
//    @State private var selectedTab: ShopTab = .auction
//    @StateObject private var viewModel = ProfileViewModel()
//    @EnvironmentObject var networkMonitor: NetworkMonitor
//    
//    // New: store initial selected product ID
//    var initialSelectedProductId: String? = nil
//
//    // Toast states
//    @State private var showToast = false
//    @State private var toastMessage = ""
//    
//    private var selectedProduct: ProductData?{
//        let selectedProduct = productData.first(where: { $0.isCurrent })
//        return selectedProduct
//    }
//    
//    private var isEveryProductSold: Bool {
//        return productData.allSatisfy({ $0.status == "sold" })
//    }
//    
//    private func isProductSelectable(for product: ProductData?) -> Bool {
//        guard let productData = product else { return false }
//        return productShowType != .viewOnly && productData.status != "sold"
//    }
//    
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            // MARK: Header
//            HStack {
//                Text(productShowType == .nextProduct ? "Select Next Product For Auction" : "Shop" )
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
//            // MARK: Search
//            if productShowType != .viewOnly{
//                HStack {
//                    Image(systemName: "magnifyingglass")
//                        .foregroundColor(.gray)
//                    TextField("Search products...", text: $searchText)
//                        .font(.custom(poppinsSemiBold, size: 13))
//                }
//                .padding(.horizontal)
//                .frame(height: 40)
//                .background(Color(.systemGray6))
//                .cornerRadius(10)
//                
//                // MARK: Tabs
//                HStack(spacing: 10) {
//                    ForEach(ShopTab.allCases, id: \.self) { tab in
//                        Button {
//                            selectedTab = tab
//                        } label: {
//                            Text(tab.rawValue)
//                                .font(.custom(poppinsSemiBold, size: 13))
//                                .frame(maxWidth: .infinity)
//                                .padding(.vertical, 10)
//                                .background(selectedTab == tab ? Color.defaultTheme : Color(.systemGray5))
//                                .foregroundColor(selectedTab == tab ? .white : .black)
//                                .cornerRadius(20)
//                        }
//                    }
//                }
//            }
//            
//            Divider()
//            
//            // MARK: Product List
//            ScrollView {
//                LazyVStack(spacing: 12) {
//                    ForEach(productData.indices, id: \.self) { index in
//                        productRow(productData[index], index: index)
//                    }
//                }
//            }
//            
//            //lbottom button -> not shown for user
//            if let product = selectedProduct {
//                if productShowType == .shop {
//                    Button(action: {
//                        isPresented = false
//                        onLiveStreamStart?(product.id ?? "")
//                    }) {
//                        Text("Start Live Stream")
//                            .font(.custom(poppinsSemiBold, size: 14))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.defaultTheme)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                }
//                else if productShowType == .nextProduct {
//                    Button(action: {
//                        // Case 1: Product already in a bid
//                        if product.id == initialSelectedProductId {
//                            // Case 2: Check sold products
//                            if productData.count == 1 && product.status == "sold" {
//                                // Only one product and it's sold
//                                toastMessage = "Product Sold"
//                                showToast = true
//                                return
//                            }
//                            toastMessage = "Product already in a bid"
//                            showToast = true
//                            return
//                        }
//                        
//                        // Case 2:
//                        if productData.count > 1 && isEveryProductSold {
//                            // Multiple products and all are sold
//                            toastMessage = "All Products Sold"
//                            showToast = true
//                            return
//                        }
//                        
//                        // Case 3: Valid product to add
//                        isPresented = false
//                        onAddProduct?(product.id ?? "")
//                    }) {
//                        Text("Add Product")
//                            .font(.custom(poppinsSemiBold, size: 14))
//                            .frame(maxWidth: .infinity)
//                            .padding()
//                            .background(Color.defaultTheme)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//                    
//                }
//            }
//            
//            // MARK: Action Buttons
////            if NavFrom != "Shop" {
////                if productData.contains(where: { $0.isCurrent ?? false }) {
////                    if NavFrom == "Rehearsal" {
////                        if let selectedProduct = productData.first(where: { $0.isCurrent ?? false }) {
////                            Button(action: {
////                                isPresented = false
////                                onLiveStreamStart?(selectedProduct.id ?? "")
////                            }) {
////                                Text("Start Live Stream")
////                                    .font(.custom(poppinsSemiBold, size: 14))
////                                    .frame(maxWidth: .infinity)
////                                    .padding()
////                                    .background(Color.defaultTheme)
////                                    .foregroundColor(.white)
////                                    .cornerRadius(12)
////                            }
////                        }
////                    } else if NavFrom.isEmpty {
////                        if let selectedProduct = productData.first(where: { $0.isCurrent }) {
////                            Button(action: {
////                                // Case 1: Product already in a bid
////                                if selectedProduct.id == initialSelectedProductId {
////                                    // Case 2: Check sold products
////                                    if productData.count == 1 && selectedProduct.status == "sold" {
////                                        // Only one product and it's sold
////                                        toastMessage = "Product Sold"
////                                        showToast = true
////                                        return
////                                    }
////                                    toastMessage = "Product already in a bid"
////                                    showToast = true
////                                    return
////                                }
////                               
////                                // Case 2:
////                                   if productData.count > 1 && productData.allSatisfy({ $0.status == "sold" }) {
////                                       // Multiple products and all are sold
////                                       toastMessage = "All Products Sold"
////                                       showToast = true
////                                       return
////                                   }
////
////                                   // Case 3: Valid product to add
////                                   isPresented = false
////                                   onAddProduct?(selectedProduct.id ?? "")
////                            }) {
////                                Text("Add Product")
////                                    .font(.custom(poppinsSemiBold, size: 14))
////                                    .frame(maxWidth: .infinity)
////                                    .padding()
////                                    .background(Color.defaultTheme)
////                                    .foregroundColor(.white)
////                                    .cornerRadius(12)
////                            }
////                        }
////                    }
////                }
////            }
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//        .toast(isPresenting: $showToast) {
//            AlertToast(type: .regular, title: toastMessage)
//        }
//    }
//    
//    // MARK: - Product Row
//    func productRow(_ product: ProductData, index: Int) -> some View {
//        HStack(spacing: 12) {
//            if isProductSelectable(for: product) {
//                Button(action: {
//                    for i in productData.indices {
//                        productData[i].isCurrent = (i == index)
//                    }
//                }) {
//                    Image(systemName: product.isCurrent ? "checkmark.circle.fill" : "circle")
//                        .foregroundColor(product.isCurrent ? .blue : .gray)
//                }
//            }
//            
//            CustomProfileImage(url: product.image, isCircular: false, cornerRadius: 8, size: 60)
//            
//            VStack(alignment: .leading, spacing: 4) {
//                HStack{
//                    Text(product.name?.capitalizingFirstLetter() ?? "")
//                        .font(.custom(poppinsSemiBold, size: 13.0))
//                    Spacer()
//                    // ✅ Show Live label if this is the initial selected product
//                    if product.id == initialSelectedProductId && product.status != "sold"{
//                        Text("LIVE")
//                            .font(.custom(poppinsSemiBold, size: 14))
//                            .foregroundColor(.defaultTheme)
//                            .padding(.trailing, -20)
//                    }
//                }
//                Text("Price : $\(product.price ?? "")")
//                    .font(.custom(poppinsRegular, size: 11.0))
//                Text("Status: \(product.status?.capitalizingFirstLetter() ?? "")")
//                    .font(.custom(poppinsRegular, size: 11.0))
//                    .foregroundColor(product.status == "sold" ? .red : .black)
//            }
//            
//            Spacer()
//        
//            
//            // Hide edit/delete in Shop mode or if sold
////            if NavFrom != "Shop" && product.status != "sold" && NavFrom != "" {
////                Button {
////                    // Edit action
////                } label: {
////                    Image(systemName: "square.and.pencil")
////                }
////                
////                Button {
////                    // Delete action
////                } label: {
////                    Image(systemName: "trash")
////                }
////            }
//        }
//        .padding()
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(product.status == "sold" ? Color(.systemGray6) : Color(.white))
//                .shadow(color: product.status == "sold" ? .clear : Color.squirrelGrey.opacity(0.5),
//                        radius: 2, x: 0, y: 0)
//        )
//        .padding(.horizontal, 4)
//        .padding(.vertical, 2)
//        .opacity(product.status == "sold" ? 0.6 : 1)
//    }
//}

struct ShopBottomSheetView: View {
    @Binding var isPresented: Bool
    @Binding var productData: [ProductDataModel1]
    var productShowType: ProductShowType
    var onLiveStreamStart: ((String) -> Void)?
    var onAddProduct: ((String) -> Void)?
    
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // New: store initial selected product ID
    var initialSelectedProductId: String? = nil

    // Toast states
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var buttonScale: CGFloat = 1.0

    // Basecamp #7: All/Sold/Offers tabs (buyer panel). "Offers" = items the
    // buyer has bought or bid on. Pre-bid product ids are the strongest
    // per-buyer "bid on" signal available client-side.
    @State private var selectedTab: ShopTab = .all
    @State private var myOfferProductIds: Set<Int> = []

    // Show-scoped, tab-filtered product list. `productData` is already scoped to
    // the current show by the caller (LiveStream loads only this show's items).
    private var visibleProducts: [ProductDataModel1] {
        switch selectedTab {
        case .all:
            return productData
        case .sold:
            return productData.filter { ($0.status ?? "").lowercased() == "sold" }
        case .offers:
            return productData.filter { p in
                guard let id = p.id else { return false }
                let bought = (p.status ?? "").lowercased() == "sold"
                    && (Int(p.purchasedQuantity ?? "0") ?? 0) > 0
                return myOfferProductIds.contains(id) || bought
            }
        }
    }
    
//    private var selectedProduct: ProductData? {
//        let selectedProduct = productData.first(where: { $0.isCurrent })
//        return selectedProduct
//    }
    var selectedProduct: ProductDataModel1? {
        productData.first
    }
    
//    private var isEveryProductSold: Bool {
//        return productData.allSatisfy({ $0.status == "sold" })
//    }
    
    private func isProductSelectable(for product: ProductDataModel1?) -> Bool {
        guard let productData = product else { return false }
        return productShowType != .viewOnly && productData.status != "sold"
    }
    
    
    
    private var currentProduct: ProductDataModel1? {
           productData.first
       }

       /// First unsold product after current
       private func nextEligibleProduct() -> ProductDataModel1? {
           productData
               .dropFirst()
               .first { $0.status != "sold" }
       }

       private var isEveryProductSold: Bool {
           productData.allSatisfy { $0.status == "sold" }
       }
    var body: some View {
        VStack(spacing: 0) {
            
            VStack(spacing: 20) {
                // MARK: Header
                HStack {
                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.defaultThemeLight)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: productShowType == .nextProduct ? "arrow.right.circle.fill" : "bag.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(productShowType == .nextProduct ? "Select Next Product" : "Shop")
                                .font(.custom(poppinsBold, size: 17))
                                .foregroundColor(.primary)
                            
                            if productShowType == .nextProduct {
                                Text("Choose product for auction")
                                    .font(.custom(poppinsRegular, size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isPresented = false
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)

                // MARK: Tabs (Basecamp #7) — All / Sold / Offers
                HStack(spacing: 10) {
                    ForEach(ShopTab.allCases, id: \.self) { tab in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                        } label: {
                            Text(tab.rawValue)
                                .font(.custom(poppinsSemiBold, size: 13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedTab == tab ? Color.defaultTheme : Color(.systemGray5))
                                .foregroundColor(selectedTab == tab ? .white : .primary)
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal, 20)

                // MARK: Product List
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        if visibleProducts.isEmpty {
                            Text("No products")
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 40)
                        } else {
                            ForEach(visibleProducts.indices, id: \.self) { index in
                                productRow(visibleProducts[index], index: index)
                                    .padding(.vertical, 6)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 12)
                .onAppear { loadMyOffers() }
                
                // Bottom button
                if let product = selectedProduct {
                    VStack(spacing: 4) {
                        Divider()
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)
                        
                        if productShowType == .shop {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 0.95
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        buttonScale = 1.0
                                    }
                                    isPresented = false
                                    onLiveStreamStart?("\(product.id ?? 0)")
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 18))
                                    
                                    Text("Start Auction")
                                        .font(.custom(poppinsSemiBold, size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.defaultTheme.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .scaleEffect(buttonScale)
                            .padding(.horizontal, 20)
                        }
                        else if productShowType == .nextProduct {
                            Button(action: {
                                // Case 1: Product already in a bid
                                if product.id == Int(initialSelectedProductId ?? "") {
                                    // Case 2: Check sold products
                                    if productData.count == 1 && product.status == "sold" {
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
                                if productData.count > 1 && isEveryProductSold {
                                    // Multiple products and all are sold
                                    toastMessage = "All Products Sold"
                                    showToast = true
                                    return
                                }
                                
                                // Case 3: Valid product to add
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    buttonScale = 0.95
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        buttonScale = 1.0
                                    }
                                    isPresented = false
                                    onAddProduct?("\(product.id ?? 0)")
                                }
                            }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 18))
                                    
                                    Text("Add Product")
                                        .font(.custom(poppinsSemiBold, size: 16))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.defaultTheme.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .scaleEffect(buttonScale)
                            .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .background(.clear)
        .toast(isPresenting: $showToast) {
            AlertToast(type: .regular, title: toastMessage)
        }
    }
    
    // MARK: - Product Row
//    func productRow(_ product: ProductDataModel1, index: Int) -> some View {
//        Button(role: {
//            if isProductSelectable(for: product) {
//                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                    for i in productData.indices {
////                        productData[i].isCurrent = (i == index)
//                    }
//                }
//            }
//        }) {
//            HStack(spacing: 14) {
//                // Selection indicator
//                if isProductSelectable(for: product) {
//                    ZStack {
//                        Circle()
//                            .stroke(product.isCurrent ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
//                            .frame(width: 24, height: 24)
//                        
//                        if product.isCurrent {
//                            Circle()
//                                .fill(Color.defaultTheme)
//                                .frame(width: 24, height: 24)
//                            
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 12, weight: .bold))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: product.isCurrent)
//                }
//                
//                // Product Image
//                CustomProfileImage(url: product.image, isCircular: false, cornerRadius: 12, size: 70)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(Color.gray.opacity(0.1), lineWidth: 1)
//                    )
//                    .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
//                
//                // Product Details
//                VStack(alignment: .leading, spacing: 6) {
//                    HStack {
//                        Text(product.name?.capitalizingFirstLetter() ?? "")
//                            .font(.custom(poppinsSemiBold, size: 14))
//                            .foregroundColor(.primary)
//                            .lineLimit(2)
//                        
//                        Spacer()
//                        
//                        // Live Badge
//                        if product.id == initialSelectedProductId && product.status != "sold" {
//                            HStack(spacing: 4) {
//                                Circle()
//                                    .fill(Color.red)
//                                    .frame(width: 6, height: 6)
//                                
//                                Text("LIVE")
//                                    .font(.custom(poppinsBold, size: 11))
//                                    .foregroundColor(.red)
//                            }
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(
//                                Capsule()
//                                    .fill(Color.red.opacity(0.1))
//                            )
//                        }
//                    }
//                    
//                    HStack(spacing: 4) {
//                        Image(systemName: "dollarsign.circle.fill")
//                            .font(.system(size: 12))
//                            .foregroundColor(.green)
//                        
//                        Text("$\(product.price ?? "")")
//                            .font(.custom(poppinsSemiBold, size: 13))
//                            .foregroundColor(.green)
//                    }
//                    
//                    HStack(spacing: 4) {
//                        Circle()
//                            .fill(product.status == "sold" ? Color.red : Color.green)
//                            .frame(width: 6, height: 6)
//                        
//                        Text(product.status?.capitalizingFirstLetter() ?? "")
//                            .font(.custom(poppinsRegular, size: 12))
//                            .foregroundColor(product.status == "sold" ? .red : .secondary)
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding(16)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(product.status == "sold" ? Color(.systemGray6) : Color(.systemBackground))
//                    .shadow(
//                        color: product.isCurrent && product.status != "sold" ? Color.defaultTheme.opacity(0.2) : Color.black.opacity(0.06),
//                        radius: product.isCurrent && product.status != "sold" ? 12 : 8,
//                        x: 0,
//                        y: product.isCurrent && product.status != "sold" ? 6 : 3
//                    )
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(
//                        product.isCurrent && product.status != "sold" ? Color.defaultTheme.opacity(0.4) : Color.clear,
//                        lineWidth: 2
//                    )
//                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: product.isCurrent)
//            )
//            .opacity(product.status == "sold" ? 0.6 : 1)
//            .scaleEffect(product.isCurrent && product.status != "sold" ? 1.02 : 1.0)
//            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: product.isCurrent)
//        }
//        .buttonStyle(PlainButtonStyle())
//    }
    
    private func productRow(_ product: ProductDataModel1, index: Int) -> some View {

           let isCurrent = index == 0
           let isNext = product.id == nextEligibleProduct()?.id

           return HStack(spacing: 14) {

               // Product Image
               CustomProfileImage(
                   url: product.thumbnail?.first ?? product.images?.first,
                   isCircular: false,
                   cornerRadius: 12,
                   size: 70
               )

               VStack(alignment: .leading, spacing: 6) {

                   HStack {
                       Text(product.title ?? "")
                           .font(.custom(poppinsSemiBold, size: 14))
                           .lineLimit(2)

                       Spacer()

                       // LIVE / NEXT badge
                       if isCurrent && product.status != "sold" {
                           badgeView(text: "LIVE", color: .red)
                       } else if isNext {
                           badgeView(text: "NEXT", color: .orange)
                       }
                   }

                   Text("$\(product.pricing ?? "")")
                       .font(.custom(poppinsSemiBold, size: 13))
                       .foregroundColor(.green)

                   Text(product.status?.capitalizingFirstLetter() ?? "")
                       .font(.custom(poppinsRegular, size: 12))
                       .foregroundColor(product.status == "sold" ? .red : .secondary)
               }

               Spacer()
           }
           .padding(16)
           .background(
               RoundedRectangle(cornerRadius: 16)
                   .fill(product.status == "sold"
                         ? Color(.systemGray6)
                         : Color(.systemBackground))
                   .shadow(
                       color: isCurrent ? Color.defaultTheme.opacity(0.25) : Color.black.opacity(0.06),
                       radius: isCurrent ? 12 : 8,
                       x: 0,
                       y: isCurrent ? 6 : 3
                   )
           )
           .overlay(
               RoundedRectangle(cornerRadius: 16)
                   .stroke(isCurrent ? Color.defaultTheme.opacity(0.4) : Color.clear, lineWidth: 2)
           )
           .opacity(product.status == "sold" ? 0.6 : 1)
       }
    
    private func bottomButton() -> some View {
            Button {

                if productShowType == .nextProduct {

                    guard let nextProduct = nextEligibleProduct() else {
                        toastMessage = "All Products Sold"
                        showToast = true
                        return
                    }

                    isPresented = false
                    onAddProduct?(String(nextProduct.id ?? 0))

                } else {

                    guard let current = currentProduct else { return }

                    isPresented = false
                    onLiveStreamStart?(String(current.id ?? 0))
                }

            } label: {
                Text(productShowType == .nextProduct ? "Add Product" : "Start Auction")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.defaultTheme)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .padding(.horizontal, 20)
            }
        }
    
    func badgeView(text: String, color: Color) -> some View {
            Text(text)
                .font(.custom(poppinsBold, size: 11))
                .foregroundColor(color)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Capsule().fill(color.opacity(0.12)))
        }

    // Basecamp #7: GET /api/pre-bid — the buyer's pre-bids, used to populate the
    // "Offers" tab (items the buyer has bid on). Combined with sold-to-buyer
    // items in `visibleProducts`.
    private func loadMyOffers() {
        Task {
            guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/pre-bid") else { return }
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            do {
                let (data, _) = try await URLSession.shared.data(for: req)
                let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                let rows = (json?["data"] as? [[String: Any]]) ?? []
                let ids = Set(rows.compactMap { $0["product_id"] as? Int })
                await MainActor.run { myOfferProductIds = ids }
            } catch { /* no-op */ }
        }
    }
}
