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
    
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var selected: Segment = .message
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
                    onClickTrailing: nil,
                    count: .constant(0)
                )
            }
            
            ScrollView {
                VStack(spacing: 20) {
                    SegmentedControlView(
                        segments: Segment.allCases,
                        selectedSegment: $selected,
                        isWithBorder: false,
                        fontTitle: robotoMedium,
                        fontSize: 14.0
                    )
                    
                    switch selected {
                    case .message:
                        ActivityCell(isFor: selected.rawValue, status: .constant(""))
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
                                    }, status: .constant("pending")
                                )
                            }
                        }
                    case .offer:
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
                                    }, status: .constant("pending")
                                )
                            }
                        }
                    case .purchases:
                        if offerList.isEmpty {
                            NoDataView(message: "No List Found")
                        }
                        else {
                            ForEach(offerList, id: \.id) { offer in
                                ActivityCell(
                                    offerListing: offer,
                                    isFor: "Purchases", status: .constant("pending")
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
                                    isFor: "Saved Items",status: .constant("pending")
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
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


