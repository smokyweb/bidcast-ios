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
    var viewModel = InventoryViewModel()
    
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var status = "active"
    @State var currentPage = 1
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
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
                .background(Color.bg.opacity(0.5))
                .onChange(of: segment) { newSegment in
                    status = newSegment.rawValue.lowercased()
                    currentPage = 1
                    self.inventoryList.removeAll()
                    fetchInventory(for: newSegment, page: 1)
                }
            
            // MARK: - Search
            SearchView()
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
                            
                            ActiveInventoryScreen(inventory: inventory)
                                .onAppear {
                                    handlePagination(index: index)
                                }
                        }
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 12)
            }
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
            
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
            SVProgressHUD.show()
            request.status = segment.rawValue.lowercased()
            request.page = page
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
