//
//  ActivityScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUICore
import SwiftUI
import SVProgressHUD
import AlertToast

struct ActivityScreen: View {
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @StateObject var viewModel = OffersViewModel()
    @State var offerList: [OfferListModel] = []
    @State var messageList = []
    
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var selected: Segment = .message
    
    @State var navigateToNotification = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                PrimaryHeader(
                    title: "Activity",
                    isForLogo: true,
                    leadingImgArr: [.appName],
                    trailingImgArr: [.notification],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    onClickTrailing: {  _ in
                       
                        navigateToNotification = true
                    },
                    count: .constant(0)
                )
            }
            VStack(alignment: .leading,spacing: 6){
                SegmentedControlView(
                    segments: Segment.allCases,
                    selectedSegment: $selected,
                    isWithBorder: false,
                    fontTitle: robotoMedium,
                    fontSize: 14.0
                )
            }
            
            ScrollView {
                VStack(spacing: 12) {
                   
                    switch selected {
                    case .message:
                        if messageList.isEmpty {
                            NoDataView(message: "No message Found")
                        }else{
                            ActivityCell(isFor: selected.rawValue, status: "")
                        }
                    case .bid:
                        if offerList.isEmpty {
                            NoDataView(message: "No bids Found")
                        } else {
                            ForEach(offerList, id: \.id) { offer in
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Bids",
                                    onDecline: {
                                        handleOfferAction(offer: offer, newStatus: "rejected")
                                    },
                                    onAccept: {
                                        handleOfferAction(offer: offer, newStatus: "accepted")
                                    }, status: offer.status ?? ""
                                )
                            }
                        }
                    case .offer:
                        TwoVerticalLabelCell(dataModel: OffersValue.allCases,
                                             topLabel: { offer in offerCount(for: offer) },
                                             bottomLabel: { $0.description.localized})
                        if offerList.isEmpty {
                            NoDataView(message: "No offers Found")
                        } else {
                            
                            ForEach(offerList, id: \.id) { offer in
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Offers",
                                    onDecline: {
                                        handleOfferAction(offer: offer, newStatus: "rejected")
                                    },
                                    onAccept: {
                                        handleOfferAction(offer: offer, newStatus: "accepted")
                                    }, status: offer.status ?? ""
                                )
                            }
                        }
                    case .purchases:
                        if offerList.isEmpty {
                            NoDataView(message: "No List Found")
                        }else {
                            ForEach(offerList, id: \.id) { offer in
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Purchases", status: offer.status ?? ""
                                )
                            }
                        }
                        
                    case .savedItems:
                        if offerList.isEmpty {
                            NoDataView(message: "No List Found")
                        }
                        else {
                            ForEach(offerList, id: \.id) { offer in
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Saved Items",status: offer.status ?? ""
                                )
                            }
                        }
                    }
                }
            }
            .padding(.top,4)
            .padding(.horizontal, 8)
            
            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
        }
        .background(Color(.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            Task {
                await fetchData(for: selected)
            }
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onChange(of: selected) { newSegment in
            Task {
                await fetchData(for: newSegment)
            }
        }
    }
    
    // Fetch data based on the selected segment
    func fetchData(for segment: Segment) async {
        switch segment {
        case .message:
            // fetchMessages()
            break
        case .bid:
            SVProgressHUD.show()
            self.offerList.removeAll()
            await viewModel.getBidList()
            await SVProgressHUD.dismiss()
            getOfferSuccess()
        case .offer:
            SVProgressHUD.show()
            self.offerList.removeAll()
            await viewModel.getOfferList()
            await SVProgressHUD.dismiss()
            getOfferSuccess()
        case .purchases:
            SVProgressHUD.show()
            self.offerList.removeAll()
            await viewModel.getItemList(parameters: ItemListRequest(type: "purchased"))
            await SVProgressHUD.dismiss()
            getOfferSuccess()
        case .savedItems:
            SVProgressHUD.show()
            self.offerList.removeAll()
            await viewModel.getItemList(parameters: ItemListRequest(type: "saved"))
            await SVProgressHUD.dismiss()
            getOfferSuccess()
        }
    }
    
    
    func getOfferSuccess() {
        SVProgressHUD.dismiss()
        if viewModel.offerListResponse.status == "success" {
            offerList = viewModel.offerListResponse.data ?? []
        } else {
            
        }
    }
    
    func handleOfferAction(offer: OfferListModel, newStatus: String) {
        let param = OfferUpdateStatusRequest(offer_id: offer.id ?? 0, status: newStatus)
        SVProgressHUD.show()
        
        Task {
            do {
                
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


// Enum for the segmented control
enum Segment: String, CaseIterable, CustomStringConvertible {
    case message = "Message"
    case bid = "Bids"
    case offer = "Offers"
    case purchases = "Purchases"
    case savedItems = "Saved Items"
    
    var description: String { rawValue }
}


