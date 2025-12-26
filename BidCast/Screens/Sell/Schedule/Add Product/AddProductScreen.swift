//
//  AddProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct AddProductsScreen: View {
    
    @EnvironmentObject  var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var productCount = 1
    @State var currentPage = 1
    @Environment(\.presentationMode) var presentationMode
    @Binding var request : StoreScheduleShowRequest
    @State var productDetails: StoreProductParam =  StoreProductParam(category_id: "",
                                                                      title: "",
                                                                      description: "",
                                                                      quantity: "1",
                                                                      pricing: "",
                                                                      flash_sale: "0",
                                                                      accept_offers: "0",
                                                                      reserve_for_live: "0",
                                                                      shipping_profile_id: "4",
                                                                      status: "",
                                                                      sub_category_id: "",
                                                                      width: "",
                                                                      length: "",
                                                                      weight: "",
                                                                      height:"",
                                                                      mail_class:"",
                                                                      processing_category:"", product_condition: "")
    @Binding var thumbNail : String
    @State var productData = [ProductDataModel1]()
    @State var viewModel = ScheduleViewModel()
    @State var productViewModel = ProductViewModel()
    
    @State var deletedIndex: Int?
    @State var deletedProductId: String?
    
    @State private var isTapped = false
    @State var selectedProductIDs: Set<String> = []
    
    @State var navigateToInventry: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var showDeleteProduct: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var navigateToTab = false
    
    @Binding var fromPrepare : Bool
    @Binding var backToPrepare : Bool
    @Binding var NavFromProductLibrary : Bool
    @State var navigateToAddProduct  = false
    @State var navigateToEditProduct  = false
    @Binding var backToCreateProduct : Bool
    var didTapBack : ((Bool) -> Void)?
    var delegate: ShowStepDelegate?
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                PrimaryHeader(
                    title: "Add Products".localized,
                    isForLogo : false ,
                    leadingImgArr:["chevron.left"],
                    onClickLeading: { _ in
                        if backToCreateProduct{
                            didTapBack?(true)
                            backToCreateProduct = false
                        }else{
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    },
                    count: .constant(0)
                )
                
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Add More Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Add More Products")
                                    .font(.custom(poppinsSemiBold, size: 16))
                                    .foregroundColor(.primary)
                                Spacer()
                                Text("\(productData.count)/100")
                                    .font(.custom(poppinsMedium, size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack(spacing: 12) {
                                addProductOption(text: "Add another product") {
                                    if NavFromProductLibrary{
                                        didTapBack?(true)
                                        presentationMode.wrappedValue.dismiss()
                                    }else{
                                        didTapBack?(true)
                                        backToCreateProduct = false
                                    }
                                }
                                
                                addProductOption(text: "Select from product Inventory"){
                                    navigateToInventry = true
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        
                        // Added Product Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Added Products")
                                .font(.custom(poppinsSemiBold, size: 16))
                                .foregroundColor(.primary)
                            
                            if productData.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "cube.box")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray.opacity(0.4))
                                    
                                    Text("No product found")
                                        .font(.custom(poppinsMedium, size: 15))
                                        .foregroundColor(.secondary)
                                    
                                    Text("Add products to your show")
                                        .font(.custom(poppinsRegular, size: 13))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 60)
                                
                            } else {
                                ForEach(productData.indices, id: \.self) { index in
                                    let data = productData[index]
                                    let idStr = "\(data.id ?? -1)"
                                    let isSelected = selectedProductIDs.contains(idStr)
                                    
                                    ProductItemCard(
                                        product: data,
                                        isSelected: isSelected,
                                        onTapCard: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                if isSelected {
                                                    selectedProductIDs.remove(idStr)
                                                } else {
                                                    selectedProductIDs.insert(idStr)
                                                }
                                                request.product_ids = selectedProductIDs.joined(separator: ",")
                                            }
                                        },
                                        onTapEdit: {
//                                            navigateToEditProduct = true
                                        },
                                        onTapDelete: {
                                            deletedIndex = index
                                            deletedProductId = idStr
                                            config = BottomSheetConfig(
                                                   icon: "trash.circle.fill",
                                                   title: "Delete Product?",
                                                   message:  "Are you sure you want to remove this product?",
                                                   primaryButtonTitle: "Delete",
                                                   secondaryButtonTitle: "Cancel"
                                               )
                                            showDeleteProduct = true
                                            
                                        }
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        // Bottom spacing for button
                        Spacer()
                            .frame(height: 100)
                    }
                }
                
                // Fixed Bottom Button
                VStack(spacing: 0) {
                    Divider()
                        .background(Color.gray.opacity(0.2))
                    
                    Button(action: handleFinishTapped) {
                        Text("Finish")
                            .font(.custom(poppinsSemiBold, size: 17))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color.defaultTheme, Color.defaultTheme.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(14)
                            .shadow(color: Color.defaultTheme.opacity(0.3), radius: 12, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)
                }
                .background(Color(UIColor.systemBackground))
                .padding(.bottom, -106)
            }
            .zIndex(0)
            
//            // Dimmed Background for Bottom Sheets
//            if showError || showDeleteProduct {
//                Color.black.opacity(0.4)
//                    .ignoresSafeArea()
//                    .onTapGesture {
//                        withAnimation {
//                            showError = false
//                            showDeleteProduct = false
//                        }
//                    }
//                    .zIndex(998)
//            }
        }
        .navigationBarHidden(true)
//        .ignoresSafeArea(edges: .bottom)
        .background(.backGround)
        .onAppear {
            // CRITICAL: Explicitly set all bottom sheet states to false on appear
            showError = false
            showDeleteProduct = false
        }
        .onFirstAppear{
            fetchProduct(page: currentPage)
            
            loadSelectedProductsFromRequest()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        // IMPORTANT: Only attach bottom sheet modifiers when actually showing
//        .modifier(ConditionalBottomSheet(
//            isPresented: $showError,
//            height: screenHeight * 0.3,
//            content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation {
//                            showError = false
//                        }
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            navigateToTab = true
//                        }
//                    },
//                    onSecondaryClick: {
//                        withAnimation {
//                            showError = false
//                        }
//                    }
//                )
//            }
//        ))
//        .modifier(ConditionalBottomSheet(
//            isPresented: $showDeleteProduct,
//            height: screenHeight * 0.35,
//            content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation {
//                            showDeleteProduct = false
//                        }
//                        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                            if let index = deletedIndex {
//                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                                    productData.remove(at: index)
//                                    if let productId = deletedProductId {
//                                        selectedProductIDs.remove(productId)
//                                        request.product_ids = selectedProductIDs.joined(separator: ",")
//                                    }
//                                    deletedIndex = nil
//                                    deletedProductId = nil
//                                }
//                            }
//                        }
//                    },
//                    onSecondaryClick: {
//                        withAnimation {
//                            showDeleteProduct = false
//                        }
//                        deletedIndex = nil
//                        deletedProductId = nil
//                    }
//                )
//            }
//        ))
        .overlay(
            CustomBottomSheetView(
                isPresented: $showError,
                config: config,
                primaryAction: {
                    withAnimation {
                        showError = false
                        if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                navigateToTab = true
                            }
                        }else{
                            
                        }
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showError = false
                    }
                }
            )
        )
        .overlay(
            CustomBottomSheetView(
                isPresented: $showDeleteProduct,
                config: config,
                primaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        if let index = deletedIndex {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                productData.remove(at: index)
                                if let productId = deletedProductId {
                                    selectedProductIDs.remove(productId)
                                    request.product_ids = selectedProductIDs.joined(separator: ",")
                                }
                                deletedIndex = nil
                                deletedProductId = nil
                            }
                        }
                    }
                },
                secondaryAction: {
                    withAnimation {
                        showDeleteProduct = false
                    }
                }
            )
        )

        
        CusNavLink(doNavigate: $navigateToTab, destination:
            TabbarScreen()
                .environmentObject(TabBarRouter())
        )
        CusNavLink(doNavigate: $navigateToAddProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
        CusNavLink(doNavigate: $navigateToEditProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
        //toDo: Need to change
//        CusNavLink(doNavigate: $navigateToInventry,
//                   destination: InventoryScreen(productData: ProductDataModel1(),
//                                                selectedProductIDs: $selectedProductIDs,
//                                                selectedProductData: $productData,
//                                                selectedCategoryId: [Int(request.category_id) ?? 0],
//                                                navigatedFrom: .addProduct))
    }
    
    
    // MARK: - Add Product Tile
    private func addProductOption(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.defaultTheme)
                
                Text(text)
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(Color.white)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 6]))
                    .foregroundColor(.defaultTheme.opacity(0.3))
            )
            .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}


// MARK: - Product Item Card
struct ProductItemCard: View {
    let product: ProductDataModel1
    let isSelected: Bool
    let onTapCard: () -> Void
    let onTapEdit: () -> Void
    let onTapDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            // Product Image
            CustomProfileImage(
                url: product.images?.first ?? "",
                isCircular: false,
                cornerRadius: 12,
                size: 70,
                height: 70,
                defaultImage: "fashion"
            ) {}
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)
            
            // Product Details
            VStack(alignment: .leading, spacing: 6) {
                Text(product.title ?? "Untitled")
                    .font(.custom(poppinsSemiBold, size: 15))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(product.category?.name ?? "Unknown Category")
                    .font(.custom(poppinsMedium, size: 13))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Text("Qty:")
                        .font(.custom(poppinsRegular, size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(product.quantity ?? "0")
                        .font(.custom(poppinsSemiBold, size: 12))
                        .foregroundColor(.primary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: onTapEdit) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.defaultTheme)
                        .frame(width: 36, height: 36)
                        .background(Color.defaultThemeLight)
                        .cornerRadius(10)
                }
                
                Button(action: onTapDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isSelected ? Color.defaultTheme : Color.black.opacity(0.08),
                    lineWidth: isSelected ? 2.5 : 1
                )
        )
        .shadow(color: .black.opacity(isSelected ? 0.12 : 0.06), radius: isSelected ? 12 : 6, x: 0, y: isSelected ? 4 : 2)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .onTapGesture(perform: onTapCard)
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

//MARK: API LOGIC.
extension AddProductsScreen {
    
    // MARK: - Fetch Inventory List
    func fetchProduct(page: Int) {
        Task{
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: productViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    productSuccess()
                }
            ) {
                try  await productViewModel.getProductsData1(parameters: ProductRequest(user_id: "\(UserDefaults.userId)",
                                                                                       category_ids: request.category_id,
                                                                                       page: currentPage))
            }
        }
    }
    
    //MARK: fetchMoreProduct.
    func fetchMoreProduct() {
        Task{
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: productViewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    productSuccess()
                }
            ) {
                currentPage += 1
                try  await productViewModel.getProductsData1(parameters: ProductRequest(user_id: "\(UserDefaults.userId)",
                                                                                       category_ids: request.category_id,
                                                                                       page: currentPage))
            }
        }
    }
    
    //MARK: handlePagination.
    func handlePagination(index: Int) {
        let isLastItem = index == productData.count - 1
        let canFetchMore = (productViewModel.productsResponse1?.total ?? 0) > productData.count

        if isLastItem && canFetchMore {
            fetchMoreProduct()
        }
    }
    
    func loadSelectedProductsFromRequest() {
           // Parse product_ids from request (comma-separated string)
           if !request.product_ids.isEmpty {
               let productIds = request.product_ids
                   .split(separator: ",")
                   .map { String($0).trimmingCharacters(in: .whitespaces) }
               
               selectedProductIDs = Set(productIds)
               
               print("✅ Pre-selected \(selectedProductIDs.count) products from request:")
               print("   Product IDs: \(Array(selectedProductIDs).joined(separator: ", "))")
           }
       }
    //MARK: productSuccess.
    func productSuccess(){
        let response = productViewModel.productsResponse1
        if response?.status == "success"{
//            productData = response?.data ?? [ProductDataModel1]()
            let newProducts = response?.data ?? [ProductDataModel1]()
                       
                       // If this is the first page, replace data
                       if currentPage == 1 {
                           productData = newProducts
                       } else {
                           // If paginating, append new products
                           productData.append(contentsOf: newProducts)
                       }
                       
                       // ⭐ IMPORTANT: Re-validate selectedProductIDs after loading products
                       // Remove any IDs that don't exist in the loaded products
                       let validProductIds = Set(productData.compactMap {
                           $0.id != nil ? String($0.id!) : nil
                       })
                       selectedProductIDs = selectedProductIDs.intersection(validProductIds)
                       
                       // Update request with valid IDs
                       request.product_ids = selectedProductIDs.joined(separator: ",")
                       
                       print("✅ Loaded \(productData.count) products")
                       print("   Valid selected IDs: \(Array(selectedProductIDs).joined(separator: ", "))")
        }else{
            config = BottomSheetConfig(
                icon: "exclamationmark.circle",
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryButtonTitle: AppString.ok.localized,
                secondaryButtonTitle: nil,
              
            )
            showError = true
        }
    }
    
    func handleFinishTapped() {
        print(request)

        if let error = validateRequest() {
            hudMsg = error
            showhud = true
            return
        }
        
        if fromPrepare {
            backToPrepare = false
            delegate?.didUpdateRequest(request, thumbNail: thumbNail)
            return
        }
        
        Task {
            if request.show_id != "" && request.show_id != nil {
                await performUpdateRequest()
            }else{
                await performSaveRequest()
            }
        }
        
    }

    func validateRequest() -> String? {
        if request.title.isEmpty { return "Please enter title" }
        if request.category_id.isEmpty { return "Please enter category type" }
        if request.auction_type_id.isEmpty { return "Please enter auction type" }
        if thumbNail.isEmpty { return "Please select thumbnail image" }
        if request.date.isEmpty { return "Please enter date" }
        if request.time.isEmpty { return "Please select time" }
        if selectedProductIDs.isEmpty { return "Please select product" }

        return nil
    }
    func performUpdateRequest() async {
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.circle",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.storeShowResponse

                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: response?.message?.capitalized ?? "",
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil,
                    bottomPadding: -80,
                    backgroundDismissal: true
                )
                showError = true
            }
        ) {
            var params: [String: Any] = [
                "show_id" : request.show_id ?? "",
                "title": request.title,
                "date": request.date,
                "time": request.time,
                "category_id": request.category_id,
                "auction_type_id": request.auction_type_id,
                "show_discoverability": request.show_discoverability,
                "repeat_value": request.repeat_value,
                "language": request.language,
                
            ]
            if request.is_explicit{
                params["is_explicit"] = 1
            }else{
                params["is_explicit"] = 0
            }
            
            if request.is_repeat{
                params["is_repeat"] = 1
            }else{
                params["is_repeat"] = 0
            }

            // Convert product IDs
            var prodIds = Array(selectedProductIDs)
            for (index, product) in prodIds.enumerated() {
                params["product_ids[\(index)]"] = product
            }

            viewModel.errorMessage = ""

            try await viewModel.updateScheduleShow(
                param: params,
                images: [thumbNail],
                key: "thumbnail[]"
            )
        }
    }
    func performSaveRequest() async {
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { error in
                config = BottomSheetConfig(
                    icon: "exclamationmark.circle",
                    title: "Error",
                    message: errorDesc(error: error, message: viewModel.errorMessage),
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.storeShowResponse

                config = BottomSheetConfig(
                    icon: "checkmark.circle.fill",
                    title: "Success",
                    message: response?.message?.capitalized ?? "",
                    primaryButtonTitle: AppString.ok.localized,
                    secondaryButtonTitle: nil,
                    bottomPadding: -80,
                    backgroundDismissal: true
                )
                showError = true
            }
        ) {
            var params: [String: Any] = [
                "title": request.title,
                "date": request.date,
                "time": request.time,
                "category_id": request.category_id,
                "auction_type_id": request.auction_type_id,
                "show_discoverability": request.show_discoverability,
                "repeat_value": request.repeat_value,
                "language": request.language,
                
            ]
            if request.is_explicit{
                params["is_explicit"] = 1
            }else{
                params["is_explicit"] = 0
            }
            
            if request.is_repeat{
                params["is_repeat"] = 1
            }else{
                params["is_repeat"] = 0
            }

            // Convert product IDs
            var prodIds = Array(selectedProductIDs)
            for (index, product) in prodIds.enumerated() {
                params["product_ids[\(index)]"] = product
            }

            viewModel.errorMessage = ""

            try await viewModel.storeScheduleShow(
                param: params,
                images: [thumbNail],
                key: "thumbnail[]"
            )
        }
    }
    
    private func errorDesc(error: Error?, message: String?) -> String {
        guard let msg = message else {
            return error?.localizedDescription ?? "Something went wrong"
        }
        return msg
    }
    
}

import SwiftUI

struct CustomBottomSheetView: View {
    
    @Binding var isPresented: Bool
    var config: BottomSheetConfig
    
    /// Actions moved here (this is what you wanted)
    var primaryAction: (() -> Void)? = nil
    var secondaryAction: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            
            // Dim background
            if isPresented {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation { isPresented = config.backgroundDismissal }
                    }
            }
            
            VStack {
                Spacer() // PUSH TO BOTTOM
                
                if isPresented {
                    VStack(spacing: 16) {
                        
                        if let icon = config.icon {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                                .padding(.top, 20)
                        }
                        
                        Text(config.title)
                            .font(.custom(poppinsBold, size: 24.0))
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        Text(config.message)
                            .font(.custom(poppinsMedium, size: 18.0))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        
                        if config.showButtons {
                            VStack(spacing: 10) {
                                
                                if let title = config.primaryButtonTitle {
                                    Button {
                                        primaryAction?()
                                        withAnimation { isPresented = false }
                                    } label: {
                                        Text(title)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.defaultTheme)
                                            .cornerRadius(12)
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: screenWidth/1.5, height: 40)
                                    .padding(.bottom, 12)
                                    .padding(.top, 20)
                                }
                                
                                if let title = config.secondaryButtonTitle {
                                    Button {
                                        secondaryAction?()
                                        withAnimation { isPresented = false }
                                    } label: {
                                        Text(title)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 8)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(12)
                                            .foregroundColor(.black)
                                    }
                                    .frame(width: screenWidth/1.5, height: 40)
                                    .padding(.bottom, 20)
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        
                        Spacer().frame(height: 20)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(25, corners: [.topLeft, .topRight])
//                    .ignoresSafeArea(edges: .bottom)
                    .padding(.bottom, config.bottomPadding)
//                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut(duration: 0.25), value: isPresented)

                }
            }
        }
    }
}



struct BottomSheetConfig {
    var icon: String? = nil
    var title: String
    var message: String

    var primaryButtonTitle: String? = nil
    var secondaryButtonTitle: String? = nil

    var showButtons: Bool = true
    var bottomPadding : CGFloat = -90
    var backgroundDismissal : Bool = false
}


