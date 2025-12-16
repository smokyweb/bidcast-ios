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
//
//
//struct SubCategoryExpandableView: View {
//    let isLoading: Bool
//    let subCategories: [SubCategoryDataModel]
//    let onSubCategoryTap: ((SubCategoryDataModel) -> Void)?
//    
//    private let itemHeight: CGFloat = 60
//    private let maxVisibleItems: Int = 3
//    
//    @State private var selectedSubCategory: SubCategoryDataModel?
//    @State private var hoveredId: Int?
//    
//    private var shouldScroll: Bool {
//        subCategories.count > maxVisibleItems
//    }
//    
//    private var scrollViewHeight: CGFloat {
//        let itemsToShow = min(subCategories.count, maxVisibleItems)
//        return CGFloat(itemsToShow) * itemHeight
//    }
//    
//    init(isLoading: Bool,
//         subCategories: [SubCategoryDataModel],
//         onSubCategoryTap: ((SubCategoryDataModel) -> Void)? = nil) {
//        self.isLoading = isLoading
//        self.subCategories = subCategories
//        self.onSubCategoryTap = onSubCategoryTap
//    }
//    
//    var body: some View {
//        VStack(spacing: 0) {
//            if isLoading {
//                loadingView
//            } else if subCategories.isEmpty {
//                emptyView
//            } else {
//                subCategoryList
//            }
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.white,
//                            Color(.systemGray6).opacity(0.3)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 16)
//                .stroke(
//                    LinearGradient(
//                        gradient: Gradient(colors: [
//                            Color.blue.opacity(0.2),
//                            Color.purple.opacity(0.1)
//                        ]),
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ),
//                    lineWidth: 1.5
//                )
//        )
//        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
//        .shadow(color: Color.blue.opacity(0.05), radius: 20, x: 0, y: 8)
//        .padding(.horizontal, 12)
//        .padding(.top, 8)
//    }
//    
//    // MARK: - Loading View
//    private var loadingView: some View {
//        VStack(spacing: 16) {
//            ProgressView()
//                .scaleEffect(1.2)
//                .tint(.blue)
//            
//            Text("Loading categories...")
//                .font(.custom("Poppins-Medium", size: 13))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 120)
//    }
//    
//    // MARK: - Empty View
//    private var emptyView: some View {
//        VStack(spacing: 12) {
//            Image(systemName: "tray")
//                .font(.system(size: 32))
//                .foregroundColor(.gray.opacity(0.6))
//            
//            Text("No subcategories available")
//                .font(.custom("Poppins-Medium", size: 14))
//                .foregroundColor(.gray)
//        }
//        .frame(maxWidth: .infinity)
//        .frame(height: 100)
//    }
//    
//    // MARK: - SubCategory List
//    private var subCategoryList: some View {
//        VStack(spacing: 0) {
//            // Header
//            HStack {
//                Text("Subcategories")
//                    .font(.custom("Poppins-SemiBold", size: 15))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                Text("\(subCategories.count)")
//                    .font(.custom("Poppins-Medium", size: 13))
//                    .foregroundColor(.white)
//                    .frame(minWidth: 28, minHeight: 22)
//                    .background(
//                        Capsule()
//                            .fill(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//                    )
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 12)
//            .background(Color(.systemGray6).opacity(0.3))
//            
//            Divider()
//            
//            // Scrollable List
//            ScrollView(showsIndicators: shouldScroll) {
//                LazyVStack(spacing: 0) {
//                    ForEach(Array(subCategories.enumerated()), id: \.element.id) { index, subCategory in
//                        SubCategoryRow(
//                            subCategory: subCategory,
//                            isHovered: hoveredId == subCategory.id,
//                            isSelected: selectedSubCategory?.id == subCategory.id
//                        )
//                        .onTapGesture {
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                selectedSubCategory = subCategory
//                            }
//                            onSubCategoryTap?(subCategory)
//                        }
//                        .onLongPressGesture(minimumDuration: 0.01, pressing: { isPressing in
//                            withAnimation(.easeInOut(duration: 0.2)) {
//                                hoveredId = isPressing ? subCategory.id : nil
//                            }
//                        }, perform: {})
//                        
//                        if index < subCategories.count - 1 {
//                            Divider()
//                                .padding(.leading, 56)
//                        }
//                    }
//                }
//            }
//            .frame(height: scrollViewHeight)
//            
//            // Scroll Indicator (if scrollable)
//            if shouldScroll {
//                HStack {
//                    Spacer()
//                    Text("Scroll for more")
//                        .font(.custom("Poppins-Regular", size: 11))
//                        .foregroundColor(.gray.opacity(0.7))
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 10, weight: .semibold))
//                        .foregroundColor(.gray.opacity(0.7))
//                    Spacer()
//                }
//                .padding(.vertical, 8)
//                .background(Color(.systemGray6).opacity(0.2))
//            }
//        }
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//    }
//}
//
//// MARK: - SubCategory Row
//struct SubCategoryRow: View {
//    let subCategory: SubCategoryDataModel
//    let isHovered: Bool
//    let isSelected: Bool
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // Icon/Image
//            ZStack {
//                Circle()
//                    .fill(
//                        LinearGradient(
//                            gradient: Gradient(colors: [
//                                isSelected ? Color.blue : Color(.systemGray5),
//                                isSelected ? Color.purple : Color(.systemGray4)
//                            ]),
//                            startPoint: .topLeading,
//                            endPoint: .bottomTrailing
//                        )
//                    )
//                    .frame(width: 40, height: 40)
//                
//                if let imageName = subCategory.imageName, !imageName.isEmpty {
//                    Image(systemName: imageName)
//                        .font(.system(size: 18, weight: .semibold))
//                        .foregroundColor(.white)
//                } else {
//                    Text(subCategory.name?.prefix(1).uppercased() ?? "?")
//                        .font(.custom("Poppins-Bold", size: 18))
//                        .foregroundColor(.white)
//                }
//            }
//            
//            // Name and Count
//            VStack(alignment: .leading, spacing: 2) {
//                Text(subCategory.name ?? "Unknown")
//                    .font(.custom("Poppins-SemiBold", size: 14))
//                    .foregroundColor(isSelected ? .blue : .primary)
//                    .lineLimit(1)
//                
//                if let count = subCategory.itemCount {
//                    Text("\(count) items")
//                        .font(.custom("Poppins-Regular", size: 11))
//                        .foregroundColor(.gray)
//                }
//            }
//            
//            Spacer()
//            
//            // Arrow
//            Image(systemName: "chevron.right")
//                .font(.system(size: 14, weight: .semibold))
//                .foregroundColor(isSelected ? .blue : .gray.opacity(0.4))
//                .scaleEffect(isHovered ? 1.2 : 1.0)
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 10)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(isHovered ? Color.blue.opacity(0.05) : Color.clear)
//        )
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 1.5)
//        )
//        .scaleEffect(isHovered ? 1.02 : 1.0)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
//        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
//    }
//}
//
//// MARK: - Data Model
//struct SubCategoryDataModel: Identifiable, Equatable {
//    let id: Int?
//    let name: String?
//    let imageName: String?
//    let itemCount: Int?
//    
//    static func == (lhs: SubCategoryDataModel, rhs: SubCategoryDataModel) -> Bool {
//        lhs.id == rhs.id
//    }
//}
//
//// MARK: - Preview
//struct SubCategoryExpandableView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack(spacing: 20) {
//            // Loading State
//            SubCategoryExpandableView(
//                isLoading: true,
//                subCategories: []
//            )
//            
//            // Empty State
//            SubCategoryExpandableView(
//                isLoading: false,
//                subCategories: []
//            )
//            
//            // With 2 Items (No Scroll)
//            SubCategoryExpandableView(
//                isLoading: false,
//                subCategories: [
//                    SubCategoryDataModel(id: 1, name: "Running Shoes", imageName: "figure.run", itemCount: 45),
//                    SubCategoryDataModel(id: 2, name: "Basketball Shoes", imageName: "basketball", itemCount: 32)
//                ],
//                onSubCategoryTap: { sub in
//                    print("Tapped: \(sub.name ?? "")")
//                }
//            )
//            
//            // With 5 Items (Scrollable)
//            SubCategoryExpandableView(
//                isLoading: false,
//                subCategories: [
//                    SubCategoryDataModel(id: 1, name: "Running Shoes", imageName: "figure.run", itemCount: 45),
//                    SubCategoryDataModel(id: 2, name: "Basketball Shoes", imageName: "basketball", itemCount: 32),
//                    SubCategoryDataModel(id: 3, name: "Tennis Shoes", imageName: "tennis.racket", itemCount: 28),
//                    SubCategoryDataModel(id: 4, name: "Football Boots", imageName: "soccerball", itemCount: 19),
//                    SubCategoryDataModel(id: 5, name: "Training Shoes", imageName: "figure.strengthtraining.traditional", itemCount: 56)
//                ],
//                onSubCategoryTap: { sub in
//                    print("Tapped: \(sub.name ?? "")")
//                }
//            )
//        }
//        .padding()
//        .background(Color(.systemGroupedBackground))
//    }
//}
