//
//  MultiSelectionSubCategoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 09/08/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct MultiSelectionSubCategoryScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @State var showError = false
    @State var isLoading = false
    @State var showhud = false
    @State var hudMsg = ""
    @State var isNavFrom : String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var subCategoryList: [SubCategoryDataModel] = []
    @State private var selectedSubCategoryIDs: Set<Int> = []
    @State private var expandedCategoryIDs: Set<Int> = []   // For open/close sections
    
    @Binding var selectedCategoryIDs: [Int]
    var viewModel = SelectCategoryViewModel()
    var delegate: ShowStepDelegate?
    @State var navigateToAccount = false
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    let columns: [GridItem] = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    @Binding var goToAccount : Bool
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                HeaderWithTitle(
                    title: "Select Favorite Sub Category".localized,
                    leadingImgArr: ["chevron.left"],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .background(.backGround)
            
            Text("Select sub categories based on the categories you chose on the previous page")
                .font(.custom(poppinsRegular, size: 13.0))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .foregroundColor(.darkGray)
                .padding(.top, 5)
                .font(.custom(poppinsRegular, fixedSize: 14))
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(subCategoryList, id: \.id) { category in
                        let hasSubs = !(category.subcategories?.isEmpty ?? true)
                        VStack(spacing: 0) {
                            // Category Header
                            HStack {
                                CustomProfileImage(url: category.image, isCircular: true, size: 36)
                                Text(category.name ?? "")
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                                    .foregroundColor(.black)
                                Spacer()
                                if hasSubs {
                                    Image(systemName: expandedCategoryIDs.contains(category.id ?? -1) ? "chevron.up" : "chevron.down")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .allowsHitTesting(hasSubs)
                            .onTapGesture {
                                toggleExpand(category.id ?? -1)
                            }
                            
                            // Subcategories grid
                            if hasSubs, expandedCategoryIDs.contains(category.id ?? -1) {
                                LazyVGrid(columns: columns, spacing: 12) {
                                    ForEach(category.subcategories ?? [], id: \.id) { sub in
                                        SubCategoryCard(
                                            subCategory: SubCategoryDataModel(
                                                id: sub.id,
                                                name: sub.name,
                                                image: sub.image,
                                                thumbnail: sub.thumbnail,
                                                extraFields: sub.extraFields,
                                                color: sub.color,
                                                subcategories: nil,
                                                categoryID: sub.categoryID,
                                                isSelected: sub.isSelected
                                            ),
                                            isSelected: selectedSubCategoryIDs.contains(sub.id ?? -1)
                                        )
                                        .onTapGesture {
                                            toggleSelection(sub.id ?? -1)
                                        }
                                    }
                                }
                                .padding(.horizontal, 8)
                                .padding(.bottom, 12)
                            }
                        }
                        
                        .background(.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    (hasSubs && expandedCategoryIDs.contains(category.id ?? -1))
                                    ? Color.defaultTheme
                                    : Color.gray.opacity(0.25),
                                    lineWidth: (hasSubs && expandedCategoryIDs.contains(category.id ?? -1)) ? 2 : 1
                                )
                        )
                        .shadow(color: .squirrelGrey.opacity(0.2), radius: 1, x: 0, y: 0)
                    }
                }
                .padding(16)
            }
            .background(.backGround)
            
            VStack {
                PrimaryButton(
                    title: "Confirm",
                    isOutLine: false,
                    onButtonClick: {
                        Task {
                            await addFavCategories(
                                selectedCategoryIDs: selectedCategoryIDs,
                                selectedSubCategoryIDs: Array(selectedSubCategoryIDs)
                            )
                        }
                    },
                    cornerRadius: 32.0,
                    btnTextColor: .white
                )
            }
            .padding(16)
            
            CusNavLink(doNavigate: $navigateToAccount, destination: AccountScreen())
        }
        .background(.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .onAppear {
            loadSubCategories(selectedCategoryIDs: selectedCategoryIDs)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false,onDismiss: {
                showError = true
            }
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: { withAnimation { showError = false }
                    let response = viewModel.storeFavCategoryResponse
                    if response?.status == "success" {
                        if isNavFrom == "Account"{
                            goToAccount = false
                        }else{
                            UserDefaults.isFirstTimeLogin = true
                            appRootManager.currentRoot = .tabBar
                        }
                    } else {
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: { withAnimation { showError = false } }
            )
        }
    }
    
    // MARK: - Expand/Collapse Logic
    private func toggleExpand(_ id: Int) {
        guard let category = subCategoryList.first(where: { $0.id == id }),
              let subs = category.subcategories,
              !subs.isEmpty else {
            return
        }
        if expandedCategoryIDs.contains(id) {
            expandedCategoryIDs.remove(id)
        } else {
            expandedCategoryIDs.insert(id)
        }
    }
    
    private func loadSubCategories(selectedCategoryIDs: [Int]) {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            let request = SubCategoryRequest(category_ids: selectedCategoryIDs)
            let parameters: [String: Any] = ["category_ids": request.category_ids]
            await viewModel.getSubCategoryList1(param: parameters)
            await SVProgressHUD.dismiss()
            
            let response = viewModel.subCategoryResponse
            if response?.status == "success" {
                subCategoryList = response?.data ?? []
                
                // Preselect already selected
                for category in subCategoryList {
                    if let subSubs = category.subcategories {
                        for sub in subSubs {
                            if sub.isSelected == true, let id = sub.id {
                                selectedSubCategoryIDs.insert(id)
                            }
                        }
                    }
                }
            } else {
                alertType = .sheetType(
                    icon: .alert,
                    title: response?.error_type?.capitalized ?? "",
                    message: response?.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }
    
    private func addFavCategories(selectedCategoryIDs: [Int], selectedSubCategoryIDs: [Int]) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let request = FavCategoryRequest(category_ids: selectedCategoryIDs, sub_category_ids: selectedSubCategoryIDs)
        let parameters: [String: Any] = [
            "category_ids": request.category_ids,
            "sub_category_ids": request.sub_category_ids
        ]
        await viewModel.storeFavCategoryList(param: parameters)
        await SVProgressHUD.dismiss()
        
        let response = viewModel.storeFavCategoryResponse
        if response?.status == "success" {
            alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: isNavFrom == "Account" ? AppString.ok.localized : AppString.Home.localized, secondaryBtnText: "", sheetThemeColor: .secondary)
            showError = true
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }
    
    private func toggleSelection(_ id: Int) {
        if selectedSubCategoryIDs.contains(id) {
            selectedSubCategoryIDs.remove(id)
        } else {
            selectedSubCategoryIDs.insert(id)
        }
    }
}

struct SubCategoryCard: View {
    let subCategory: SubCategoryDataModel
    let isSelected: Bool
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: subCategory.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 100, height: 100)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.35), lineWidth: 1.5)
            )
            
            .shadow(color: isSelected ? Color.clear : Color.gray.opacity(0.4), radius: 4, x: 0, y: 2)
            
            Text(subCategory.name ?? "")
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(1)
        }
    }
}
