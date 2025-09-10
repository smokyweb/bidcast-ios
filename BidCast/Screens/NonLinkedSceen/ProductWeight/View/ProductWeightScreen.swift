//
//  ProductWeightScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct ProductWeightScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @Binding var weight: String
    @Binding var selectedUnit: String
    @Binding var isHazardous: Bool
    
    var unitOptions: [String]
    var quickWeights: [String]
    
    @Binding var imageUrls: [String]
    
    @Binding var request: StoreProductParam
    @Binding var storeScheduleRequest : StoreScheduleShowRequest
    @EnvironmentObject private var appRootManager: AppRootManager
    @StateObject private var viewModel =  ListProductViewModel()
    @State var navigateToAddProduct = false
    @Binding var thumbNail : String
    @Binding var backToPrepare : Bool
    @State var navigateToProuct = false
    @Binding var fromPrepare : Bool
    var delegate: ShowStepDelegate?
    
    var onContinue: () -> Void
    
    var body: some View {
            VStack(spacing: 0) {
                // Header
                PrimaryHeader(
                    title: "Product Weight",
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(Color.white)
                .frame(height: 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // Info
                        HStack(alignment: .top) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("BidCast calculates shipping fees based on the product weight. You can adjust this later if needed.")
                                .font(.footnote)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                        
                        // Item Weight Input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Item Weight")
                                .font(.subheadline)
                            
                            HStack(spacing: 10) {
                                TextField("0.00", text: $weight)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .foregroundColor(.black)
                                    .cornerRadius(8)
                                
                                Menu {
                                    ForEach(unitOptions, id: \.self) { unit in
                                        Button(unit) { selectedUnit = unit }
                                    }
                                } label: {
                                    HStack {
                                        Text(selectedUnit)
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Quick Weights
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                            ForEach(quickWeights, id: \.self) { qw in
                                Button(action: {
                                    weight = qw.replacingOccurrences(of: " oz", with: "")
                                }) {
                                    Text(qw)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .foregroundColor(.black)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Hazardous Toggle
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Hazardous Material")
                                    .font(.subheadline)
                                Spacer()
                                Toggle("", isOn: $isHazardous)
                                    .labelsHidden()
                            }
                            Text("Items containing flammable, explosive, or other dangerous materials. ")
                                .font(.caption)
                            + Text(" Learn more about hazardous materials")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
                
                // Continue Button
                VStack {
                    Button(action: {
                        submitProduct()
                    }) {
                        Text("Continue")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.defaultTheme)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color.white)
            }
            .edgesIgnoringSafeArea(.bottom)
            .padding(.bottom , -200)
        CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$storeScheduleRequest,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
        CusNavLink(doNavigate: $navigateToProuct, destination: AddProductsScreen(request:$storeScheduleRequest,thumbNail: $thumbNail,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare,delegate: delegate))
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight * 0.35, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
            if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
                showError = true
            }else{
                showError = false
            }
        }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    if self.fromPrepare{
                        navigateToProuct = true
                    }else{
                        navigateToAddProduct = true
                    }
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    withAnimation { showError = false }
                })
        })
    }
    
    // MARK: - Submit Product Logic
    func submitProduct(){
        
        print(request)
        print(imageUrls)
        guard !imageUrls.isEmpty,imageUrls.count != 0 else{
            hudMsg = "Please select images"
            showhud = true
            return
        }
        guard !request.category_id.isEmpty else{
            hudMsg = "Please select category"
            showhud = true
            return
        }
        guard !request.title.isEmpty else{
            hudMsg = "Please enter title"
            showhud = true
            return
        }
        guard !request.description.isEmpty else{
            hudMsg = "Please enter description"
            showhud = true
            return
        }
        guard !request.width.isEmpty else{
            hudMsg = "Please enter width"
            showhud = true
            return
        }
        guard !request.height.isEmpty else{
            hudMsg = "Please enter height"
            showhud = true
            return
        }
        guard !request.length.isEmpty else{
            hudMsg = "Please enter length"
            showhud = true
            return
        }
        guard !request.weight.isEmpty else{
            hudMsg = "Please enter weight"
            showhud = true
            return
        }
        guard !request.mail_class.isEmpty else{
            hudMsg = "Please select mail class"
            showhud = true
            return
        }
        guard !request.processing_category.isEmpty else{
            hudMsg = "Please select processing category"
            showhud = true
            return
        }
        
        Task{
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            SVProgressHUD.show()
            viewModel.errorMessage?.removeAll()
            await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
            request.shipping_profile_id = "4" //TODO : need to dynamic
            if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                uploadSuccess()
            }else{
                alertType = .sheetType(
                    icon: .alert,
                    title: "Failed",
                    message: viewModel.errorMessage ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
        }
    }
    
    func uploadSuccess(){
        guard let response = self.viewModel.storeImageResponse,
              response.status == "success"
        else {
            return
        }
        //            let response = self.viewModel.storeImageResponse
        if response.status == "success"{
            let uploadedUrls: [[String: String]] = response.data.map {
                return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
            }
            var variantArray: [[String: Any]] = []
            SVProgressHUD.dismiss()
            Task{
                self.viewModel.errorMessage?.removeAll()
                var request = [
                    
                    "category_id": request.category_id,
                    "sub_category_id": request.sub_category_id ?? "",
                    "title": request.title,
                    "description": request.description,
                    "quantity": request.quantity,
                    "pricing": request.pricing,
                    "flash_sale": request.flash_sale,
                    "accept_offers": request.accept_offers,
                    "reserve_for_live": request.reserve_for_live,
                    "shipping_profile_id": request.shipping_profile_id,
                    "images": uploadedUrls
                    
                    
                ]
                
                if !variantArray.isEmpty {
                    request["variant"] = variantArray
                }
                
                
                await viewModel.storeProduct(param: request)
                await SVProgressHUD.dismiss()
                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                    storeSuccess()
                }else{
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Failed",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            }
        }
    }
    
    
    func storeSuccess(){
        let response = viewModel.storeProductResponse
        if response?.status == "success"{
            alertType = .sheetType(
                icon: .success,
                title: response?.status?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        }else{
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
    
    
    private func showValidation(_ msg: String) {
        hudMsg = msg
        showhud = true
    }
}


extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
        as? [String: Any]
    }
}

