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
    
    @State var selectedCategoryIndex = 0
    var categoryTitles =  ["Recommended", "Popular", "All"]
    @State var category: String = ""
    @State var navigateToCategoryDetailScreen = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var searchText: String = ""  
    
    @State var categoryList = [CategoryDataModel]()
    @State var navigateToNoti: Bool = false
    @State var isLoadingAPI: Bool = true
    
    @State private var expandedCategoryIndex: Int? = nil
    @State private var subCategoryCache: [String: [SubCategoryDataModel]] = [:]
    @State private var subCategoryLoadingId: String? = nil
    @State var loadingSubCategoryId: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                SearchBarView(placeholder: "Search") { debouncedText in
                    if debouncedText == "" { return }
                    self.searchText = debouncedText
                    let selectedCategory = categoryTitles[selectedCategoryIndex]
                    Task { await fetchCategory(for: selectedCategory) }
                }
                HeaderMenuIconView(didTapMenuButton: {
                    print("Menu Button Tapped")
                    navigateToNoti = true
                }, count: .constant(0))
            }
            .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                  
                    PillsSelectorView(titles: categoryTitles,
                                      selectedIndex: $selectedCategoryIndex,
                                      backgroundStyle: .pill,
                                      underlineEnabled: false,
                                      onSelectionChanged: { index, data in
                        let selectedCategory = categoryTitles[index]
                        Task {
                            await fetchCategory(for: selectedCategory)
                        }
                    })
                    
                    if isLoadingAPI {
                        // 1️⃣ FULL CARD SHIMMER
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(0..<12, id: \.self) { _ in
                                CategoryCardFullShimmerView()
                            }
                        }

                    } else if !isLoadingAPI && categoryList.isEmpty {
                        // 2️⃣ NO DATA VIEW
                        NoDataView(message: searchText.isEmpty ? "No categories found" : "No searched categories found")
                            .padding(.top, 40)

                    } else {
                        // 3️⃣ GRID LIST
//                        LazyVGrid(columns: columns, spacing: 16) {
//                            ForEach(categoryList.indices, id: \.self) { ind in
//                                let id = categoryList[ind].id ?? 0
//                                let key = String(id)
//                                
//                                CategoryCardView(
//                                    title: categoryList[ind].name ?? "",
//                                    imageURL: categoryList[ind].image ?? "",
//                                    liveCount: categoryList[ind].liveCount ?? 0
//                                )
//                                .onTapGesture {
//                                    handleCategoryTap(ind)
////                                    category = categoryList[ind].name ?? ""
////                                    navigateToCategoryDetailScreen = true
//                                }
//                                if expandedCategoryIndex == ind {
//                                    SubCategoryExpandableView(
//                                        isLoading: loadingSubCategoryId == key,
//                                        subCategories: subCategoryCache[key] ?? []
//                                    )
//                                }
//                            }
//                        }
                        LazyVStack(spacing: 16) {

                               ForEach(Array(categoryRows().enumerated()), id: \.offset) { rowIndex, row in

                                   // 🔹 CATEGORY ROW (3 items)
                                   HStack(spacing: 12) {
                                       ForEach(row, id: \.id) { category in

                                           CategoryCardView(
                                               title: category.name ?? "",
                                               imageURL: category.image ?? "",
                                               liveCount: category.liveCount ?? 0
                                           )
                                           .onTapGesture {
                                               if let index = categoryList.firstIndex(where: { $0.id == category.id }) {
                                                   handleCategoryTap(index)
                                               }
                                           }
                                       }
                                   }

                                   // 🔽 INLINE SUBCATEGORY VIEW (ONLY ONCE PER ROW)
                                   if let expandedIndex = expandedCategoryIndex,
                                      expandedIndex / 3 == rowIndex {

                                       let categoryId = categoryList[expandedIndex].id ?? 0
                                       let key = "\(categoryId)"

                                       SubCategoryExpandableView(
                                           isLoading: loadingSubCategoryId == key,
                                           subCategories: subCategoryCache[key] ?? []
                                       )
                                       .transition(.opacity.combined(with: .move(edge: .top)))
                                   }
                               }
                           }
                        
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal, 13)
            
            // Navigation Links
            CusNavLink(doNavigate: $navigateToCategoryDetailScreen,
                       destination: HomeViewScreen(showCategory: $category, comeFromExploreScreen: $navigateToCategoryDetailScreen))
            CusNavLink(doNavigate: $navigateToNoti, destination: NotificationScreen())
        }
        .background(.bg.opacity(0.4))
        .padding(.bottom, -27)
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
        isLoadingAPI = true
//        SVProgressHUD.show()
        categoryList.removeAll()

        await viewModel.getCategoryList(param: CategoryRequest(category_id: "", type: tab.lowercased(), search: searchText))
//        await SVProgressHUD.dismiss()
        success()
    }
    
    func success() {

        let response = viewModel.categoryResponse
        if response.status == "success" {
            self.categoryList = response.data ?? []
            isLoadingAPI = false
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
    func categoryRows() -> [[CategoryDataModel]] {
        stride(from: 0, to: categoryList.count, by: 3).map {
            Array(categoryList[$0..<min($0 + 3, categoryList.count)])
        }
    }
    
    func handleCategoryTap(_ index: Int) {

        let categoryId = categoryList[index].id ?? 0

        // Collapse if same category tapped again
        if expandedCategoryIndex == index {
            expandedCategoryIndex = nil
            return
        }

        expandedCategoryIndex = index

        // 🔁 USE CACHE IF AVAILABLE
        if let cachedSubCategories = subCategoryCache["\(categoryId)"] {
            // Already loaded → do NOT call API
            print("Using cached subcategories for \(categoryId)")
            return
        }

        // 🚀 Call API only first time
        subCategoryLoadingId = "\(categoryId)"
        loadingSubCategoryId = "\(categoryId)"

        Task {
            await fetchSubCategories(categoryId: "\(categoryId)")
        }
    }
    
    func fetchSubCategories(categoryId: String) async {
        let param = [
            "category_ids":[categoryId]
        ]
        await viewModel.getSubCategoryList(param: param)
        
        if viewModel.subCategoryResponse?.status == "success" {
            let subCats = viewModel.subCategoryResponse?.data ?? []

            // ✅ SAVE TO CACHE
            subCategoryCache[categoryId] = subCats
        }

        subCategoryLoadingId = nil
        loadingSubCategoryId = nil
    }
    
    
}

struct SubCategoryExpandableView: View {

    let isLoading: Bool
    let subCategories: [SubCategoryDataModel]

    private let maxHeight: CGFloat = 4 * 55   // 4 rows

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(subCategories, id: \.id) { sub in
                            
                            Text(sub.name ?? "")
                                .font(.custom(poppinsSemiBold, size: 14.0))
                                .padding(.vertical, 6)
                        }
                    }
                    .padding()
                }
                .frame(maxHeight: maxHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 6)
        )
        .padding(.top, 8)
    }
}
