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
                                                                      processing_category:"")
    @Binding var thumbNail : String
    @State var productData = [ProductDataModel]()
    @State var viewModel = ScheduleViewModel()
    
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
//                RoundedRectangle(cornerRadius: 12)
//                    .fill(Color.gray.opacity(0.1))
//                    .frame(height: 80)
//                    .padding(.horizontal)
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
                    
                    HStack(spacing: 10) {
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
                .padding(.bottom, 25)
                Spacer()
                // Added Product Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Added Product")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    if productData.isEmpty{
                        Text("No product found")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                    }else{
                        ForEach(productData.indices, id: \.self) { index in
                            let data = productData[index]
                            let idStr = "\(data.id ?? -1)"
                            let isSelected = selectedProductIDs.contains(idStr)

                            HStack {
                                CustomProfileImage(
                                    url: data.images?.first,
                                    isCircular: false,
                                    size: 50,
                                    defaultImage: "fashion"
                                )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(data.title ?? "Untitled")
                                        .font(.custom(poppinsBold, size: 14))

                                    Text(data.category?.name ?? "Unknown Category")
                                        .font(.custom(poppinsSemiBold, size: 13))
                                        .foregroundColor(.gray)

                                    Text("Quantity: \(data.quantity ?? "")")
                                        .font(.custom(poppinsSemiBold, size: 13))
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(action: {
                                    navigateToEditProduct = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                }

                                Button(action: {
                                   
                                    deletedIndex = index
                                    deletedProductId = idStr
                                    // Delete action
                                    alertType = .sheetType(
                                        icon: .alert,
                                        title: "Delete!",
                                        message: "Are you sure, You want to delete this product.",
                                        primaryBtnText: "Yes",
                                        secondaryBtnText: "No"
                                    )
                                    showDeleteProduct = true
                               
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                            )
                            .onTapGesture {
                                // Animation
                                isTapped = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        isTapped = false
                                    }
                                }

                                // Selection toggle
                                if isSelected {
                                    selectedProductIDs = selectedProductIDs.filter({$0 != idStr})
//                                    productData.remove(at: index)
                                } else {
//                                    productData.append(data)
                                    selectedProductIDs.insert(idStr)
                                }
                                request.product_ids = selectedProductIDs.joined(separator: ",")
                            }
                        }

                    }
                }
                .padding(.horizontal)
                
//                Spacer()
               
            }
            
            Spacer()
            
            // Finish Button
            Button(action: handleFinishTapped) {
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
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight * 0.26,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showError = false
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation {
                            showError = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            navigateToTab = true
                        }
                    }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        
        .bottomSheet(
            isPresented: $showDeleteProduct,
            height: screenHeight * 0.37,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showDeleteProduct = false
            },  content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showDeleteProduct = false }
                    isTapped = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isTapped = false
                            if let index = deletedIndex {
                                productData.remove(at: index)
                                selectedProductIDs = selectedProductIDs.filter({$0 != deletedProductId ?? ""})
                            }
                           
                        }
                    }
                }, onSecondaryClick: {
                    withAnimation { showDeleteProduct = false }
                })
        })
            
//        
//        CusNavLink(doNavigate: $navigateToTab, destination: TabbarScreen())
        CusNavLink(doNavigate: $navigateToTab, destination:
            TabbarScreen()
                .environmentObject(TabBarRouter())
        )
        CusNavLink(doNavigate: $navigateToAddProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
        CusNavLink(doNavigate: $navigateToEditProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
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
            await viewModel.getProductList(parameters: UserProductRequest(user_id: "\(UserDefaults.userId)", category_id: request.category_id, page: page, type: "live"))
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
            await viewModel.getProductList(parameters: UserProductRequest(user_id: "\(UserDefaults.userId)", category_id: request.category_id, page: currentPage, type: "live"))
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
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
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
            await performSaveRequest()
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
    
    func performSaveRequest() async {
        await performAPICalls(
            isConcurrent: false,
            showLoader: true,
            onError: { _ in
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: viewModel.errorMessage ?? "",
                    primaryBtnText: AppString.ok.localized,
                    secondaryBtnText: ""
                )
                showError = true
            },
            onSuccess: {
                let response = viewModel.storeShowResponse

                alertType = .sheetType(
                    icon: .success,
                    title: "Success",
                    message: response?.message?.capitalized ?? "",
                    primaryBtnText: AppString.ok.localized,
                    secondaryBtnText: ""
                )
                showError = true
            }
        ) {
            var params: [String: Any] = [
                "title": request.title,
                "date": request.date,
                "time": request.time,
                "category_id": request.category_id,
                "auction_type_id": request.auction_type_id
            ]

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


}

