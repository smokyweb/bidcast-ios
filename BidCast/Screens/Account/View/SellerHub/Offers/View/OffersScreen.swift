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
    // QA #38 — toggle between offers I've placed/received vs bids placed on my items.
    // Same cell + list + pagination; only the API endpoint changes.
    private enum ActivityMode { case offers, bids }
    @State private var activityMode: ActivityMode = .offers
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
                    isForBoth : false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [.icSetting],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            // QA #38 — mode toggle: Offers (default) vs Bids on my items
            HStack(spacing: 0) {
                modeToggleButton(title: "Offers", mode: .offers)
                modeToggleButton(title: "Bids on my items", mode: .bids)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            // MARK: - Scrollable Show List
            ScrollView {
                VStack(spacing: 10) {
                    TwoVerticalLabelCell(dataModel: OffersValue.allCases,
                                         topLabel: { offer in offerCount(for: offer) },
                                         bottomLabel: { $0.description.localized})
                    if offerList.count != 0{
                        // Basecamp #9938459971 round 2 (2026-05-28): SwiftUI was
                        // not re-rendering ActivityCell after status changed
                        // because ForEach used `id: \.element.id` (offer.id) which
                        // stayed constant across the accept/decline refresh.
                        // Combine offer id + status into the ForEach id so the
                        // row identity changes when the status flips, forcing
                        // a fresh render with the correct accept/accepted/rejected
                        // button layout.
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
                            .id("\(txn.id ?? 0)-\(txn.status ?? "")")
                            .padding([.leading, .trailing], 15)
                            .onAppear {
                                Task {
                                    await handlePagination(index: i)
                                }
                            }
                        }
                    }else{
                        NoDataView(message: "No Offers found")
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
                await fetchActivityList(param: param)
                await SVProgressHUD.dismiss()
                getOfferSuccess()
            }
        }
        // QA #38 — reload list when the user flips between Offers and Bids on my items.
        .onChange(of: activityMode) { _ in
            Task {
                currentPage = 1
                offerList = []
                SVProgressHUD.show()
                let param = PageRequest(page: currentPage)
                await fetchActivityList(param: param)
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
                // QA #38 — refresh via whichever feed the user is currently viewing.
                await fetchActivityList(param: param)
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
            // QA #38 — paginate the active feed (offers OR bids).
            await fetchActivityList(param: param)
            
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

    // QA #38 — routes to either getOfferList or getBidList depending on the current mode.
    private func fetchActivityList(param: PageRequest) async {
        switch activityMode {
        case .offers: await viewModel.getOfferList(param: param)
        case .bids:   await viewModel.getBidList(param: param)
        }
    }

    // QA #38 — compact pill-style toggle for Offers vs Bids on my items.
    @ViewBuilder
    private func modeToggleButton(title: String, mode: ActivityMode) -> some View {
        let selected = (activityMode == mode)
        Button(action: { activityMode = mode }) {
            Text(title)
                .font(.custom(selected ? poppinsBold : poppinsMedium, size: 14))
                .foregroundColor(selected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(selected ? Color.defaultTheme.opacity(0.85) : Color.gray.opacity(0.12))
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
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

