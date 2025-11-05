//
//  InventoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

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
                // Perform search logic here
                searchText = debouncedText
                currentPage = 1
                self.inventoryList.removeAll()
                fetchInventory(for: segment, page: 1)
            }
            .padding(.horizontal, 12)
            .padding(.top, 10)
            
            // MARK: - Inventory List
            ScrollView {
                VStack(spacing: 4) {
                    if inventoryList.count == 0{
                        NoDataView( message: AppString.NoInventoryFound.localized)
                    }else{
                        ForEach(0 ..< inventoryList.count, id: \.self) { index in
                            let inventory = inventoryList[index]
                            
                            ActiveInventoryScreen(inventory: inventory,didTapProduct: {
                                productId = inventory.id ?? 0
                                productData = inventory
                                showSellSheet = true
                            })
                                .onAppear {
                                    handlePagination(index: index)
                                }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 12)
            }
            CusNavLink(doNavigate: $navigateToCreateProduct, destination: ListProductScreen(productData:$productData))
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
            searchText = ""
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
                onTapEdit: {
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
