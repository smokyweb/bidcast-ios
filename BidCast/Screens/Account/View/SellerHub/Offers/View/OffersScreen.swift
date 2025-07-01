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

    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: "Offers",
                    isForLogo : true,
                    leadingImgArr: [.appName],
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
                    ForEach(offerList, id: \.id) { txn in
                        ActivityCell(offerListing: txn, isFor: "OffersScreen",onDecline: {
                            handleOfferAction(offer: txn, newStatus: "rejected")
                        }, onAccept: {
                            handleOfferAction(offer: txn, newStatus: "accepted")
                        }, status:.constant(txn.status ?? ""))
                            .padding([.leading, .trailing], 15)
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
                SVProgressHUD.show()
                await viewModel.getOfferList()
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
        let param = OfferUpdateStatusRequest(offer_id: offer.id ?? 0, status: newStatus)
        SVProgressHUD.show()
        
        Task {
            do {
                // Call the async updateOfferStatus
                await viewModel.updateOfferStatus(parameters: param)
                await viewModel.getOfferList()
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
    
    func getOfferSuccess() {
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
    case decline = "Decline"
    
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
#Preview {
    OffersScreen()
}

