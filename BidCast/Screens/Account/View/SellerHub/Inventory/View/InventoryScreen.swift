//
//  InventoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

enum InventoryNavigation {
    case account
    case addProduct
    
    var btnTitle: String  {
        switch self {
        case .account:
            return AppString.newProduct.localized
        case .addProduct:
            return AppString.selectedProduct.localized
        }
    }
}

// MARK: - InventoryScreen
struct InventoryScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var segment: InventorySegment = .active
    @State var inventoryList: [InventoryDataModel] = []
    @State var request: InventoryRequest = InventoryRequest(status: "active", page: 1)
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var viewModel = InventoryViewModel()
    @State var productId : Int = 0
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var status = "active"
    @State var currentPage = 1
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showSellSheet = false
    @State var productData : InventoryDataModel
    @State var navigateToCreateProduct = false
    @State var searchText: String = ""
    
    @Binding var selectedProductIDs: Set<String>
    @Binding var selectedProductData: [ProductDataModel]
    @State var productToEdit: ProductDataModel?
    @State var selectedCategoryId: String = ""
    
    var navigatedFrom: InventoryNavigation = .account
    @State private var navigateToCreateNewProduct = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            VStack{
                PrimaryHeader(
                    title: AppString.Inventory.localized,
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName], // logo on left
                    trailingImgArr: [],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    onClickTrailing: nil,
                    count: .constant(0)
                )
                
            }
            // MARK: - Segment
            CustomSegmentedControl(preselectedIndex: $segment, options: InventorySegment.allCases)
                .padding(.horizontal, 12)
                .background(Color.white)
                .onChange(of: segment) { newSegment in
                    status = newSegment.rawValue.lowercased()
                    currentPage = 1
                    searchText = ""
                    self.inventoryList.removeAll()
                    fetchInventory(for: newSegment, page: 1)
                }
            
            // MARK: - Search
            SearchView { debouncedText in
                print("User stopped typing. Search: \(debouncedText)")
                guard !debouncedText.isEmpty else {
                    return
                }
                // Perform search logic here
                searchText = debouncedText
                currentPage = 1
                self.inventoryList.removeAll()
                fetchInventory(for: segment, page: 1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // MARK: - Inventory List
            ScrollView {
                LazyVStack(spacing: 4) {
                    if inventoryList.count == 0{
                        NoDataView( message: AppString.NoInventoryFound.localized)
                    }else{
                        ForEach(0 ..< inventoryList.count, id: \.self) { index in
                            let inventory = inventoryList[index]
                            
                            ActiveInventoryScreen(inventory: inventory,
                                                  didTapProduct: {
                                if navigatedFrom == .account {
                                    productId = inventory.id ?? 0
                                    productData = inventory
                                    showSellSheet = true
                                }
                                else  {
                                    if !selectedProductIDs.contains("\(inventory.id ?? 0)") {
                                        selectedProductIDs.insert("\(inventory.id ?? 0)")
                                        selectedProductData.append(inventory.toProductDataModel())
                                    }
                                }
                            },
                                                  navigatedFrom: navigatedFrom
                            )
                            .onAppear {
                                handlePagination(index: index)
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, -20)
            }

            
            TwoButton(titleOne: navigatedFrom.btnTitle,
                      onFirstButtonClick: {
                switch navigatedFrom {
                case .account:
                    print("create new Prooduct")
                    navigateToCreateProduct = true
                case .addProduct:
                    print("Select Existing Product")
                    self.presentationMode.wrappedValue.dismiss()
                }
            },
                      
                      onSecButtonClick: {  },
                      firstBtnBgColor: .defaultTheme,
                      isHidefirstBtn: false,
                      isHideSecBtn: true
            )
            .padding(.top, 20)
            .padding(.bottom, -15)
            
            CusNavLink(doNavigate: $navigateToCreateProduct, destination: ListProductScreen(productData:.constant(productData))) // for edit
            CusNavLink(doNavigate: $navigateToCreateNewProduct,
                       destination: CreateProductScreen(requests: .constant(StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")),
                                                        thumbNail: .constant(""),
                                                        backToPrepare: .constant(false),
                                                        fromPrepare: .constant(false),
                                                        isComeFrom: .inventry))
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
            searchText = ""
            currentPage = 1
            segment = .active
            request.search = searchText
            selectedCategoryId = navigatedFrom == .account ? "" : selectedCategoryId
            fetchInventory(for: segment, page: currentPage)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
        .bottomSheet(isPresented: $showSellSheet, height: screenHeight * 0.95) {
            
            ProductDetailSheet(
                onDismiss : {
                    self.showSellSheet = false
                    productId = 0
                },
                productID: $productId,
                onTapEdit: { details  in
//                    productToEdit = details
                    
                    navigateToCreateProduct = true
                },onTapDelete: {
                    SVProgressHUD.show()
                    let param = DeleteProduct(product_id: productId)
                    await viewModel.DeleteProductRequest(parameters: param)
                    await SVProgressHUD.dismiss()
                    deleteProductSuccess()
                }
            )
        }
    }
    
    func handlePagination(index: Int) {
        let isLastItem = index == inventoryList.count - 1
        let canFetchMore = (viewModel.inventoryDict?.total ?? 0) > inventoryList.count

        if isLastItem && canFetchMore {
            fetchMoreInventory()
        }
    }
    
    // MARK: - Fetch Inventory List
    func fetchInventory(for segment: InventorySegment,page: Int) {
        Task{
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            request.status = segment.rawValue.lowercased()
            request.page = page
            request.search = searchText
            request.category_id = selectedCategoryId
            await viewModel.getInventoryList(param: request)
            await SVProgressHUD.dismiss()
            handleDataLoad()
        }
    }
    
    // MARK: - Handle ViewModel Data
    func handleDataLoad() {
        SVProgressHUD.dismiss()
        let response = viewModel.inventoryDict
        if response?.status == "success" {
            // append new data
            self.inventoryList.append(contentsOf: response?.data ?? [])
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
    // MARK: - deleteProductSuccess
    func deleteProductSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.inventoryDict
        if response?.status == "success" {
            self.showSellSheet = false
            currentPage = 1
            self.inventoryList.removeAll()
            fetchInventory(for: segment, page: 1)
            
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    func fetchMoreInventory() {
        Task {
            currentPage += 1
            request.status = status
            request.page = currentPage
            request.category_id = selectedCategoryId
            await viewModel.getInventoryList(param: request)
            handleDataLoad()
        }
    }
}

// MARK: - Inventory Segment Enum
enum InventorySegment: String, CaseIterable, CustomStringConvertible {
    case active = "Active"
    case draft = "Draft"
    case inactive = "Inactive"
    
    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}
