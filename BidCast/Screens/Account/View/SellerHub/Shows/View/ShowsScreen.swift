//
//  ShowsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD
//import ZegoExpressEngine

// MARK: - Show Model
struct Show: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let time: String
    let rsvps: Int
}

// MARK: - Shows Screen View
struct ShowsScreen: View {
    @State private var segment: ShowScreenSegment = .shows
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var isLive = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State var navigateToReherseal = false
    @State var navigateToShowAnalytics = false
    @State var navigateToShowDetails = false
    @State private var isActiveOnShowsScreen = false
    @State var viewModel = ShowsViewModel()
    @State var showsData = [HomeModel]()
    @State private var selectedProductIds: [String] = []
    @State var selectedShowsData = HomeModel()
    @State var showID = ""
    // QA #26 — capture selected show title for the Analytics screen's Watch Replay card
    @State var selectedShowTitle: String = ""
    @State var SHowId = 0
    @State var navigateToshowTitle = false
    // Basecamp #9934001770: co-host join screen (second device).
    @State private var navigateToCoHostJoin: Bool = false
    
    @State private var scheduleRequest = StoreScheduleShowRequest(
        title: "",
        date: "",
        time: "",
        category_id: "",
        auction_type_id: "",
        product_ids: [],
        is_explicit: false,
        show_discoverability: "",
        repeat_value: "",
        is_repeat: false,
        language: "english"
    )

    // Sample data removed — ShowsScreen now uses real API data via showsData.
    // (cmp3z7e4400k54axyxucdv6qm: replaced hardcoded placeholder shows)
    @State private var currentPage: Int = 1
    @State private var isLastPage: Bool = false
    @State private var isPaginating: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            VStack{
                PrimaryHeader(
                    title: "Shows",
                    isForBoth: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }

            // MARK: - Segmented Control
            CustomSegmentedControl(preselectedIndex: $segment, options: ShowScreenSegment.allCases)
                .padding(.horizontal)
            
            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 10) {
                    if showsData.isEmpty {
                        NoDataView(message: "No Shows found")
                    } else {
                        ForEach(showsData.indices,id: \.self) { index in
                            let data = showsData[index]
                            ShowCardView(show: data,onTap: {
                                if segment == .pastShows {
                                    showID = "\(data.id ?? 0)"
                                    selectedShowTitle = data.title ?? "" // QA #26
                                    navigateToShowAnalytics = true
                                }
                                else {
                                    navigateToShowDetails = true
                                    showID = "\(data.id ?? 0)"
                                    selectedShowsData = data
                                }
                            },onTapMenu: {
                                SHowId = data.id ?? 0
                                navigateToshowTitle = true
                            },isPastShows : segment == .pastShows)
                            .onAppear {
                                   // Trigger pagination when last cell appears
                                   if index == showsData.count - 1 {
                                       loadMoreShowsIfNeeded()
                                   }
                               }
                        }
                        if isPaginating {
                            ProgressView()
                                .padding(.vertical, 16)
                        }
                    }
                    Spacer().frame(height: 0)
                }
                .padding(.top)
                // Basecamp #9934001770: "Join as Co-Host" entry point for the
                // seller who is operating the second device.
                Button {
                    navigateToCoHostJoin = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 18))
                            .foregroundColor(.defaultTheme)
                        Text("Join as Co-Host (second device)")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.defaultTheme)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.defaultTheme.opacity(0.07))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            CusNavLink(doNavigate: $navigateToShowAnalytics,
                       destination:  MyShowsAnalyticsScreen(showId: $showID, showTitle: selectedShowTitle))
            
            CusNavLink(doNavigate: $navigateToShowDetails,
                       destination:  ShowDetailsScreen(showId: $showID))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination:
                        ShowTitleTips(request : $scheduleRequest,
                                      fromPrepare:.constant(false),
//                                      backToPrepare: $navigateToshowTitle,
                                      showId: $SHowId))
            // Basecamp #9934001770: second-device co-host join.
            CusNavLink(doNavigate: $navigateToCoHostJoin,
                       destination: CoHostJoinScreen())
           
        }
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
        .background(.backGround)
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear {
            loadShows(reset: true)
        }
        .onChange(of: segment) { _ in
            loadShows(reset: true)
        }


    }

    func loadShows(reset: Bool) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                isPaginating = false
                return
            }

            SVProgressHUD.show()
            if reset {
                currentPage = 1
                isLastPage = false
                showsData.removeAll()
            }

            let requestSegment = segment
            let requestPage = currentPage
            let type = requestSegment == .pastShows ? "past" : "upcoming"
            await viewModel.getLiveSHows(
                param: GetLiveShowsRequest(type: type, page: "\(requestPage)")
            )

            await SVProgressHUD.dismiss()
            guard segment == requestSegment else {
                if !reset {
                    isPaginating = false
                }
                return
            }
            scheduleSuccess(isPagination: !reset)

            if let error = viewModel.errorMessage, !error.isEmpty {
                hudMsg = error
                showhud = true
                viewModel.errorMessage = nil
            }
            if !reset {
                isPaginating = false
            }
        }
    }
    func scheduleSuccess(isPagination: Bool = false) {
        guard let response = viewModel.scheduledShow else { return }

        if response.status == "success" {
            let newData = response.data ?? []

            if isPagination {
                if newData.isEmpty {
                    isLastPage = true
                } else {
                    showsData.append(contentsOf: newData)
                }
            } else {
                showsData = newData
            }
        }
    }

    func loadMoreShowsIfNeeded() {
        guard !isPaginating, !isLastPage else { return }

        isPaginating = true
        currentPage += 1
        loadShows(reset: false)
    }

}

// MARK: - Segment Enum
enum ShowScreenSegment: String, CaseIterable, CustomStringConvertible {
    case shows = "Upcoming"
    case pastShows = "Past"

    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}

// MARK: - Preview
//#Preview {
//    ShowsScreen()
//}
