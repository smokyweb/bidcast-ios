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
    @State private var inventoryList: [InventoryDataModel] = []
    @State var request: InventoryRequest = InventoryRequest(status: "active")
    var viewModel = InventoryViewModel()

    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
//            VStack{
//                PrimaryHeader(
//                    title: "Inventory".localized,
//                    isForLogo: false,
//                    leadingImgArr: [.icBack],
//                    trailingImgArr: [],
//                    onClickLeading: { _ in
//                        self.presentationMode.wrappedValue.dismiss()
//                    },
//                    count: .constant(0)
//                )
//                .background(Color.white)
//            }
            VStack{
                PrimaryHeader(
                    title: "Inventory".localized,
                    isForLogo: true,
                    leadingImgArr: [.appName], // logo on left
                    trailingImgArr: [],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                        // maybe open menu or do nothing
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
                    fetchInventory(for: newSegment)
                }

            // MARK: - Search
            SearchView()
                .padding(.horizontal, 12)
                .padding(.top, 10)

            // MARK: - Inventory List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(inventoryList, id: \.id) { inventory in
                        ActiveInventoryScreen(inventory: inventory)
                    }
                }
                .padding(.top, 10)
                .padding(.horizontal, 12)
            }
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
           
            fetchInventory(for: segment)
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
   
    // MARK: - Fetch Inventory List
    func fetchInventory(for segment: InventorySegment) {
        Task{
            SVProgressHUD.show()
            request.status = segment.rawValue.lowercased()
            await viewModel.getInventoryList(param: request)
            await SVProgressHUD.dismiss()
            await handleDataLoad()
        }
    }

    // MARK: - Handle ViewModel Data
    func handleDataLoad() {
        SVProgressHUD.dismiss()
        let response = viewModel.inventoryDict
        if response?.status == "success" {
            self.inventoryList = response?.data ?? []
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
