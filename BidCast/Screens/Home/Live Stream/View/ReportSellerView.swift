//
//  ReportSellerView.swift
//  BidCast
//
//  Created by JamTech on 25/11/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct ReportSellerView: View {
    
    @State private var selectedReason: String = ""
    @State private var showReasonDropdown = false
    @State private var message: String = ""
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var onReportSellerClicked: ((Int?, String?) -> Void) = {_, _ in}
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    
    @StateObject private var viewModel = LiveShowsViewModel()
    
    @State private var categoryList:[SellerCategoryDetailsModel] = []
    
    @State private var reasons: [String] = []
    @State private var selectedCategoryId: Int? = nil
    
    var body: some View {
        ScrollView(showsIndicators:false) {
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: - Title
                Text("Report Seller")
                    .font(.custom("Poppins-SemiBold", size: 20))
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                
                // MARK: - Reason Label
                //            Text("Reason")
                //                .font(.custom("Poppins-SemiBold", size: 15))
                //                .foregroundColor(.black)
                
                DropDownSelection(
                    options: $reasons, floatingLabel:"Reason",
                    hint: "Select",
                    selected: $selectedReason,
                    anchor: .top,
                    custFontName: robotoMedium,
                    custFontSize:  14.0,
                    custCategory : robotoRegular,
                    custCategorySize : 13.0,
                    onOptionSelected: { value in
                        selectedReason = value
                        selectedCategoryId = categoryList.filter({$0.name == value}).first?.id
                    }
                )
                .background(.clear)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                
                // MARK: - Tell us more
//                Text("Tell us more")
//                    .font(.custom("Poppins-SemiBold", size: 15))
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 12)
//                
                DescriptionFieldView(
                    description:$message,
                    title: "Tell us more",
                    placeholder: "Write Something",
                    custFontName : robotoMedium,
                    custFontSize : 14.0
                )
                { msg in
                    self.message = msg
                }
                .padding(.vertical, 12)
                
                // MARK: - Submit Button
                Button {
                    // VALIDATION
                    if !validateFields() {
                        return
                    }
                    
                    onReportSellerClicked(selectedCategoryId, message)
                } label: {
                    Text("Submit Report")
                        .font(.custom("Poppins-SemiBold", size: 17))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                .padding(.top, 10)
                .padding(.horizontal, 16)
                Spacer(minLength: 20)
            }
        }
        .padding(.top, 10)
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
            Task {
                await fetchReportCategories()
            }
        }
        
        .bottomSheet(isPresented: $showError, height: screenHeight/2.8, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            showError = true
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if let message = viewModel.errorMessage {
                        withAnimation { showError = false }
                    }else{
                        withAnimation { showError = false }
                    }
                   
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
    }
    
    @MainActor
    func fetchReportCategories() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        do {
            SVProgressHUD.show()
            try await viewModel.getReportCategories()
            await SVProgressHUD.dismiss()
            let response = viewModel.categoriesResponse

            if response.status == "success" {
                self.categoryList = response.data ?? []
                self.reasons = categoryList.compactMap({$0.name})
            } else {
                throw NSError(
                    domain: "APIError",
                    code: -1,
                    userInfo: [NSLocalizedDescriptionKey : response.message ?? "Something went wrong"]
                )
            }
        }
        catch {
            print("❌ Failed to load categories:", error.localizedDescription)

            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? error.localizedDescription,
                primaryBtnText: "",
                secondaryBtnText: "OK"
            )

            showError = true
        }
    }
    
    func validateFields() -> Bool {
        if selectedCategoryId == nil {
            hudMsg = "Please select a reason"
            showhud = true
            return false
        }
        
        if message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            hudMsg = "Please enter a message"
            showhud = true
            return false
        }
        
        return true
    }
   
    
}


extension View {
    func keyboardAwarePadding() -> some View {
        self
            .padding(.bottom, 0)
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                UIApplication.shared.windows.first?.rootViewController?.view.frame.origin.y = -50
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                UIApplication.shared.windows.first?.rootViewController?.view.frame.origin.y = 0
            }
    }
}
