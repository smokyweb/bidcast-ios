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
    
    @Binding var sellerImage: String
    @Binding var sellerName: String
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @State var navigateToProfile = false
    @State var userId = ""
    @State var userName : String = ""
    @State var userImage : String = ""
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var viewModel = ProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Custom Header
            PrimaryHeader(
                title: "Rate Seller",
                isForBoth: true,
                leadingImgArr: [.icBack,.appName],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Seller Profile Section
                    VStack(alignment: .leading, spacing: 16) {
                        CustomProfileImage(url: sellerImage, isCircular: true, size: 100)
                            .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 3)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        // MARK: - Seller Name
                        VStack(alignment: .leading, spacing: 4) {
                            Text(sellerName)
                                .font(.custom(poppinsBold, size: 20))
                                .foregroundColor(.primary)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    
                    // MARK: - Ratings & Comment Section
                    VStack(alignment: .leading, spacing: 24) {
                        // Ratings Container
                        VStack(alignment: .leading, spacing: 20) {
                            RatingRow(title: "Over All", rating: $overAllRating)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            RatingRow(title: "Shipping", rating: $shippingRating)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            RatingRow(title: "Packaging", rating: $packingRating)
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                            
                            RatingRow(title: "Accuracy", rating: $accuracyRating)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        
                        // Comment Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add Description")
                                .font(.custom(poppinsSemiBold, size: 15))
                                .foregroundColor(.primary)
                            
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                                
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        comment.isEmpty ? Color.gray.opacity(0.2) : Color.blue.opacity(0.4),
                                        lineWidth: comment.isEmpty ? 1 : 2
                                    )
                                    .animation(.easeInOut(duration: 0.2), value: comment.isEmpty)
                                
                                TextEditor(text: $comment)
                                    .frame(height: 120)
                                    .font(.custom(poppinsRegular, size: 14))
                                    .padding(12)
                                    .background(Color.clear)
                                    .scrollContentBackground(.hidden)
                                
                                if comment.isEmpty {
                                    Text("Share your experience with this seller...")
                                        .font(.custom(poppinsRegular, size: 14))
                                        .foregroundColor(.gray.opacity(0.6))
                                        .padding(.horizontal, 17)
                                        .padding(.vertical, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                            .frame(height: 140)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 3)
                        )
                        
                        // MARK: - Submit Button
                        Button(action: {
                            Task {
                               guard Reachability.isConnectedToNetwork() else {
                                    hudMsg = "No Internet Connection"
                                    showhud = true
                                    return
                                }

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
                            Text("Submit Rating")
                                .font(.custom(poppinsSemiBold, size: 17))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(14)
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                    .frame(alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .top)
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
        }
        .onAppear(perform: {
            print("Seller Profile image: \(sellerImage)")
        })
        .ignoresSafeArea(edges: .bottom)
        .background(Color(.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
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
    @State private var selectedRating: Double = -1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom(poppinsSemiBold, size: 15))
                .foregroundColor(.primary)
            
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { index in
                    ZStack {
                        // Background glow effect for selected stars
                        if index <= Int(rating) {
                            Circle()
                                .fill(Color.defaultTheme.opacity(0.15))
                                .frame(width: 36, height: 36)
                                .blur(radius: 4)
                        }
                        
                        Image(systemName: index <= Int(rating) ? "star.fill" : "star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 28, height: 28)
                            .foregroundColor(index <= Int(rating) ? .defaultTheme : .gray.opacity(0.3))
                            .scaleEffect(selectedRating == Double(index) ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedRating)
                    }
                    .onTapGesture {
                        selectedRating = Double(index)
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            rating = Double(index)
                        }
                        
                        // Reset scale after animation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedRating = -1
                        }
                    }
                }
            }
        }
    }
}
