//
//  InventoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import SwiftUI
import AlertToast

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
            PrimaryHeader(
                title: "Inventory".localized,
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)

            // MARK: - Segment
            CustomSegmentedControl(preselectedIndex: $segment, options: InventorySegment.allCases)
                .padding([.horizontal,.leading,.trailing], 16)
                .background(Color.white)
                .onChange(of: segment) { newSegment in
                    fetchInventory(for: newSegment)
                }

            // MARK: - Search
            SearchView()
                .padding(.horizontal, 16)
                .padding(.top, 10)

            // MARK: - Inventory List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(inventoryList, id: \.id) { inventory in
                        ActiveInventoryScreen(inventory: inventory)
                            .padding(.horizontal, 10)
                    }
                }
                .padding(.top, 10)
                .padding([.leading, .trailing ], 16)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.bg)
        .onAppear {
            observe()
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

    // MARK: - Observe ViewModel Events
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                handleDataLoad()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                alertType = .sheetType(
                    icon: .alert,
                    title: AppString.error.localized,
                    message: msg,
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }

    // MARK: - Fetch Inventory List
    func fetchInventory(for segment: InventorySegment) {
        request.status = segment.rawValue.lowercased()
        viewModel.getInventoryList(param: request)
    }

    // MARK: - Handle ViewModel Data
    func handleDataLoad() {
        if viewModel.request == "Inventory" {
            if let response = viewModel.InventoryDict {
                if response.status == "success" {
                    self.inventoryList = response.data ?? []
                } else {
                    alertType = .sheetType(
                        icon: .alert,
                        title: response.error_type?.capitalized ?? "",
                        message: response.message?.capitalized ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            }
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
