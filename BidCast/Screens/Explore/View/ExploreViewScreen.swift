//
//  ExploreViewScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct ExploreViewScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var viewModel = SelectCategoryViewModel()
    
    @State var selectedTab = "recommended"
    @State var category: String = ""
    @State var navigateToCategoryDetailScreen = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State private var showSearchView: Bool = false
    @State var searchText: String = ""  
    
    @State var categoryList = [CategoryDataModel]()
    @State var navigateToNoti: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Header
            PrimaryHeader(
                title: "",
                isForLogo: true,
                leadingImgArr: [.appName],
                trailingImgArr: [.search, .notification],
                onClickLeading: { _ in },
                onClickTrailing: { index in
                    if index == 0 {
                        withAnimation {
                            showSearchView.toggle()
                        }
                    } else {
                        navigateToNoti = true
                    }
                },
                count: .constant(0)
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    // 🔹 Search Bar
                    if showSearchView {
                        SearchView(searchText: $searchText) { _ in
                            Task { await fetchCategory(for: selectedTab)
                            }
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.bottom, 10)
                        .onChange(of: searchText) { newValue in
                            if newValue.isEmpty {
                                Task { await fetchCategory(for: selectedTab)
                                }
                            }
                        }
                    }
                    
                    // 🔹 Tabs (Recommended | Popular | All)
                    ButtonTitleLabel(
                        titles: ["Recommended", "Popular", "All"],
                        fontValue: 16,
                        textColor: .blue
                    ) { selected in
                        Task {
                            await fetchCategory(for: selected)
                        }
                    }
                    
                    // 🔹 Category List / No Data
                    if categoryList.isEmpty {
                        NoDataView(message: searchText.isEmpty ? "No categories found" : "No searched categories found")
                            .padding(.top, 40)
                    } else {
                        ForEach(0 ..< categoryList.count, id: \.self) { ind in
                            ListCell(
                                image: categoryList[ind].image ?? "",
                                title: categoryList[ind].name ?? "",
                                vectorImg: .icArrowUp,
                                subLabel: "\(categoryList[ind].usage_count ?? "") Live",
                                tintColot: categoryList[ind].color ?? ""
                            ) {
                                category = categoryList[ind].name ?? ""
                                navigateToCategoryDetailScreen = true
                            }
                            .padding(.horizontal, 0)
                        }
                    }

                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 13)
            
            // Navigation Links
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen,
                       destination: HomeViewScreen(showCategory: $category, comeFromExploreScreen: $navigateToCategoryDetailScreen))
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
        }
        .background(.bg.opacity(0.4))
        .onAppear {
            Task { await fetchCategory(for: "Recommended") }
        }
    }
    
    // MARK: - API Calls
    
    func fetchCategory(for tab: String) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        
        SVProgressHUD.show()
        categoryList.removeAll()
        
        if tab == "Recommended" {
            selectedTab = "recommended"
        } else if tab == "Popular" {
            selectedTab = "popular"
        } else if tab == "All"{
            selectedTab = "all"
        }
        
        await viewModel.getCategoryList(param: CategoryRequest(category_id: "", type: selectedTab, search: searchText))
        await SVProgressHUD.dismiss()
        success()
    }
    
    func success() {
        let response = viewModel.categoryResponse
        if response.status == "success" {
            self.categoryList = response.data ?? []
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
}
