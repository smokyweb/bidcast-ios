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
    @Binding var thumbNail : String
    @State var productData = [ProductDataModel]()
    @State var viewModel = ScheduleViewModel()
    
    @State var selectedProductIDs: [String] = []
    @State var navigateToInventry: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var navigateToTab = false
    
    @Binding var fromPrepare : Bool
    @Binding var backToPrepare : Bool
    @Binding var NavFromProductLibrary : Bool
    @State var navigateToAddProduct  = false
    @Binding var backToCreateProduct : Bool
    var delegate: ShowStepDelegate?
    
    
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Header
            VStack{
                PrimaryHeader(
                    title: "Add Products".localized,
                    isForLogo : false ,
                    leadingImgArr:[.icBack],
                    onClickLeading: { _ in
                        if backToCreateProduct{
                            backToCreateProduct = false
                        }else{
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    },
                    count: .constant(0)
                )
            }
            ScrollView{
                // Placeholder for banner/image box
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 80)
                    .padding(.horizontal)
                Spacer()
                // Added Product Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Added Product")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    if productData.isEmpty{
                        Text("No product found")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                    }else{
                        ForEach(productData.indices, id:\.self ){ index in
                            let data = productData[index]
                            let idStr = "\(data.id ?? -1)"
                            let isSelected = selectedProductIDs.contains(idStr)
                            HStack {
                                CustomProfileImage(url: data.images?.first, isCircular: false, size: 50, defaultImage: "fashion")
//                                if let urlString = data.images?.first, let url = URL(string: urlString) {
//                                    AsyncImage(url: url) { image in
//                                        image.resizable()
//                                    } placeholder: {
//                                        Color.gray
//                                    }
//                                    .frame(width: 50, height: 50)
//                                    .clipShape(RoundedRectangle(cornerRadius: 8))
//                                } else {
//                                    Image("fashion") // Fallback asset
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 50, height: 50)
//                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(data.title ?? "Untitled")
                                        .font(.custom(poppinsBold, size: 14.0))
                                    Text(data.category?.name ?? "Unknown Category")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .foregroundColor(.gray)
                                    Text("Quantity: \(data.quantity ?? "")")
                                        .font(.custom(poppinsSemiBold, size: 13.0))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    // Edit product
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }
                                
                                Button(action: {
                                    // Delete product
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                                
                                Button(action: {
                                    if isSelected {
                                        selectedProductIDs.removeAll { $0 == idStr }
                                    } else {
                                        selectedProductIDs.append(idStr)
                                    }
                                    request.product_ids = selectedProductIDs.joined(separator: ",")
                                }) {
                                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(isSelected ? .green : .gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                // Add More Section
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Add More Products")
                            .fontWeight(.semibold)
                        Spacer()
                        Text("\(productCount)/100")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    }
                    
                    VStack(spacing: 16) {
                        addProductOption(text: "Add another product") {
                            if NavFromProductLibrary{
                                presentationMode.wrappedValue.dismiss()
                            }else{
                                backToCreateProduct = false
                            }
                            
                        }
                        addProductOption(text: "Select from product Inventory"){
//                            presentationMode.wrappedValue.dismiss()
                            navigateToInventry = true
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            
            // Finish Button
            Button(action: {
                print(request)
                guard !request.title.isEmpty else {
                    hudMsg = "Please enter title"
                    showhud = true
                    return
                }
                guard !request.category_id.isEmpty else {
                    hudMsg = "Please enter category type"
                    showhud = true
                    return
                }
                guard !request.auction_type_id.isEmpty else {
                    hudMsg = "Please enter auction type"
                    showhud = true
                    return
                }
                guard !thumbNail.isEmpty else {
                    hudMsg = "Please select thumbnail image"
                    showhud = true
                    return
                }
                guard !request.date.isEmpty else {
                    hudMsg = "Please enter date"
                    showhud = true
                    return
                }
                guard !request.time.isEmpty else {
                    hudMsg = "Please select time"
                    showhud = true
                    return
                }
                guard !request.product_ids.isEmpty else {
                    hudMsg = "Please select product"
                    showhud = true
                    return
                }
                if fromPrepare{
                    backToPrepare = false
                    delegate?.didUpdateRequest(request,thumbNail: self.thumbNail)
                }else{
//                    Task{
//                       guard Reachability.isConnectedToNetwork() else {
//                            hudMsg = "No Internet Connection"
//                            showhud = true
//                            return
//                        }
//                        SVProgressHUD.show()
//                        var thumbImage = [String]()
//                        thumbImage.append(thumbNail)
//                        self.viewModel.errorMessage = ""
//                        var param: [String: Any] = [
//                            "title": request.title,
//                            "date": request.date,
//                            "time": request.time,
//                            "category_id": request.category_id,
//                            "auction_type_id": request.auction_type_id,
//                        ]
//                        let products = request.product_ids.toIntArray()
//                        for (index, product) in products.enumerated() {
//                            param["product_ids[\(index)]"] = product
//                        }
//                        await viewModel.storeScheduleShow(param: param,images: [thumbNail],key: "thumbnail[]")
//                        await SVProgressHUD.dismiss()
//                        
//                        if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
//                            storeSuccess()
//                        }else{
//                            alertType = .sheetType(
//                                icon: .alert,
//                                title: "Error",
//                                message: viewModel.errorMessage ?? "",
//                                primaryBtnText: AppString.ok.localized,
//                                secondaryBtnText:""
//                            )
//                            showError = true
//                        }
//                        
//                    }
                    
                    Task {
                        await performAPICalls(
                            isConcurrent: false,
                            showLoader: true,
                            onError: { error in
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: "Error",
                                    message: viewModel.errorMessage ?? "",
                                    primaryBtnText: AppString.ok.localized,
                                    secondaryBtnText: ""
                                )
                                showError = true
                            }
                        ) {
                            var thumbImage = [String]()
                            thumbImage.append(thumbNail)
                            self.viewModel.errorMessage = ""

                            // Prepare request parameters
                            var param: [String: Any] = [
                                "title": request.title,
                                "date": request.date,
                                "time": request.time,
                                "category_id": request.category_id,
                                "auction_type_id": request.auction_type_id
                            ]

                            // Convert product IDs into array format
                            let products = request.product_ids.toIntArray()
                            for (index, product) in products.enumerated() {
                                param["product_ids[\(index)]"] = product
                            }

                            // 🔹 API Call
                            await viewModel.storeScheduleShow(param: param, images: [thumbNail], key: "thumbnail[]")
                            let response = viewModel.storeShowResponse
                            alertType = .sheetType(
                                icon: .success,
                                title: "Successs",
                                message: response?.message?.capitalized ?? "",
                                primaryBtnText: AppString.ok.localized,
                                secondaryBtnText:""
                            )
                            showError = true
                        }
                    }

                }
            }) {
                Text("Finish")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.defaultTheme)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .bottom])
            
            
        }
        .navigationBarHidden(true)
        .onFirstAppear{
            fetchProduct(page: currentPage)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight/2.8, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            if viewModel.errorMessage != nil || viewModel.errorMessage != "" {
                showError = true
            }else{
                
                showError = false
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                        backToPrepare = false
                        withAnimation { showError = false }
                        
                    }else{
                        withAnimation { showError = false }
                        
                    }
                    
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        CusNavLink(doNavigate: $navigateToTab, destination: TabbarScreen())
        CusNavLink(doNavigate: $navigateToAddProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
        CusNavLink(doNavigate: $navigateToInventry,
                   destination: InventoryScreen(productData: InventoryDataModel(),
                                                selectedProductIDs: $selectedProductIDs,
                                                selectedProductData: $productData,
                                                selectedCategoryId: request.category_id,
                                                navigatedFrom: .addProduct))
    }
    
    
    // MARK: - Add Product Tile
    private func addProductOption(text: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                Image(systemName: "plus")
                    .foregroundColor(.gray)
                Text(text)
                    .foregroundColor(.gray)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
            )
        }
    }

}

//MARK: API LOGIC.
extension AddProductsScreen{
    
    // MARK: - Fetch Inventory List
    func fetchProduct(page: Int) {
        Task{
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            await viewModel.getProductList(parameters: UserProductRequest(user_id: UserDefaults.userId, category_id: request.category_id, page: page))
            await SVProgressHUD.dismiss()
            productSuccess()
        }
    }
    
    //MARK: fetchMoreProduct.
    func fetchMoreProduct() {
        Task {
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            currentPage += 1
            await viewModel.getProductList(parameters: UserProductRequest(user_id: UserDefaults.userId, category_id: request.category_id, page: currentPage))
            productSuccess()
        }
    }
    
    //MARK: handlePagination.
    func handlePagination(index: Int) {
        let isLastItem = index == productData.count - 1
        let canFetchMore = (viewModel.productResponse?.total ?? 0) > productData.count

        if isLastItem && canFetchMore {
            fetchMoreProduct()
        }
    }
    
    
    //MARK: productSuccess.
    func productSuccess(){
        let response = viewModel.productResponse
        if response?.status == "success"{
            productData = response?.data ?? [ProductDataModel]()
        }else{
            alertType = .sheetType(
                icon: .success,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
}

