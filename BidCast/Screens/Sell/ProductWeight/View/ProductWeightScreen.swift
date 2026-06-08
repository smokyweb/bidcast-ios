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
    @Binding var videoUrls: [String]
    
    @State private var isHazardousMaterial = false
    
    var strokeColor: Color {
        isHazardousMaterial ? Color.defaultTheme.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    var lineWidth: CGFloat {
        isHazardousMaterial ? 2 : 1
    }
    
    @Binding var request: StoreProductParam
    @Binding var storeScheduleRequest : StoreScheduleShowRequest
    @EnvironmentObject private var appRootManager: AppRootManager
    @StateObject private var viewModel =  ListProductViewModel()
    @State var navigateToAddProduct = false
    @Binding var thumbNail : String
//    @Binding var backToPrepare : Bool
    @State var navigateToProuct = false
    @Binding var fromPrepare : Bool
    @Binding var backToCreateProduct : Bool
    @Binding var productId : String
    @State var productData = [ProductDataModel1]()
    
    @EnvironmentObject var productManager: ProductManager
    
    var didTapBack : ((Bool,ProductManager,LetsPrepareCoordinator) -> Void)?
    var didTapEdit : ((ProductDataModel1,LetsPrepareCoordinator) -> Void)?
    
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    
    var onContinue: () -> Void
    
    var body: some View {
        //        ZStack {
        VStack(spacing: 0) {
            VStack {
                // Header
                PrimaryHeader(
                    title: "Product Weight",
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            .background(Color.white)
            //                    .frame(height: 40)
            ScrollView{
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Info
                    HStack(alignment: .top) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("BidCast calculates shipping fees based on the product weight. You can adjust this later if needed.")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.defaultThemeLight)
                    .cornerRadius(10)
                    
                    // Item Weight Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Weight")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        
                        HStack(spacing: 10) {
                            TextField("0.00", text: $weight)
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .keyboardType(.decimalPad)
                                .padding()
                                .foregroundStyle(.text)
                                .submitLabel(.next)
                                .accentColor(.text)
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(.white)
                                        .shadow(color: .gray.opacity(0.7), radius: 1, x: 0, y: 0)
                                )
                                
                            
                            Menu {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Button(unit) { selectedUnit = unit }
                                }
                            } label: {
                                HStack {
                                    Text(selectedUnit)
                                        .font(.custom(poppinsSemiBold, size: 11.0))
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .foregroundColor(.black)
                                .frame(height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 32)
                                        .fill(.white)
                                        .shadow(color: .gray.opacity(0.7), radius: 1, x: 0, y: 0)
                                )
                               
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
                                    .font(.custom(poppinsSemiBold, size: 12.0))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.white)
                                            .shadow(color: .gray.opacity(0.7), radius: 1, x: 0, y: 0)
                                    )
                            }
                        }
                    }
                    //
                    //                        // Hazardous Toggle
                    //                        VStack(alignment: .leading, spacing: 8) {
                    //                            HStack {
                    //                                Text("Hazardous Material")
                    //                                    .font(.custom(poppinsSemiBold, size: 13.0))
                    //                                Spacer()
                    //                                Toggle("", isOn: $isHazardous)
                    //                                    .labelsHidden()
                    //                            }
                    //                            Text("Items containing flammable, explosive, or other dangerous materials. ")
                    //                                .font(.custom(poppinsRegular, size: 11.0))
                    //                            + Text(" Learn more about hazardous materials")
                    //                                .font(.custom(poppinsRegular, size: 11.0))
                    //                                .foregroundColor(.defaultTheme)
                    //                        }
                    //
                    //                        Spacer(minLength: 100)
                    //
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        Toggle(isOn: $isHazardousMaterial) {
                            HazardousLabel()
                        }
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 12, x: 0, y: 4
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(strokeColor, lineWidth: lineWidth)
                                .animation(.easeInOut(duration: 0.2), value: isHazardousMaterial)
                        )
                    }
                    //                        .padding(.horizontal, 16)
                    
                }
                .padding()
                
                // Continue Button
                VStack {
                    Button(action: {
                        submitProduct()
                    }) {
                        Text(productId.isEmpty ? "Continue" : "Update")
                            .font(.custom(poppinsSemiBold, size: 18.0))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.defaultTheme)
                            .cornerRadius(32)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
//                .background(Color.white)
            }.background(.backGround)
            
            CusNavLink(
                doNavigate: $navigateToAddProduct,
                destination: AddProductsScreen(
                    request:$storeScheduleRequest,
                    thumbNail: $thumbNail,
                    fromPrepare: .constant(false),
                    NavFromProductLibrary: .constant(false),
                    backToCreateProduct: $backToCreateProduct,
                    didTapBack:{ value,maanger,coordinator in
                        didTapBack?(value,maanger,coordinator)
                    },didTapEdit: { product ,coordinator in
                       didTapEdit?(product,coordinator)
                      
                    },
                )
            )
            CusNavLink(
                doNavigate: $navigateToProuct,
                destination: AddProductsScreen(
                    
                    request:$storeScheduleRequest,
                    thumbNail: $thumbNail,
                   
                    fromPrepare: $fromPrepare,
                    NavFromProductLibrary: .constant(false),
                    backToCreateProduct: $backToCreateProduct,
                    didTapBack:{ value,maanger,coordinator in
                        didTapBack?(value,maanger,coordinator)
                    },didTapEdit: { product ,coordinator in
                       didTapEdit?(product,coordinator)
                      
                    },
                   
                ).environmentObject(productManager)
            )
        }
        .background(.backGround)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight * 0.37,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil {
                    showError = true
                } else {
                    showError = false
                }
            },
            content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        productId = ""
                        if self.fromPrepare {
                            navigateToProuct = true
                        } else {
                            navigateToAddProduct = true
                        }
                        withAnimation { showError = false }
                    },
                    onSecondaryClick: {
                        withAnimation { showError = false }
                    }
                )
            }
        )
        
    }
    
    
    // MARK: - Submit Product Logic
    func submitProduct(){
        
        print(request)
        print(imageUrls)
        request.weight = weight
        $isHazardousMaterial
        guard !request.weight.isEmpty else{
            hudMsg = "Please enter weight"
            showhud = true
            return
        }
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
        
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            ) {
                var mimeType: [String] = []
                var photos = [[String]]()
                var keysValue: [String] = []
                
                if imageUrls.count > 0 {
                    mimeType.append("image/jpeg")
                    keysValue.append("images[]")
                    let imagesArr = self.imageUrls.map({$0.description})
                    photos.append(imagesArr)
                }
                
                
                if self.videoUrls.count > 0 {
                    // Check video URL extension to set the appropriate MIME type
                    for urlString in videoUrls {
                        guard let url = URL(string: urlString) else { return }
                        let fileExtension = url.pathExtension.lowercased()
                        
                        switch fileExtension {
                        case "mp4":
                            keysValue.append("videos[]")
                            mimeType.append("video/mp4")
                            photos.append([url.description])
                        case "avi":
                            keysValue.append("videos[]")
                            mimeType.append("video/avi")
                            photos.append([url.description])
                        case "mov":
                            keysValue.append("videos[]")
                            mimeType.append("video/mov")
                            photos.append([url.description])
                        case "mkv":
                            keysValue.append("videos[]")
                            mimeType.append("video/x-matroska")
                            photos.append([url.description])
                        default:
                            keysValue.append("videos[]")
                            mimeType.append("video/*") // Default case for unknown video types
                            photos.append([url.description])
                        }
                    }
                }
                try await viewModel.uploadStoreImage(images: photos, mimeType: mimeType, keysValue: keysValue)
                
                
                
                //                try await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
                //                request.shipping_profile_id = "4" //TODO : need to dynamic
                guard let response = self.viewModel.storeImageResponse, response.status == "success" else {
                    return
                }
                
                let uploadedImagesUrls: [[String: String]] = response.data.images?.compactMap {
                    return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
                } ?? []
                let uploadedVideoUrls: [[String: String]] = response.data.videos?.compactMap {
                    return ["videos": $0.videos ?? ""]
                } ?? []
                
                let finalImageUrls: [[String: String]]
                if !uploadedImagesUrls.isEmpty {
                    // New images were uploaded
                    finalImageUrls = uploadedImagesUrls
                } else if !imageUrls.isEmpty {
                    // No new uploads, use existing image URLs (edit mode)
                    finalImageUrls = imageUrls.map { url in
                        return ["image": url, "thumbnail": url]
                    }
                } else {
                    // No images at all
                    finalImageUrls = []
                }

                let finalVideoUrls: [[String: String]]
                if !uploadedVideoUrls.isEmpty {
                    // New videos were uploaded
                    finalVideoUrls = uploadedVideoUrls
                } else if !videoUrls.isEmpty {
                    // No new uploads, use existing video URLs (edit mode)
                    finalVideoUrls = videoUrls.map { url in
                        return ["videos": url]
                    }
                } else {
                    // No videos at all
                    finalVideoUrls = []
                }
                
                var variantArray: [[String: Any]] = []
                //TODO: eed to manage varient
                
                // 🔹 Prepare request body
                var productRequest: [String: Any] = [
                    
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
                    //                    "auction": "true",
                    // ✅ Newly added fields
                    "width": request.width,
                    "length": request.length,
                    "weight": request.weight,
                    "height": request.height,
                    "mail_class": request.mail_class,
                    "processing_category": request.processing_category,
                    "product_condition":request.product_condition,
                    
                    // ✅ Images array (already present)
                    "images": finalImageUrls,
                    "videos": finalVideoUrls,
                    "status": request.status,
                    //                    "type": "live"
                    "hazardous_material": isHazardousMaterial
                ]
                
                
                if !variantArray.isEmpty {
                    productRequest["variant"] = variantArray
                }
                if let existingProductId = Int(productId), !productId.isEmpty {
                    productRequest["product_id"] = existingProductId
                }
                
                try await viewModel.storeProduct(productId: !productId.isEmpty ? Int(productId) : nil ,param: productRequest)
                storeSuccess()
            }
        }
        
        //        Task {
        //            guard Reachability.isConnectedToNetwork() else {
        //                hudMsg = "No Internet Connection"
        //                showhud = true
        //                return
        //            }
        //            SVProgressHUD.show()
        //            viewModel.errorMessage?.removeAll()
        //            await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
        //            request.shipping_profile_id = "4" //TODO : need to dynamic
        //            if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
        //                uploadSuccess()
        //            }else{
        //                alertType = .sheetType(
        //                    icon: .alert,
        //                    title: "Failed",
        //                    message: viewModel.errorMessage ?? "",
        //                    primaryBtnText: "",
        //                    secondaryBtnText: AppString.ok.localized
        //                )
        //                showError = true
        //            }
        //        }
    }
    
    //    func uploadSuccess(){
    //        guard let response = self.viewModel.storeImageResponse,
    //              response.status == "success"
    //        else {
    //            return
    //        }
    //        if response.status == "success"{
    //            let uploadedUrls: [[String: String]] = response.data.map {
    //                return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
    //            }
    //            var variantArray: [[String: Any]] = []
    //            SVProgressHUD.dismiss()
    //            Task{
    //                self.viewModel.errorMessage?.removeAll()
    //                var request = [
    //
    //                    "category_id": request.category_id,
    //                    "sub_category_id": request.sub_category_id ?? "",
    //                    "title": request.title,
    //                    "description": request.description,
    //                    "quantity": request.quantity,
    //                    "pricing": request.pricing,
    //                    "flash_sale": request.flash_sale,
    //                    "accept_offers": request.accept_offers,
    //                    "reserve_for_live": request.reserve_for_live,
    //                    "shipping_profile_id": request.shipping_profile_id,
    //                    "images": uploadedUrls
    //                ]
    //
    //                if !variantArray.isEmpty {
    //                    request["variant"] = variantArray
    //                }
    //
    //                await viewModel.storeProduct(param: request)
    //                await SVProgressHUD.dismiss()
    //                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
    //                    storeSuccess()
    //                }else{
    //                    alertType = .sheetType(
    //                        icon: .alert,
    //                        title: "Failed",
    //                        message: viewModel.errorMessage ?? "",
    //                        primaryBtnText: "",
    //                        secondaryBtnText: AppString.ok.localized
    //                    )
    //                    showError = true
    //                }
    //            }
    //        }
    //    }
    
    
//    func storeSuccess(){
//        let response = viewModel.storeProductResponse
//        request = StoreProductParam(category_id: "", title: "", description: "", quantity: "1", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"", product_condition: "")
//        imageUrls = []
//        videoUrls = []
//        
//        if response?.status == "success"{
//           
//            if let newProduct = response?.data {
//                DispatchQueue.main.async { [weak productManager] in
//                    productManager?.addProduct(newProduct)
//                }
//            }
//            
//            alertType = .sheetType(
//                icon: .success,
//                title: response?.status?.capitalized ?? "",
//                message: response?.message?.capitalized ?? "",
//                primaryBtnText: AppString.ok.localized,
//                secondaryBtnText: ""
//            )
//            showError = true
//        }else{
//            alertType = .sheetType(
//                icon: .alert,
//                title: response?.error_type?.capitalized ?? "",
//                message: response?.message?.capitalized ?? "",
//                primaryBtnText: "",
//                secondaryBtnText: AppString.ok.localized
//            )
//            showError = true
//        }
//    }
//    @MainActor
    func storeSuccess(){
        let response = viewModel.storeProductResponse
        
        request = StoreProductParam(category_id: "", title: "", description: "", quantity: "1", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"", product_condition: "")
        imageUrls = []
        videoUrls = []
        
        if response?.status == "success"{
            
            if let updatedProduct = response?.data {
                // ✅ FIX: Check if we're updating or creating
                if !productId.isEmpty {
                    // UPDATE existing product
                    print("🔄 Updating product with ID: \(productId)")
                    productManager.updateProduct(updatedProduct)
                } else {
                    // CREATE new product
                    print("➕ Adding new product")
                    productManager.addProduct(updatedProduct)
                }
            }
            
            alertType = .sheetType(
                icon: .success,
                title: response?.status?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
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

//#Preview {
//    ProductWeightScreen(
//        weight: .constant(""),
//        selectedUnit: .constant(""),
//        isHazardous: .constant(false),
//        unitOptions: [""],
//        quickWeights: [""],
//        imageUrls: .constant([""]),
//        videoUrls: .constant([""]),
//        request: .constant(StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "", accept_offers: "", reserve_for_live: "", shipping_profile_id: "", status: "", width: "", length: "", weight: "", height: "", mail_class: "", processing_category: "", product_condition: "")),
//        storeScheduleRequest: .constant(StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "", is_explicit: false, show_discoverability: "", repeat_value: "", is_repeat: false, language: "")),
//        thumbNail: .constant(""),
//        backToPrepare: .constant(false),
//        fromPrepare: .constant(false),
//        backToCreateProduct: .constant(false), onContinue: {})
//}
