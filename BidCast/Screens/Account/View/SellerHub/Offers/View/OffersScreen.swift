//
//  OffersScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

// MARK: - OffersScreen View
struct OffersScreen: View {
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @StateObject var viewModel = OffersViewModel()
    @State private var offerList: [OfferListModel] = []
    @State var status : String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var currentPage = 1
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: AppString.Offers,
                    isForBoth : true,
                    leadingImgArr: [.icBack,.appName],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    TwoVerticalLabelCell(dataModel: OffersValue.allCases,
                                         topLabel: { offer in offerCount(for: offer) },
                                         bottomLabel: { $0.description.localized})
                    if offerList.count != 0{
                        ForEach(Array(offerList.enumerated()), id: \.element.id) { i, txn in
                            ActivityCell(
                                offerListing: txn,
                                isFor: "OffersScreen",
                                onDecline: {
                                    handleOfferAction(offer: txn, newStatus: "rejected")
                                },
                                onAccept: {
                                    handleOfferAction(offer: txn, newStatus: "accepted")
                                },
                                status: txn.status ?? ""
                            )
                            .padding([.leading, .trailing], 15)
                            .onAppear {
                                Task {
                                    await handlePagination(index: i)
                                }
                            }
                        }
                    }else{
                        NoDataView(message: "No Orders found")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        
                    }
                }
                .padding(.top)
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onAppear{
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                let param = PageRequest(page: currentPage)
                await viewModel.getOfferList(param: param)
                await SVProgressHUD.dismiss()
                getOfferSuccess()
            }
        }
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
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
    func handleOfferAction(offer: OfferListModel, newStatus: String) {
        let param = OfferUpdateStatusRequest(offer_id: offer.id ?? 0, status: newStatus, page: currentPage)
        Task {
            do {
                // Call the async updateOfferStatus
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await viewModel.updateOfferStatus(parameters: param)
                let param = PageRequest(page: currentPage)
                await viewModel.getOfferList(param: param)
                await SVProgressHUD.dismiss()
                if viewModel.offerListResponse.status == "success" {
                    self.offerList = viewModel.offerListResponse.data ?? []
                    self.hudMsg = "Offer \(newStatus)"
                } else {
                    self.hudMsg = "Failed to refresh offers"
                }
                self.showhud = true
            } catch {
                await SVProgressHUD.dismiss()
                self.hudMsg = "Failed to update offer"
                self.showhud = true
            }
        }
    }
    

    func handlePagination(index: Int) async {
        let isLastItem = index == offerList.count - 1
        let totalItems = viewModel.offerListResponse.total ?? 0
        let canFetchMore = totalItems > offerList.count
        
        if isLastItem && canFetchMore {
            let nextPage = currentPage + 1
            let param = PageRequest(page: nextPage)
            await viewModel.getOfferList(param: param)
            
            if viewModel.offerListResponse.status == "success" {
                currentPage = nextPage
                offerList.append(contentsOf: viewModel.offerListResponse.data ?? [])
            }
        }
    }
    
    
    func getOfferSuccess() {
       guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.dismiss()
        let response = viewModel.offerListResponse
        if response.status == "success" {
            offerList = response.data ?? []
        } else {
            
        }
    }
    
    func offerCount(for offer: OffersValue) -> String {
        switch offer {
        case .pending:
            return "\(viewModel.offerListResponse.pending ?? 0)"
        case .accepted:
            return "\(viewModel.offerListResponse.accepted ?? 0)"
        case .decline:
            return "\(viewModel.offerListResponse.declined ?? 0)"
        }
    }
}



enum OffersValue : String, CaseIterable, CustomStringConvertible{
    
    case pending = "Pending"
    case accepted = "Accepted"
    case decline = "Declined"
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "")
    }
    
    var labelOlt : String{
        switch self {
            
        case .pending:
            return "12"
        case .accepted:
            return "45"
        case .decline :
            return "23"
            
        }
    }
}

// MARK: - Preview
//#Preview {
//    OffersScreen()
//}

