//
//  MultiSelectionCategoryScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 09/08/25.
//

import SwiftUICore
import SwiftUI
import AlertToast
import SVProgressHUD

struct MultiSelectionCategoryScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showError = false
    @State var showhud = false
    @State var hudMsg = ""
    @State var navigateToSubCategory = false
    @State var navFrom : String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var categoryList: [CategoryDataModel] = []
    @State private var selectedCategoryIDs: [Int] = []
    
    var viewModel = SelectCategoryViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HeaderWithTitle(
                title: "Select Your Favourite Category".localized,
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            // Category Grid
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
                .padding(.all, 16)
            }
            
            // Next Button with Navigation
            CusNavLink(
                doNavigate: $navigateToSubCategory,
                destination: MultiSelectionSubCategoryScreen(selectedCategoryIDs: $selectedCategoryIDs)
            )

            PrimaryButton(
                title: "Next",
                isOutLine: false,
                onButtonClick: {
                    guard !selectedCategoryIDs.isEmpty else {
                        hudMsg = "Please select at least one category"
                        showhud = true
                        return
                    }
                    navigateToSubCategory = true
                },
                cornerRadius: 12.0,
                btnTextColor: .white
            )
            .padding(.bottom, 20)
        }
        .background(Color.bg.opacity(0.5))
        .onAppear {
            loadCategories()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: { withAnimation { showError = false } },
                onSecondaryClick: { withAnimation { showError = false } }
            )
        }
    }
    
    // MARK: - Load Categories
    private func loadCategories() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            await viewModel.getCategoryList(param: CategoryRequest(category_id: ""))
            await SVProgressHUD.dismiss()
            let response = viewModel.categoryResponse
            if response.status == "success" {
                categoryList = response.data ?? []
            } else {
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }
    
    // MARK: - Selection Logic
    private func toggleCategorySelection(_ id: Int) {
        if let index = selectedCategoryIDs.firstIndex(of: id) {
            selectedCategoryIDs.remove(at: index)
        } else {
            selectedCategoryIDs.append(id)
        }
    }
}

// MARK: - Category Card View
struct CategoryCard: View {
    let category: CategoryDataModel
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: category.image ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 64, height: 64)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            Text(category.name ?? "Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
