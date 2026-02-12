//
//  ManageProductSheet.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 05/02/26.
//


import SwiftUI

//// MARK: - Models
//struct ProductItem: Identifiable, Codable {
//    let id = UUID()
//    var name: String
//    var quantity: Int
//    var description: String
//}

struct UnsoldProduct: Identifiable {
    let id = UUID()
    var number: Int
    var price: Double
}

struct AvailableProduct: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
}

// MARK: - Main Sheet View
struct ManageProductSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var surpriseData: ProductSurpriseData
//    let surpriseData: ProductSurpriseData
    var onStartAuction: ((ProductSurpriseData,String,Int,Int,Bool) -> Void)?
    
    @State private var isAutoRandomizeOn: Bool = false
    @State private var isQuickSpinOn: Bool = false
    
    // State for Auction Sheet
    @State private var showAuctionSheet = false
    @State private var selectedProductForAuction: ProductItemResponse?
    var didUpdate: () -> Void
    // Computed properties for dynamic data
    private var productTitle: String {
        surpriseData.name ?? "Untitled"
    }
    
    private var price: String {
        if let priceValue = surpriseData.price {
            return Double(priceValue).compactCurrency()
        }
        return "$0"
    }
    
    private var availableProducts: [ProductItemResponse] {
        surpriseData.items ?? []
    }
    
    private var totalQuantity: Int {
        availableProducts.reduce(0) { $0 + ($1.quantity ?? 0) }
    }
    
    private var isAuctionType: Bool {
        surpriseData.type != "auction"
    }
    
    // All unsold units from all items, ordered by item
    private var allUnsoldUnits: [(unit: ProductSetUnit, productName: String)] {
        var result: [(unit: ProductSetUnit, productName: String)] = []
        for product in availableProducts {
            let unsoldUnits = product.units?.filter { $0.status != "sold" } ?? []
            for unit in unsoldUnits {
                result.append((unit: unit, productName: product.name ?? "Product"))
            }
        }
        return result
    }
    
    // All available (not sold) units from all items
    private var allAvailableUnits: [(unit: ProductSetUnit, productName: String)] {
        var result: [(unit: ProductSetUnit, productName: String)] = []
        for product in availableProducts {
            let availableUnits = product.units?.filter { $0.status == "available" || $0.status == nil } ?? []
            for unit in availableUnits {
                result.append((unit: unit, productName: product.name ?? "Product"))
            }
        }
        return result
    }
    
    // All sold units
    private var allSoldUnits: [(unit: ProductSetUnit, productName: String)] {
        var result: [(unit: ProductSetUnit, productName: String)] = []
        for product in availableProducts {
            let soldUnits = product.units?.filter { $0.status == "sold" } ?? []
            for unit in soldUnits {
                result.append((unit: unit, productName: product.name ?? "Product"))
            }
        }
        return result
    }
    
    init(
        surpriseData: Binding<ProductSurpriseData>,
        onStartAuction: ((ProductSurpriseData, String, Int, Int, Bool) -> Void)? = nil,
        didUpdate: @escaping () -> Void = {}
    ) {
        self._surpriseData = surpriseData
        self.onStartAuction = onStartAuction
        self.didUpdate = didUpdate
        _isAutoRandomizeOn = State(
               initialValue: (surpriseData.wrappedValue.autoRandomizer ?? 0) == 1
           )

           _isQuickSpinOn = State(
               initialValue: (surpriseData.wrappedValue.quickSpin ?? 0) == 1
           )
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Manage Product Set")
                        .font(.custom(poppinsSemiBold, size: 18))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 8) {
                        // Product Title & Price Display
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(productTitle.capitalizingFirstLetter())
                                    .font(.custom(poppinsSemiBold, size: 16))
                                    .foregroundColor(.black)
                                
                                if let description = surpriseData.description, !description.isEmpty {
                                    Text(description)
                                        .font(.custom(poppinsRegular, size: 13))
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.horizontal,8)
                            
                            Spacer()
                            
                            // Hide price for auction type
                            if surpriseData.type != "auction" {
                                Text(price)
                                    .font(.custom(poppinsSemiBold, size: 18))
                                    .foregroundColor(.defaultTheme)
                                    .padding(.horizontal,8)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        
                        // Type Badge
                        if let type = surpriseData.type {
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: type == "auction" ? "gavel.fill" : "cart.fill")
                                        .font(.system(size: 12))
                                    
                                    Text(type == "auction" ? "Auction" : "Buy It Now")
                                        .font(.custom(poppinsRegular, size: 12))
                                }
                                .foregroundColor(.defaultTheme)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.defaultThemeLight)
                                .cornerRadius(12)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
//
//                        // Action Buttons
//                        HStack(spacing: 12) {
//                            ActionTools(
//                                icon: "trash.fill",
//                                backgroundColor: Color(red: 0.95, green: 0.9, blue: 0.95)
//                            )
//
//                            ActionTools(
//                                icon: "pin.fill",
//                                backgroundColor: .defaultThemeLight
//                            )
//                        }
//                        .padding(.horizontal, 20)
                        
                        // Up Next Card (Only for Auction type)
                        if surpriseData.type == "auction" {
                            UpNextCard(
                                productName: productTitle,
                                soldCount: availableProducts.reduce(0) { $0 + ($1.soldQuantity ?? 0) },
                                totalCount: totalQuantity,
                                onStartAuction: {
                                    if let product = availableProducts.first {
                                        selectedProductForAuction = product
                                        showAuctionSheet = true
                                    }
                                }
                            )
                            .padding(.horizontal, 16)
                        }
                        
                        // Toggle Cards
                        ToggleInfoCardNew(
                            items: [
                                .init(
                                    title: "Auto-Randomize",
                                    description: "After each product sells, the buyer will be randomly assigned. Turn off if you want to randomize manually.",
                                    tint: .defaultTheme,
                                    isOn: $isAutoRandomizeOn
                                ),
                                .init(
                                    title: "Quick Spin",
                                    description: "Turn off if you want a slower spin animation. This does not affect randomization.",
                                    tint: .defaultTheme,
                                    isOn: $isQuickSpinOn
                                )
                            ]
                        )
                        .padding(.horizontal, 16)
                        
                        // Products Section - Collapsible sections for both types
                        AuctionProductSections(
                            unsoldUnits: allUnsoldUnits,
                            availableItems: availableProducts,
                            isAuctionType: isAuctionType,
                            didUpdate: didUpdate
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 8)
                }
            }
            .background(.backGround)
        }
        
        .sheet(isPresented:$showAuctionSheet){
            AuctionSettingsSheet(
                startingBid: "\(surpriseData.price ?? 0)",
                onTapCancel: {
                    showAuctionSheet = false
                },
                onStartAuction: { bidAmount, requiredTime, counterBidTime, isSuddenDeath in
                    showAuctionSheet = false
                    // Pass the full surpriseData for auction start
                    onStartAuction?(surpriseData, bidAmount, requiredTime, counterBidTime, isSuddenDeath)
                }
            )
            .presentationDetents([.fraction(0.70)])
            .presentationCornerRadius(24)
            .presentationDragIndicator(.hidden)
        }
    }
}

// MARK: - Up Next Card
struct UpNextCard: View {
    let productName: String
    let soldCount: Int
    let totalCount: Int
    var onStartAuction: (() -> Void)?
   
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Up Next")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.black)
            
            HStack {
                Text(productName)
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(soldCount) of \(totalCount) sold")
                    .font(.custom(poppinsRegular, size: 14))
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                onStartAuction?()
            }) {
                Text("Start Auction")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.defaultTheme)
                    .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Auction Product Sections (Unsold & Available Collapsible)
struct AuctionProductSections: View {
    let unsoldUnits: [(unit: ProductSetUnit, productName: String)]
    let availableItems: [ProductItemResponse]
    let isAuctionType: Bool
    var didUpdate : () -> () = {  }
    
    @State private var isUnsoldExpanded: Bool = true
    @State private var isAvailableExpanded: Bool = false
    
    // Total available units count for header
    private var totalAvailableUnits: Int {
        availableItems.reduce(0) { total, item in
            total + (item.units?.filter { $0.status != "sold" }.count ?? 0)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Unsold Section - Hidden for Auction type, shown for Buy Now
            if !isAuctionType {
                CollapsibleUnitSection(
                    title: "Unsold",
                    count: unsoldUnits.count,
                    isExpanded: $isUnsoldExpanded,
                    accentColor: .orange
                ) {
                    if unsoldUnits.isEmpty {
                        Text("No unsold units")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: 6) {
                            ForEach(Array(unsoldUnits.enumerated()), id: \.element.unit.id) { index, item in
                                UnsoldUnitRow(
                                    unit: item.unit,
                                    productName: item.productName,
                                    index: index + 1,
                                    unitId:Int(item.unit.id),
                                    didUpdate: didUpdate
                                    
                                )
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                    }
                }
            }
            
            // Available Section - Shows items (not units)
            CollapsibleUnitSection(
                title: "Available",
                count: totalAvailableUnits,
                isExpanded: $isAvailableExpanded,
                accentColor: .green
            ) {
                if availableItems.isEmpty {
                    Text("No available items")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 6) {
                        ForEach(availableItems, id: \.id) { item in
                            AvailableItemRow(product: item)
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

// MARK: - Collapsible Unit Section
struct CollapsibleUnitSection<Content: View>: View {
    let title: String
    let count: Int
    @Binding var isExpanded: Bool
    let accentColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Entire row is tappable
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 10, height: 10)
                    
                    Text("\(title) (\(count))")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.defaultTheme)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            
            // Expanded Content
            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                
                content
            }
        }
        .background(Color.white)
        .cornerRadius(12)
    }
}


struct CollapsibleUnitSectionforproduct<Content: View>: View {
    let title: String
    let count: Int
    @Binding var isExpanded: Bool
    let accentColor: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Header - Entire row is tappable
        
            
            // Expanded Content
            if isExpanded {
//                Divider()
//                    .padding(.horizontal, 12)
                
                content
            }
        }
        .background(Color.backGround)
        .cornerRadius(12)
    }
}

// MARK: - Unsold Unit Row (with #1, #2 index)
struct UnsoldUnitRow: View {
    let viewModel = SurpriseViewModel()
    let unit: ProductSetUnit
    let productName: String
    let index: Int
    let unitId: Int
    var didUpdate: () -> Void


    @State private var isUnsoldExpanded: Bool = false
    @State private var price: String = ""
    @State private var description: String = ""
//    @State private var unitId: String = ""

    init(
    unit: ProductSetUnit,
     productName: String,
     index: Int,
     unitId: Int,
     didUpdate: @escaping () -> Void
 ) {
     self.unit = unit
     self.productName = productName
     self.index = index
     self.unitId = unitId
     self.didUpdate = didUpdate

     // Initialize State properly
     _price = State(initialValue: "\(unit.price ?? 0)")
     _description = State(initialValue: unit.description ?? "")
 }
            
    var body: some View {
        VStack(spacing: 0){
            HStack(alignment: .center, spacing: 10) {
                // Index number
                Text("#\(index)")
                    .font(.custom(poppinsSemiBold, size: 14))
                    .foregroundColor(.defaultTheme)
                    .frame(width: 36, alignment: .leading)
                
                // Unit Info
                VStack(alignment: .leading, spacing: 0) {
                    Text(unit.name ?? "Unit #\(unit.id)")
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.black)
                    
                    Text(unit.description ?? "")
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.gray)
                    
                    
                    let price = unit.price ?? 0
                    Text(Double(price).compactCurrency())
                        .font(.custom(poppinsSemiBold, size: 13))
                        .foregroundColor(.defaultTheme)
                    
                }
                
                Spacer()
                
                HStack(spacing: 12) {

                    Button {
                        if isUnsoldExpanded {
                            
                            Task {
                                do {
                                    try await viewModel.editProductPrice(
                                        param: EditProductUnitRequest(
                                            unit_id: String(unitId),
                                            price: price,
                                            description: description
                                        )
                                        
                                    )
                                    success()
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                        }
                        isUnsoldExpanded.toggle()

                        
                    } label: {
                        Image(systemName: !isUnsoldExpanded ? "pencil" : "checkmark")
                            .foregroundColor(!isUnsoldExpanded ? .black : .defaultTheme)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.defaultThemeLight)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            )
                    }

                    Button {
                        print("Pin tapped")
                    } label: {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.black)
                            .font(.system(size: 16, weight: .semibold))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color.defaultThemeLight)
                                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
                            )
                    }
                }

                
                
                // Price
                //            if let price = unit.price {
                //                Text(Double(price).compactCurrency())
                //                    .font(.custom(poppinsSemiBold, size: 13))
                //                    .foregroundColor(.defaultTheme)
                //            }
                
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background(Color.backGround)
            .cornerRadius(8)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isUnsoldExpanded.toggle()
                }
            }
            
            CollapsibleUnitSectionforproduct(
                title: "Unsold",
                count: unit.price ?? 0,
                isExpanded: $isUnsoldExpanded,
                accentColor: .orange
            ) {
                VStack(alignment: .leading, spacing: 8){
                AuthTextField(floatingLabel: "Price ($)".localized, placeholder: "Enter Price".localized, icon: .menuProfile, text: $price ,isIconDisplay : false,
                              custFontName : robotoMedium,
                              custFontSize : 14.0,
//                              height : 20.0 ,
                              enteredText:  { quantity in
                    //                    request.width = quantity
                })
                .keyboardType(.decimalPad)
                .padding(.vertical,4)
                
                AuthTextField(floatingLabel: "Description ".localized, placeholder: "Enter Description".localized, icon: .menuProfile, text:$description ,isIconDisplay : false,
                              custFontName : robotoMedium,
                              custFontSize : 14.0,
                              enteredText:  { quantity in
                    //                    request.width = quantity
                })
                .keyboardType(.decimalPad)
                .padding(.vertical,4)
            }
            .background(Color.backGround)
                
            }

        }
        .background(Color.backGround)
        .cornerRadius(14)
        .padding(.vertical,4)


    }
   private func success() {
        if let dict = viewModel.editProductPricedict {
            if dict.status == "success" {
                didUpdate()
            } else {
                print("API error: \(dict.status ?? "")")
            }
        }
    }
}

// MARK: - Available Item Row (shows product/item, not unit)
struct AvailableItemRow: View {
    let product: ProductItemResponse
    
    private var availableUnitsCount: Int {
        product.units?.filter { $0.status != "sold" }.count ?? 0
    }
    
    private var totalUnitsCount: Int {
        product.units?.count ?? 0
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Product Info
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name ?? "Product")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.black)
                
                if let description = product.description, !description.isEmpty {
                    Text(description)
                        .font(.custom(poppinsRegular, size: 11))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Units count
            Text("\(availableUnitsCount)/\(totalUnitsCount) units")
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(Color.backGround)
        .cornerRadius(8)
    }
}

// MARK: - Dynamic Product Row (Expandable)
struct DynamicProductRow: View {
    let product: ProductItemResponse
    var onUnitSelected: ((ProductSetUnit) -> Void)?
    
    @State private var isExpanded: Bool = false
    
    private var availableUnits: [ProductSetUnit] {
        product.units?.filter { $0.status != "sold" } ?? []
    }
    
    private var soldUnitsCount: Int {
        product.units?.filter { $0.status == "sold" }.count ?? 0
    }
    
    private var totalUnitsCount: Int {
        product.units?.count ?? 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Row (Tappable to expand/collapse)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .center, spacing: 12) {
                    // Product Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(product.name ?? "Product")
                            .font(.custom(poppinsSemiBold, size: 15))
                            .foregroundColor(.black)
                        
                        if let description = product.description, !description.isEmpty {
                            Text(description)
                                .font(.custom(poppinsRegular, size: 13))
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        // Units count info
                        HStack(spacing: 8) {
                            Text("Units: \(totalUnitsCount)")
                                .font(.custom(poppinsRegular, size: 12))
                                .foregroundColor(.gray)
                            
                            if availableUnits.count > 0 {
                                Text("• \(availableUnits.count) available")
                                    .font(.custom(poppinsRegular, size: 12))
                                    .foregroundColor(.green)
                            }
                            
                            if soldUnitsCount > 0 {
                                Text("• \(soldUnitsCount) sold")
                                    .font(.custom(poppinsRegular, size: 12))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Expand/Collapse chevron
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.defaultTheme)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Expanded Units List
            if isExpanded {
                Divider()
                    .padding(.horizontal, 12)
                
                if product.units?.isEmpty ?? true {
                    Text("No units available")
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(spacing: 6) {
                        ForEach(product.units ?? [], id: \.id) { unit in
                            UnitItemRow(unit: unit) {
                                onUnitSelected?(unit)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 8)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
    }
}

// MARK: - Unit Item Row
struct UnitItemRow: View {
    let unit: ProductSetUnit
    var onStartAuction: (() -> Void)?
    
    private var isSold: Bool {
        unit.status == "sold"
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            // Status indicator
            Circle()
                .fill(isSold ? Color.red : Color.green)
                .frame(width: 8, height: 8)
            
            // Unit Info
            VStack(alignment: .leading, spacing: 2) {
                Text(unit.name ?? "Unit #\(unit.id)")
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(isSold ? .gray : .black)
                
                if let price = unit.price {
                    Text(Double(price).compactCurrency())
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(isSold ? .gray : .defaultTheme)
                }
            }
            
            Spacer()
            
    // Status indicator
            if isSold {
                Text("Sold")
                    .font(.custom(poppinsSemiBold, size: 11))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.gray)
                    .cornerRadius(6)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(Color.backGround)
        .cornerRadius(8)
    }
}

// MARK: - Product Title Input
struct ProductTitleInput: View {
    @Binding var title: String
    @Binding var price: String
    
    var body: some View {
        HStack {
            TextField("Enter product title", text: $title)
                .font(.custom("Roboto-Regular", size: 15))
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(price)
                .font(.custom("Roboto-Medium", size: 16))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Category Progress Card
struct CategoryProgressCard: View {
    let category: String
    let condition: String
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(category) • \(condition)")
                .font(.custom("Roboto-Regular", size: 14))
                .foregroundColor(.black)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 6)
                    
                    // Progress with gradient
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: progress < 1.0
                                    ? [Color.green, Color.green.opacity(0.7)]
                                    : [Color.gray, Color.gray.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                    
                    // End dot
                    if progress < 1.0 {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 10, height: 10)
                            .offset(x: geometry.size.width * progress - 5)
                    }
                }
            }
            .frame(height: 10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Action Button
struct ActionTools: View {
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        Button(action: {}) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(Color(red: 0.4, green: 0.2, blue: 0.8))
                .frame(width: 50, height: 50)
                .background(backgroundColor)
                .clipShape(Circle())
        }
    }
}

// MARK: - Toggle Info Card (Enhanced)
struct ToggleInfoCardNew: View {
    struct Item: Identifiable {
        let id: String  // Use stable ID based on title
        let title: String
        let description: String
        let tint: Color
        @Binding var isOn: Bool
        
        init(title: String, description: String, tint: Color, isOn: Binding<Bool>) {
            self.id = title  // Use title as stable ID
            self.title = title
            self.description = description
            self.tint = tint
            self._isOn = isOn
        }
    }
    
    let items: [Item]
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.black)
                        
                        Text(item.description)
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: item.$isOn)
                        .labelsHidden()
                        .tint(item.tint)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Unsold Products Section
struct UnsoldProductsSection: View {
    @Binding var products: [UnsoldProduct]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unsold (\(products.count))")
                .font(.custom("Roboto-Bold", size: 18))
                .foregroundColor(.black)
            
            ForEach(products) { product in
                UnsoldProductRow(product: product)
            }
        }
    }
}

struct UnsoldProductRow: View {
    let product: UnsoldProduct
    
    var body: some View {
        HStack {
            Text("#\(product.number)")
                .font(.custom("Roboto-Medium", size: 16))
                .foregroundColor(.black)
            
            Spacer()
            
            Text("$\(Int(product.price))")
                .font(.custom("Roboto-Medium", size: 16))
                .foregroundColor(.black)
        }
        .padding(.vertical, 12)
        .overlay(
            HStack(spacing: 12) {
                ActionTools(
                    icon: "pin.fill",
                    backgroundColor: Color(red: 0.9, green: 0.93, blue: 0.98)
                )
                
                ActionTools(
                    icon: "square.and.pencil",
                    backgroundColor: Color(red: 0.9, green: 0.93, blue: 0.98)
                )
            }
            .padding(.leading, 16),
            alignment: .leading
        )
        .overlay(
            Divider()
                .background(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

// MARK: - Available Products Section
struct AvailableProductsSection: View {
    @Binding var products: [AvailableProduct]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Available (\(products.reduce(0) { $0 + $1.quantity }))")
                .font(.custom("Roboto-Bold", size: 18))
                .foregroundColor(.black)
            
            ForEach(products) { product in
                AvailableProductRow(product: product)
            }
        }
    }
}

struct AvailableProductRow: View {
    let product: AvailableProduct
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(product.name)
                    .font(.custom("Roboto-Medium", size: 16))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("Available")
                    .font(.custom("Roboto-Regular", size: 14))
                    .foregroundColor(.gray)
            }
            
            Text("Qty: \(product.quantity)")
                .font(.custom("Roboto-Regular", size: 14))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 12)
        .overlay(
            Divider()
                .background(Color.gray.opacity(0.2)),
            alignment: .bottom
        )
    }
}

