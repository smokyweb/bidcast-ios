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

// MARK: - MultiSelectionCategoryScreen
struct MultiSelectionCategoryScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var showError = false
    @State var showhud = false
    @State var hudMsg = ""
    @State var navigateToSubCategory = false
    @State var isNavFrom : String = ""
    
    @State private var categoryList: [CategoryDataModel] = []
    @State private var selectedCategoryIDs: [Int] = []
    
    var viewModel = SelectCategoryViewModel()
    
    let gridColumns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
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
            
            // Next Button with Navigation
            CusNavLink(
                doNavigate: $navigateToSubCategory,
                destination: MultiSelectionSubCategoryScreen(isNavFrom : isNavFrom, selectedCategoryIDs: $selectedCategoryIDs)
            )
            PrimaryButton(
                title: "Next",
                isOutLine: false,
                onButtonClick: {
                    navigateToSubCategory = true
                },
                cornerRadius: 12.0,
                btnTextColor: .white
            )
            .disabled(selectedCategoryIDs.isEmpty)
            .opacity(selectedCategoryIDs.isEmpty ? 0.5 : 1.0)
            .padding(.bottom, 20)
        }
        .onAppear {
            loadCategories()
        }
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
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
}

// MARK: - CategoryCard View
struct CategoryCard: View {
    let category: CategoryDataModel
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: category.image ?? "")) { phase in
                switch phase {
                case .empty: ProgressView().frame(width: 64, height: 64)
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 64, height: 64)
                        .cornerRadius(12)
                case .failure:
                    Image(systemName: "photo").resizable()
                        .frame(width: 64, height: 64)
                        .foregroundColor(.gray)
                @unknown default: EmptyView()
                }
            }
            
            Text(category.name ?? "Category")
                .font(.subheadline)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
