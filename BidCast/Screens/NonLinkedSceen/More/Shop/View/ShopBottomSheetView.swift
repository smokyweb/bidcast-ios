//
//  ShowSummarySheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI
import SVProgressHUD

struct Product: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
    let detail: String
    let statusColor: Color
}

enum ShopTab: String, CaseIterable {
    case auction = "Auction"
    case buyNow = "Buy Now"
    case freebie = "Freebie"
    case sold = "Sold"
}
struct ShopBottomSheetView: View {
    @Binding var isPresented: Bool
    @State  var searchText = ""
    @State  var selectedTab: ShopTab = .auction
    @StateObject var viewModel = ProfileViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var filteredProducts: [ProductListingDataModel] {
        viewModel.productDetailsResponseDict?.data.filter {
            searchText.isEmpty || (($0.title?.localizedCaseInsensitiveContains(searchText)) != nil)} ?? [ProductListingDataModel]()
      }
//    @Binding var userId : String
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    
    @Binding var productData : [ProductData]
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Header
            HStack {
                Text("Shop")
                    .font(.custom(poppinsBold, size: 15))
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
            }
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search products...", text: $searchText)
                    .font(.custom(poppinsSemiBold, size: 13))
            }
            .padding(.horizontal)
            .frame(height: 40)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // Tabs
            HStack(spacing: 10) {
                ForEach(ShopTab.allCases, id: \.self) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Text(tab.rawValue)
                            .font(.custom(poppinsSemiBold, size: 13))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedTab == tab ? Color.defaultTheme : Color(.systemGray5))
                            .foregroundColor(selectedTab == tab ? .white : .black)
                            .cornerRadius(20)
                    }
                }
            }
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(productData.indices, id: \.self) { index in
                        productRow(productData[index])
                    }
                }
            }
            
            // Add Product
            HStack {
                Spacer()
                Button {
                    // Add new product action
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.defaultTheme)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
            }
            .padding(.bottom)
            
        }
        .edgesIgnoringSafeArea(.top)
        .padding()
        .background(.white)
        .cornerRadius(20)
//        .onAppear {
////            Task{
////               guard Reachability.isConnectedToNetwork() else {
////                    hudMsg = "No Internet Connection"
////                    showhud = true
////                    return
////                }
//////                SVProgressHUD.show()
//////                await self.viewModel.productDetails(parameters: UserProductRequest(user_id: Int(userId) ?? 0, page: 1))
//////                await SVProgressHUD.dismiss()
//////                if self.viewModel.errorMessage == nil {
//////                    filteredProducts = self.viewModel.productDetailsResponseDict?.data ?? [ProductListingDataModel]()
//////                }
////            }
//        }
    }
    

    
    func productRow(_ product: ProductData) -> some View {
            HStack(spacing: 12) {
                CustomProfileImage(url: product.image,isCircular: false,cornerRadius: 8,size: 60)

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.custom(poppinsSemiBold, size: 13.0))
//                    Text(product.description ?? "")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
                    Text(product.category)
                        .font(.custom(poppinsRegular, size: 11.0))
//                        .foregroundColor(product.status == "active" ? .darkGreen : .red)
                }

                Spacer()

                Button {
                    // Edit action
                } label: {
                    Image(systemName: "square.and.pencil")
                }

                Button {
                    // Delete action
                } label: {
                    Image(systemName: "trash")
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
}
