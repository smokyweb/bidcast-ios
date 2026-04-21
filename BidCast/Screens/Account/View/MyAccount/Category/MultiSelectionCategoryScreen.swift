//
//  MultiSelectionCategoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 09/08/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

// MARK: - MultiSelectionCategoryScreen
struct MultiSelectionCategoryScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @State var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showhud = false
    @State var hudMsg = ""
    @State var navigateToSubCategory = false
    @State var isNavFrom : String = ""
    
    @State private var categoryList: [CategoryDataModel] = []
    @State private var selectedCategoryIDs: [Int] = []
    
    @Binding var goToAccount : Bool
    
    var viewModel = SelectCategoryViewModel()
    
    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                HeaderWithTitle(
                    title: "Select Favorite Category".localized,
                    leadingImgArr: ["chevron.left"],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .background(.white)
            
            Text("Choose the categories you're interested in to watch related shows")
                .font(.custom(poppinsRegular, size: 13.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 5)
                .foregroundColor(.darkGray)
                .font(.custom(poppinsRegular, fixedSize: 13))
            
            ScrollView {
                LazyVGrid(columns: gridColumns, spacing: 16) {
                    ForEach(categoryList, id: \.id) { category in
                        CategoryCard(
                            category: category,
                            isSelected: selectedCategoryIDs.contains(category.id ?? -1)
                        )
                        .onTapGesture {
                            toggleCategorySelection(category.id ?? -1)
                        }
                    }
                }
                .padding(16)
            }
            .background(.backGround)
            
            // Next Button with Navigation
            CusNavLink(
                doNavigate: $navigateToSubCategory,
                destination: MultiSelectionSubCategoryScreen(isNavFrom : isNavFrom, selectedCategoryIDs: $selectedCategoryIDs, goToAccount: $goToAccount)
            )
            VStack{
                PrimaryButton(
                    title: "Next",
                    isOutLine: false,
                    onButtonClick: {
                Task {
                    await proceedNext()
                }
                    },
                    cornerRadius: 32.0,
                    btnTextColor: .white
                )
                .disabled(selectedCategoryIDs.isEmpty)
                .opacity(selectedCategoryIDs.isEmpty ? 0.5 : 1.0)
            }
            .background(.backGround)
            .padding(.bottom, 16)
        }
        .background(.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .onFirstAppear {
            loadCategories()
        }
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: { showError = false }
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if isNavFrom == "Account" {
                        goToAccount = false
                    } else {
                        UserDefaults.isFirstTimeLogin = true
                        appRootManager.currentRoot = .tabBar
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    // MARK: - Load Categories from API
    private func loadCategories() {
        Task {
            await viewModel.getCategoryList(param: CategoryRequest(category_id: ""))
            
            let response = viewModel.categoryResponse
            if response.status == "success" {
                categoryList = response.data ?? []
                
                // Initialize selectedCategoryIDs from API `is_selected`
                selectedCategoryIDs = categoryList
                    .filter { $0.is_selected ?? false }
                    .compactMap { $0.id }
            } else {
                hudMsg = response.message ?? "Failed to load categories"
                showhud = true
            }
        }
    }
    
    // MARK: - Toggle Category Selection
    private func toggleCategorySelection(_ id: Int) {
        if let index = selectedCategoryIDs.firstIndex(of: id) {
            selectedCategoryIDs.remove(at: index)
        } else {
            selectedCategoryIDs.append(id)
        }
    }
    
    private func proceedNext() async {
        guard !selectedCategoryIDs.isEmpty else { return }
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        
        SVProgressHUD.show()
        await viewModel.getSubCategoryList1(param: ["category_ids": selectedCategoryIDs])
        await SVProgressHUD.dismiss()
        
        if let msg = viewModel.errorMessage, !msg.isEmpty {
            hudMsg = msg
            showhud = true
            return
        }
        
        let response = viewModel.subCategoryResponse
        guard response?.status == "success" else {
            hudMsg = response?.message ?? "Failed to load subcategories"
            showhud = true
            return
        }
        
        let categories = response?.data ?? []
        let hasAnySubcategories = categories.contains { !($0.subcategories?.isEmpty ?? true) }
        
        if hasAnySubcategories {
            navigateToSubCategory = true
            return
        }
        
        // No subcategories at all → directly save selected categories as favorites
        SVProgressHUD.show()
        await viewModel.storeFavCategoryList(param: [
            "category_ids": selectedCategoryIDs,
            "sub_category_ids": []
        ])
        await SVProgressHUD.dismiss()
        
        if let msg = viewModel.errorMessage, !msg.isEmpty {
            hudMsg = msg
            showhud = true
            return
        }
        
        let saveResp = viewModel.storeFavCategoryResponse
        if saveResp?.status == "success" {
            alertType = .sheetType(
                icon: .success,
                title: saveResp?.status?.capitalized ?? "Success",
                message: saveResp?.message?.capitalized ?? "Saved",
                primaryBtnText: isNavFrom == "Account" ? AppString.ok.localized : AppString.Home.localized,
                secondaryBtnText: "",
                sheetThemeColor: .secondary
            )
            showError = true
        } else {
            hudMsg = saveResp?.message ?? "Failed to save favorites"
            showhud = true
        }
    }
}

// MARK: - CategoryCard View
struct CategoryCard: View {
    let category: CategoryDataModel
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
//            AsyncImage(url: URL(string: category.image ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                        .frame(width: 64, height: 64)
//                case .success(let image):
//                    image.resizable()
//                        .scaledToFit()
//                        .frame(width: 64, height: 64)
//                        .cornerRadius(12)
//                case .failure:
//                    Image(systemName: "photo")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 64, height: 64)
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
            CustomProfileImage(url: category.image ?? "",isCircular: false,cornerRadius: 12,size: 64,defaultImage: "photo")
                .disabled(true)
            Text(category.name ?? "Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: .infinity, minHeight: 34, alignment: .center)
                .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .frame(height: 150, alignment: .top)
        .background(isSelected ? Color.defaultTheme.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.defaultTheme : Color.clear, lineWidth: 2)
        )
        .contentShape(RoundedRectangle(cornerRadius: 12))
    }
}

