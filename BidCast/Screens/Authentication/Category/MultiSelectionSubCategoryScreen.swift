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
    @State var showError = false
    @State var isLoading = false
    @State var showhud = false
    @State var hudMsg = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State private var subCategoryList: [SubCategoryDataModel] = []
    @State private var selectedSubCategoryIDs: Set<Int> = []
    
    @Binding var selectedCategoryIDs: [Int]
    var viewModel = SelectCategoryViewModel()
    var delegate: ShowStepDelegate?
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 12)
    ]

    
    var body: some View {
        VStack(spacing: 0) {
            
            HeaderWithTitle(
                title: "Select Your Favourite SubCategory".localized,
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(subCategoryList, id: \.id) { subCategory in
                        SubCategoryCard(
                            subCategory: subCategory,
                            isSelected: selectedSubCategoryIDs.contains(subCategory.id ?? -1)
                        )
                        .onTapGesture {
                            toggleSelection(subCategory.id ?? -1)
                        }
                    }
                }
                .padding(16)
            }
            .padding([.leading,.trailing], 16)
            
            VStack {
                Button(action: {
                    if selectedSubCategoryIDs.isEmpty {
                        hudMsg = "Please select at least one subcategory."
                        showhud = true
                    } else {
                        Task {
                            await addFavCategories(
                                selectedCategoryIDs: selectedCategoryIDs,
                                selectedSubCategoryIDs: Array(selectedSubCategoryIDs)
                            )
                        }
                    }
                }) {
                    Text("Next")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedSubCategoryIDs.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedSubCategoryIDs.isEmpty)
            }
            .padding(16)
            .background(Color.white.shadow(radius: 3))
        }
        .onAppear {
            print("DEBUG: Passed Category IDs = \(selectedCategoryIDs)")
            loadSubCategories(selectedCategoryIDs: selectedCategoryIDs)
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
    
    // MARK: API Call - Load Subcategories
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
            await viewModel.getSubCategoryList(param: parameters)
            await SVProgressHUD.dismiss()
            let response = viewModel.subCategoryResponse
            if response?.status == "success" {
                subCategoryList = response?.data ?? []
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
    
    // MARK: API Call - Add Favorite Categories + Subcategories
    private func addFavCategories(selectedCategoryIDs: [Int], selectedSubCategoryIDs: [Int]) async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        print("category_ids param: \(selectedCategoryIDs)")
        print("subcategory_ids param: \(selectedSubCategoryIDs)")
        
        let request = FavCategoryRequest(category_ids: selectedCategoryIDs, sub_category_ids: selectedSubCategoryIDs)
        let parameters: [String: Any] = [
            "category_ids": request.category_ids,
            "sub_category_ids": request.sub_category_ids
        ]
        
        await viewModel.storeFavCategoryList(param: parameters)
        await SVProgressHUD.dismiss()
        
        let response = viewModel.storeFavCategoryResponse
        if response?.status == "success" {
            // TODO: Navigate to Home screen or next step
            print("Favorite categories saved successfully!")
            // e.g. presentationMode.wrappedValue.dismiss()
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

// MARK: - Subcategory Card View
struct SubCategoryCard: View {
    let subCategory: SubCategoryDataModel
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            AsyncImage(url: URL(string: subCategory.image ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
            )
            
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(height: 60)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
            .overlay(
                Text(subCategory.name ?? "")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding([.leading, .bottom], 8),
                alignment: .bottomLeading
            )
        }
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
