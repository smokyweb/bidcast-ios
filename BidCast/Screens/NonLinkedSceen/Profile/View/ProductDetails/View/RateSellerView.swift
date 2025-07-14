//
//  RateSellerView.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/07/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct RateSellerView: View {
    
    // MARK: - Properties
    @State var sellerID: Int
    @State var overAllRating: Double = -1
    @State var shippingRating: Double = -1
    @State var packingRating: Double = -1
    @State var accuracyRating: Double = -1
    @State var comment: String = ""
    
    var sellerImage: String
    var sellerName: String = "dom crush"
    
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var navigateToProfile = false
    @State var userId = ""
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Header
            PrimaryHeader(
                title: "Rate Seller",
                isForLogo: false,
                leadingImgArr: [.sideArrow],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Seller Image
                    AsyncImage(url: URL(string: sellerImage)) { phase in
                        if let image = try? phase.image?.resizable() {
                            image
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        } else {
                            Image(.defaultUser)
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    .padding(.top)
                    
                    // MARK: - Seller Name
                    Text(sellerName)
                        .font(.custom(poppinsBold, size: 18))
                    
                    // MARK: - Ratings & Comment Section
                    VStack(alignment: .leading, spacing: 20) {
                        RatingRow(title: "Over All", rating: $overAllRating)
                        RatingRow(title: "Shipping", rating: $shippingRating)
                        RatingRow(title: "Packaging", rating: $packingRating)
                        RatingRow(title: "Accuracy", rating: $accuracyRating)
                        
                        Text("Add Description")
                            .font(.custom(poppinsRegular, size: 13))
                        
                        TextEditor(text: $comment)
                            .frame(height: 120)
                            .font(.custom(poppinsRegular, size: 13))
                            .padding()
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2)))
                        
                        // MARK: - Submit Button
                        Button(action: {
                            Task {
                                SVProgressHUD.show()
                                
                                guard overAllRating != -1 else {
                                    await SVProgressHUD.dismiss()
                                    hudMsg = AppString.addOverallRating
                                    showhud = true
                                    return
                                }
                                guard shippingRating != -1 else {
                                    await SVProgressHUD.dismiss()
                                    hudMsg = AppString.addshippingRating
                                    showhud = true
                                    return
                                }
                                guard packingRating != -1 else {
                                    await SVProgressHUD.dismiss()
                                    hudMsg = AppString.addpackagingRating
                                    showhud = true
                                    return
                                }
                                guard accuracyRating != -1 else {
                                    await SVProgressHUD.dismiss()
                                    hudMsg = AppString.addaccuracyRating
                                    showhud = true
                                    return
                                }
                                guard !comment.isEmpty else {
                                    await SVProgressHUD.dismiss()
                                    hudMsg = AppString.addComment
                                    showhud = true
                                    return
                                }
                                
                                let request = AddRatingRequest(
                                    seller_id: sellerID,
                                    overall_rating: overAllRating,
                                    shipping_rating: shippingRating,
                                    packaging_rating: packingRating,
                                    accuracy_rating: accuracyRating,
                                    comment: comment
                                )
                                await viewModel.addRating(parameters: request)
                                await SVProgressHUD.dismiss()
                                submitRatingSuccess()
                            }
                        }) {
                            Text("Submit")
                                .font(.custom(poppinsSemiBold, size: 16))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top)
                        
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 40)
            }
        }
        .ignoresSafeArea(edges: .bottom) // Optional
        .background(Color(.systemBackground))
        CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id: $userId))
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
    }
    
    // MARK: - Success Handler
    func submitRatingSuccess() {
        let response = viewModel.addRatingResponseDict
        if response?.status == "success" {
            navigateToProfile = true
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
    }
}

struct RatingRow: View {
    var title: String
    @Binding var rating: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.custom(poppinsRegular, size: 13))
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(index <= Int(rating) ? .defaultTheme : .gray)
                        .onTapGesture {
                            rating = Double(index)
                        }
                }
            }
        }
    }
}
