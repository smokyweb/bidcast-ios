//
//  ShowsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD
import ZegoExpressEngine

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
    @State var SHowId = 0
    @State var navigateToshowTitle = false
    
    @State private var scheduleRequest = StoreScheduleShowRequest(
        title: "",
        date: "",
        time: "",
        category_id: "",
        auction_type_id: "",
        product_ids: "",
        is_explicit: false,
        show_discoverability: "",
        repeat_value: "",
        is_repeat: false,
        language: "english"
    )

    // Sample data
    let shows = [
        Show(title: "MTG Cards Sale", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156),
        Show(title: "Show Name", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156)
    ]

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
                .onChange(of: segment) { newSegment in
                    Task{
                        SVProgressHUD.show()
                        if segment == .pastShows{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            showsData.removeAll()
                            await viewModel.getLiveSHows(param: GetLiveShowsRequest(type: "past", page: "1"))
                        }else{
                            showsData.removeAll()
                            await viewModel.getLiveSHows(param: GetLiveShowsRequest(type: "upcoming", page: "1"))
                        }
                       
                        await SVProgressHUD.dismiss()
                        scheduleSuccess()
                    }
                }
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
                            })
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
//            .safeAreaInset(edge: .bottom) {
//                // MARK: - Fixed Bottom Button
////                PrimaryButton(
////                    title: AppString.submit.localized,
////                    isOutLine: false,
////                    onButtonClick: {
////                        // Action
////                    },
////                    btnTextColor: .white
////                )
////                .padding(.horizontal)
////                .padding(.vertical, 0)
////                .background(Color(UIColor.systemGroupedBackground))
//            }
//            CusNavLink(doNavigate: $navigateToReherseal,
//                       destination: RehearsalScreen(showUd: $showID,
//                                                    productListData: .constant([]),
//                                                    isLive: isLive,
//                                                    backToTabBar: .constant(true),
//                                                    showsData: $selectedShowsData))
            CusNavLink(doNavigate: $navigateToShowAnalytics,
                       destination:  MyShowsAnalyticsScreen(showId: $showID))
            
            CusNavLink(doNavigate: $navigateToShowDetails,
                       destination:  ShowDetailsScreen(showId: $showID))
            
//            CusNavLink(doNavigate: $navigateToshowTitle, destination:
//                        ShowTitleTips(request : $scheduleRequest,
//                                      fromPrepare:.constant(false),
//                                      backToPrepare: $navigateToshowTitle,
//                                      showId: $SHowId))
           
        }
        .navigationBarHidden(true)
        .toolbar(.hidden,for: .tabBar)
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
        .onAppear{
            Task{
                SVProgressHUD.show()
                if segment == .pastShows{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    await viewModel.getLiveSHows(param: GetLiveShowsRequest(type: "past", page: "1"))
                }else{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    await viewModel.getLiveSHows(param: GetLiveShowsRequest(type: "upcoming", page: "1"))
                }
                await SVProgressHUD.dismiss()
                scheduleSuccess()
            }
        }
    }
    func scheduleSuccess(){
        let response = viewModel.scheduledShow
        if response?.status == "success"{
            showsData = response?.data ?? [HomeModel]()
            SVProgressHUD.dismiss()
        }else{
            SVProgressHUD.dismiss()
        }
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



