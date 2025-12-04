//
//  ListProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

struct ListProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
    @State var productTitle = ""
    @State var message = ""
    @State var isTappedFlash : Bool = false
    @State var isTappedAccept : Bool = false
    @State var isTappedReserve: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var categoryNames: [String] = []
    @State var selectedCategory = ""
    @State var categoryList: [CategoryDataModel] = []
    @State var shippingAddressName: [String] = []
    @State var shippingId = ""
    @State var ShippingAddress: [AddressModel] = []
    @State var mailClassList = [String]()
//    @State var isImageSizeExceeding: Bool = false
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"", product_condition: "")
    
    @StateObject var viewModel = ListProductViewModel()
    @State var imageUrls: [String] = []
    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName : [String] = [""]
    @Binding var productData : InventoryDataModel
    @State var extraFields: [ExtraFieldModel] = []
    @State var processingListArr = ["Letters","Flats","Machinaable","Nonstandard","Non Machinable"]
    
//    @State var conditionListArr = ["New","Used - Like New","Used - Very Good","Used - Good","Used - Acceptable","Collectible - Like New","Collectible - Very Good","Collectible - Good","Collectible - Acceptable"]
    
    @State var conditionListArr = ["New","Used - Like New"]
    
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]

    var body: some View {
        
//        ZStack {
            VStack{
                VStack{
                    PrimaryHeader(
                        title: "List a Product".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                .frame(height: 40)
                .background(Color.white)
                
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView(uploadedImageUrls: $imageUrls)
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        
                        DropDownSelection(
                            options: $categoryNames, floatingLabel:"Category",
                            hint: "Select Category",
                            selected: $selectedCategory,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                selectedCategory = value
                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.category_id = "\(id)"
                                } else {
                                    request.category_id = ""
                                }
                                Task{
                                    
                                    await performAPICalls(
                                        isConcurrent: false,
                                        onError: { error in
                                            showSubCategorySheet = false
                                        },
                                        onSuccess: {
                                            self.subCategoryList.removeAll()
                                            if let response = self.viewModel.categoryResponse{
                                                self.subCategoryList = response.data
                                                self.subCategoryName = self.subCategoryList.map { $0.name ?? ""}
                                            }
                                            if subCategoryList.count != 0{
                                                showSubCategorySheet = true
                                            }
                                        }
                                    ) {
                                        extraFields = []
                                        selectedSubCategory = ""
                                        selectedOption = []
                                        request.sub_category_id = ""
                                        let request = CategoryRequest(category_id: request.category_id)
                                        SVProgressHUD.show()
                                        try await self.viewModel.getSubCategoryList(param: request)
                                        await SVProgressHUD.dismiss()
                                    }
                                }
                            }
                        )
                        .zIndex(1201.0)
                        .padding([.leading,.trailing],16)
                        AuthTextField(
                            floatingLabel: "Title".localized,
                            placeholder: "Enter Product title".localized,
                            icon: .menuProfile,
                            text: $request.title ,
                            isIconDisplay : false,
                            custFontName : robotoMedium,
                            custFontSize : 14.0,
                            enteredText:  { title in
                                request.title = title
                            })
                        .keyboardType(.alphabet)
                        .padding([.top,.bottom],4)
                        
                        DescriptionFieldView(
                            description:$request.description,
                            custFontName : robotoMedium,
                            custFontSize : 14.0
                            )
                        { message in
                            request.description = message
                        }
                        AuthTextField(floatingLabel: "Quantity".localized, placeholder: "Enter Quantity".localized, icon: .menuProfile, text: $request.quantity ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.quantity = quantity
                        })
                        .keyboardType(.numberPad)
                        .padding([.bottom],4)
                        AuthTextField(floatingLabel: "Width (cm)".localized, placeholder: "Enter width".localized, icon: .menuProfile, text: $request.width ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.width = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        AuthTextField(floatingLabel: "Height (cm)".localized, placeholder: "Enter height".localized, icon: .menuProfile, text: $request.height ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.height = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        AuthTextField(floatingLabel: "Length (cm)".localized, placeholder: "Enter length".localized, icon: .menuProfile, text: $request.length ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.length = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        AuthTextField(floatingLabel: "Weight (lbs)".localized, placeholder: "Enter Weight".localized, icon: .menuProfile, text: $request.weight ,isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                            request.weight = quantity
                        })
                        .keyboardType(.decimalPad)
                        .padding([.bottom],4)
                        DropDownSelection(
                            options: $mailClassList, floatingLabel:"Mail Class",
                            hint: "Select",
                            selected: $request.mail_class,
                            anchor: .bottom,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
//                                selectedCategory = value
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
//                                    request.mail_class = "\(id)"
//                                } else {
                                    request.mail_class = value
//                                }
                               
                            }
                        )
                        
                        .padding([.leading,.trailing],16)
                        DropDownSelection(
                            options: $processingListArr, floatingLabel:"Processing Category",
                            hint: "Select",
                            selected: $request.processing_category,
                            anchor: .top,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
//                                selectedCategory = value
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.processing_category = value
//                                } else {
//                                    request.processing_category = ""
//                                }
                            }
                        )
                        .padding([.leading,.trailing],16)
                        
                        DropDownSelection(
                            options: $conditionListArr, floatingLabel:"Condition",
                            hint: "Select",
                            selected: $request.product_condition,
                            anchor: .top,
                            custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                request.product_condition = value
                            }
                        )
                        .padding([.leading,.trailing],16)
                        
//                        var extraField = self.extraFields
                        if extraFields.count != 0{
                            ForEach(0 ..< extraFields.count) { index in
                                let field = extraFields[index]
                                if let type = field.type {
                                    if type == "text" {
                                        AuthTextField(
                                            floatingLabel: field.label ?? "",
                                            placeholder: "Enter \(field.label ?? "")",
                                            icon: .menuProfile,
                                            text: Binding(
                                                get: { self.extraFieldValues[field.label ?? ""] ?? "" },
                                                set: { self.extraFieldValues[field.label ?? ""] = $0 }
                                            ),
                                            isIconDisplay: false,
                                            custFontName: robotoMedium,
                                            custFontSize: 14.0,
                                            enteredText: { text in
                                                self.extraFieldValues[field.label ?? ""] = text
                                            }
                                        )
                                        .padding(.bottom, 4)
                                        
                                    } else if type == "radio", let options = field.options {
                                        
                                        VStack(alignment: .leading) {
                                            Text(field.label?.capitalizingFirstLetter() ?? "")
                                                .padding(.horizontal,1)
                                                .font(.custom(robotoMedium, size: 14))
                                            
                                            ForEach(options, id: \.self) { option in
                                                HStack {
                                                    Image(systemName: selectedRadio[field.label ?? ""] == option ? "largecircle.fill.circle" : "circle")
                                                        .foregroundColor(Color.defaultTheme)
                                                    Text(option)
                                                        .font(.custom(robotoMedium, size: 14))
                                                }
                                                .onTapGesture {
                                                    selectedRadio[field.label ?? ""] = option
                                                }
                                                .padding(.vertical, 2)
                                            }
                                        }
                                        .padding(.horizontal,16)
                                        .padding(.bottom, 8)
                                    }
                                }
                                
                            }
                        }
                        PrimaryButton(
                            title: "Add Variants",
                            isOutLine: false,
                            custFontName : poppinsSemiBold,
                            custFontSize : 14.0,
                            onButtonClick: {
                                print("hell")
                            }, imageName: "ic_Plus", btnColor: .white)
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal,12)
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Pricing".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        
                        AuthTextField(floatingLabel: "Buy it Now Price".localized,
                                      placeholder: "$0.0",
                                      icon: .menuProfile,
                                      text: $request.pricing,
                                      isIconDisplay : false,
                                      isForPrice:true,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { price in
//                            if let amt = Double(price) {
//                                if amt < 1.0 {
//                                    hudMsg = "Price should not be less than $1.00"
//                                    showhud = true
//                                } else {
                                    request.pricing = price
//                                }
//                            }
                        })
                        .keyboardType(.decimalPad)
                        //                        .padding(.horizontal , 16)
                        
                        MenuCell( title: "Flash Sale",fontName: robotoMedium,fontValue: 14.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedFlash,onToggle: { value in
                            if value == true{
                                request.flash_sale = "1"
                            }else{
                                request.flash_sale = "0"
                            }
                        })
                        .padding(.vertical,4)
                        .padding([.leading,.trailing],8)
                        MenuCell( title: "Accept offers",fontName: robotoMedium,fontValue: 14.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedAccept,onToggle: { value in
                            print(value)
                            if value == true{
                                request.accept_offers = "1"
                            }else{
                                request.accept_offers = "0"
                            }
                        })
                        .padding(.vertical,4)
                        .padding([.leading,.trailing],8)
                        MenuCell( title: "Reserve for Live",fontName: robotoMedium,fontValue: 14.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedReserve,onToggle: { value in
                            print(value)
                            if value == true{
                                request.reserve_for_live = "1"
                            }else{
                                request.reserve_for_live = "0"
                            }
                        })
                        .padding(.vertical,4)
                        .padding([.leading,.trailing],8)
                    }
                    .zIndex(1000)
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal,12)
                    
//                    VStack(alignment:.leading,spacing: 8){
//                        Text("Shipping".localized)
//                            .font(.custom(robotoMedium, size: 16.0))
//                            .padding(.top,8)
//                            .padding([.leading,.trailing],16.0)
//                        
//                        DropDownSelection(
//                            options: $shippingAddressName,
//                            floatingLabel:"Shipping Profile",
//                            hint: "Select Profile",
//                            selected: $shippingId,
//                            anchor: .bottom,
//                            custFontName: robotoMedium,
//                            custFontSize:  14.0,
//                            custCategory : robotoRegular,
//                            custCategorySize : 13.0,
//                            onOptionSelected: { value in
//                                if let id = ShippingAddress.first(where: { $0.name == value })?.id {
//                                    request.shipping_profile_id = "\(id)"
//                                    shippingId = value
//                                } else {
//                                    request.shipping_profile_id = ""
//                                }
//                            }
//                        )
//                        .padding(.bottom,8)
//                        .padding([.leading,.trailing],16)
                        
//                    }
                    
//                    .background(.white)
//                    .cornerRadius(12)
//                    .padding(.horizontal,12)
                    
//                    TwoButton(titleOne: "Save Draft", titleTwo: "Publish", onFirstButtonClick: {
//                        print(request)
//                        print(imageUrls)
//                        guard !imageUrls.isEmpty,imageUrls.count != 0 else{
//                            hudMsg = "Please select images"
//                            showhud = true
//                            return
//                        }
//                        guard !request.category_id.isEmpty else{
//                            hudMsg = "Please select category"
//                            showhud = true
//                            return
//                        }
//                        guard !request.title.isEmpty else{
//                            hudMsg = "Please enter title"
//                            showhud = true
//                            return
//                        }
//                        guard !request.description.isEmpty else{
//                            hudMsg = "Please enter description"
//                            showhud = true
//                            return
//                        }
//                        guard !request.quantity.isEmpty else{
//                            hudMsg = "Please enter quantity"
//                            showhud = true
//                            return
//                        }
//                        guard let quantity = Double(request.quantity), quantity >= 1.0 else{
//                            hudMsg = "Please enter quantity greater than 1"
//                            showhud = true
//                            return
//                        }
//                        guard !request.width.isEmpty else{
//                            hudMsg = "Please enter width"
//                            showhud = true
//                            return
//                        }
//                        guard !request.height.isEmpty else{
//                            hudMsg = "Please enter height"
//                            showhud = true
//                            return
//                        }
//                        guard !request.length.isEmpty else{
//                            hudMsg = "Please enter length"
//                            showhud = true
//                            return
//                        }
//                        guard !request.weight.isEmpty else{
//                            hudMsg = "Please enter weight"
//                            showhud = true
//                            return
//                        }
//                        guard !request.mail_class.isEmpty else{
//                            hudMsg = "Please select mail class"
//                            showhud = true
//                            return
//                        }
//                        guard !request.processing_category.isEmpty else{
//                            hudMsg = "Please select processing category"
//                            showhud = true
//                            return
//                        }
//                        guard !request.pricing.isEmpty else{
//                            hudMsg = "Please enter pricing"
//                            showhud = true
//                            return
//                        }
//                        guard let amt = Double(request.pricing), amt >= 1.0 else {
//                            hudMsg = "Price should not be less than $1.00"
//                            showhud = true
//                            return
//                        }
//                        
//                        
//                        guard !request.shipping_profile_id.isEmpty else{
//                            hudMsg = "Please select shipping address"
//                            showhud = true
//                            return
//                        }
//                        request.status = "draft"
//                        
//                        Task {
//                            await performAPICalls(
//                                isConcurrent: false,
//                                onError: { error in
//                                    alertType = .sheetType(
//                                        icon: .alert,
//                                        title: "Error",
//                                        message: error.localizedDescription,
//                                        primaryBtnText: "",
//                                        secondaryBtnText: AppString.ok.localized
//                                    )
//                                    showError = true
//                                }
//                            ) {
//                                await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
//                                uploadSuccess()
//                                
//                                guard let response = self.viewModel.storeImageResponse, response.status == "success"
//                                else {
//                                    return
//                                }
//                                
//                                let uploadedUrls: [[String: String]] = response.data.map {
//                                    return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
//                                }
//                                var variantArray: [[String: Any]] = []
//                                
//                                for field in extraFields {
//                                    guard let title = field.label, let type = field.type else { continue }
//                                    
//                                    if type == "text" {
//                                        // Handle text input
//                                        let value = extraFieldValues[title] ?? ""
//                                        variantArray.append([
//                                            "title": title,
//                                            "value": value
//                                        ])
//                                    } else if type == "radio", let options = field.options {
//                                        // Handle radio input
//                                        let selected = selectedRadio[title] ?? ""
//                                        
//                                        // Find which option key is selected (e.g. option_1 or option_2)
//                                        var selectedKey: String = ""
//                                        var valueDict: [String: String] = [:]
//                                        
//                                        for (index, option) in options.enumerated() {
//                                            let key = "option_\(index + 1)"
//                                            valueDict[key] = option
//                                            
//                                            if option == selected {
//                                                selectedKey = option
//                                            }
//                                        }
//                                        
//                                        valueDict["selected"] = selectedKey
//                                        
//                                        variantArray.append([
//                                            "title": title,
//                                            "value": valueDict
//                                        ])
//                                    }
//                                }
//                                
//                                self.viewModel.errorMessage?.removeAll()
//                                var request = [
//                                    "category_id": request.category_id,
//                                    "sub_category_id": request.sub_category_id ?? "",
//                                    "title": request.title,
//                                    "description": request.description,
//                                    "quantity": request.quantity,
//                                    "pricing": request.pricing,
//                                    "flash_sale": request.flash_sale,
//                                    "accept_offers": request.accept_offers,
//                                    "reserve_for_live": request.reserve_for_live,
//                                    "shipping_profile_id": request.shipping_profile_id,
//                                    "images": uploadedUrls
//                                    
//                                ]
//                                
//                                if !variantArray.isEmpty {
//                                    request["variant"] = variantArray
//                                }
//                                
//                                
//                                await viewModel.storeProduct(param: request)
//                                
//                                storeSuccess()
//                            }
//                            
//                            //                        Task{
//                            //                           guard Reachability.isConnectedToNetwork() else {
//                            //                                hudMsg = "No Internet Connection"
//                            //                                showhud = true
//                            //                                return
//                            //                            }
//                            //                            SVProgressHUD.show()
//                            //                            viewModel.errorMessage?.removeAll()
//                            //                            await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
//                            //                            if let errorMessage = self.viewModel.errorMessage, errorMessage != ""{
//                            //                                alertType = .sheetType(
//                            //                                    icon: .alert,
//                            //                                    title: "Failed",
//                            //                                    message: viewModel.errorMessage ?? "",
//                            //                                    primaryBtnText: "",
//                            //                                    secondaryBtnText: AppString.ok.localized
//                            //                                )
//                            //                                showError = true
//                            //                            }
//                            //                            else {
//                            //                                uploadSuccess()
//                            //                            }
//                            //                        }
//                        }
//                    }, onSecButtonClick: {
//                        print(request)
//                        print(imageUrls)
//                        guard !imageUrls.isEmpty,imageUrls.count != 0 else{
//                            hudMsg = "Please select images"
//                            showhud = true
//                            return
//                        }
//                        guard !request.category_id.isEmpty else{
//                            hudMsg = "Please select category"
//                            showhud = true
//                            return
//                        }
//                        guard !request.title.isEmpty else{
//                            hudMsg = "Please enter title"
//                            showhud = true
//                            return
//                        }
//                        guard !request.description.isEmpty else{
//                            hudMsg = "Please enter description"
//                            showhud = true
//                            return
//                        }
//                        guard !request.quantity.isEmpty else{
//                            hudMsg = "Please enter quantity"
//                            showhud = true
//                            return
//                        }
//                        guard let quantity = Double(request.quantity), quantity >= 1.0 else{
//                            hudMsg = "Please enter quantity greater than 1"
//                            showhud = true
//                            return
//                        }
//                        guard !request.width.isEmpty else{
//                            hudMsg = "Please enter width"
//                            showhud = true
//                            return
//                        }
//                        guard !request.height.isEmpty else{
//                            hudMsg = "Please enter height"
//                            showhud = true
//                            return
//                        }
//                        guard !request.length.isEmpty else{
//                            hudMsg = "Please enter length"
//                            showhud = true
//                            return
//                        }
//                        guard !request.weight.isEmpty else{
//                            hudMsg = "Please enter weight"
//                            showhud = true
//                            return
//                        }
//                        guard !request.mail_class.isEmpty else{
//                            hudMsg = "Please select mail class"
//                            showhud = true
//                            return
//                        }
//                        guard !request.processing_category.isEmpty else{
//                            hudMsg = "Please select processing category"
//                            showhud = true
//                            return
//                        }
//                        guard !request.pricing.isEmpty else{
//                            hudMsg = "Please enter pricing"
//                            showhud = true
//                            return
//                        }
//                        guard let amt = Double(request.pricing), amt >= 1.0 else {
//                            hudMsg = "Price should not be less than $1.00"
//                            showhud = true
//                            return
//                        }
//                        
//                        guard !request.shipping_profile_id.isEmpty else{
//                            hudMsg = "Please select shipping address"
//                            showhud = true
//                            return
//                        }
//                        request.status = "active"
//                        Task{
//                           guard Reachability.isConnectedToNetwork() else {
//                                hudMsg = "No Internet Connection"
//                                showhud = true
//                                return
//                            }
//                            SVProgressHUD.show()
//                            viewModel.errorMessage?.removeAll()
//                            await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
//                            if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
//                                uploadSuccess()
//                            }else{
//                                alertType = .sheetType(
//                                    icon: .alert,
//                                    title: "Failed",
//                                    message: viewModel.errorMessage ?? "",
//                                    primaryBtnText: "",
//                                    secondaryBtnText: AppString.ok.localized
//                                )
//                                showError = true
//                            }
//                        }
//                    }, height: 45, firstBtnTitleColor: .darkGray, secBtnTitleColor: .white, firstBtnBgColor: .white, secBtnBgColor:.darkBlue)
                    TwoButton(titleOne: "Save Draft", titleTwo: "Publish",
                     onFirstButtonClick: {
                        hideKeyboardPopup()
                        saveProductDetails(as: "draft")
                    }, onSecButtonClick: {
                        hideKeyboardPopup()
                        saveProductDetails(as: "active")
                    },
                    height: 45,
                    firstBtnTitleColor: .darkGray,
                    secBtnTitleColor: .white,
                    firstBtnBgColor: .white,
                    secBtnBgColor: .darkBlue)

                    .padding(.horizontal,12)
                }
//                .edgesIgnoringSafeArea(.top)
                .padding(.all,0)
                .padding(.horizontal,12)
//                .background(.bg.opacity(0.5))
                
                .bottomSheet(
                    isPresented: $showSubCategorySheet,
                    height: selectedOption.count < 4 ? screenHeight * 0.4 : screenHeight/1.7,
                    topBarCornerRadius: 25,
                    showTopIndicator: false,
                    onDismiss: {
                        showSubCategorySheet = true
                    },
                    content: {
                        SelectionBottomSheet(
                            title: "Select sub category",
                            message: "Please select subcategory.",
                            options: $subCategoryName,
                            selectedOptions: $selectedOption,
                            onSelectionDone: { selectedIndexes in
                                if let index = selectedIndexes.first {
                                    let selectedValue = subCategoryList[index]
                                    selectedSubCategory = selectedValue.name ?? ""
                                    request.sub_category_id = "\(selectedValue.id ?? 0)"
                                    selectedCategory = "\(selectedCategory) (\(selectedValue.name ?? ""))"
                                    print("Selected SubCategory: \(selectedValue.name ?? "")")
                                    self.extraFields = selectedValue.extra_fields ?? []
//                                    if let extraFields =  self.viewModel.categoryResponse?.data[index].extra_fields{
//                                        
//                                    }
                                }
                                showSubCategorySheet = false
                            }
                        )
                    }
                )
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                    
                }
//                .toast(isPresenting: $isImageSizeExceeding) {
//                    AlertToast(displayMode: .hud, type: .regular, title: "Please select image size less than 5 MB", style: alertStlye)
//                }
                .bottomSheet(isPresented: $showError, height: screenHeight * 0.28, topBarCornerRadius: 25, showTopIndicator: false,
                    onDismiss: {
                    if let errorMessage = viewModel.errorMessage {
                        showError = false
                        viewModel.errorMessage = nil
                    }else{
                        showError = true
                    }
                }, content: {
                    CommonBottomSheet(
                        sheetType: $alertType,
                        onPrimaryClick: {
                            if let errorMessage = viewModel.errorMessage {
                                showError = false
                                viewModel.errorMessage = nil
                            }else{
                                self.presentationMode.wrappedValue.dismiss()
                                withAnimation {
                                    showError = false
                                    viewModel.errorMessage = nil
                                }
                            }
                        }, onSecondaryClick: {
                            withAnimation {
                                showError = false
                                viewModel.errorMessage = nil
                            }
                        })
                })
//            }
//            .padding([.leading,.trailing],12)
        }
//        .edgesIgnoringSafeArea(.top/)
        .background(.bg.opacity(0.4))
        .onFirstAppear(perform: {
            Task{
                
                await performAPICalls(
                    isConcurrent: true,
                    onError: { error in
                        alertType = .sheetType(
                            icon: .alert,
                            title: "Error",
                            message: viewModel.errorMessage ?? "",
                            primaryBtnText: "",
                            secondaryBtnText: AppString.ok.localized
                        )
                        showError = true
                    }, onSuccess: {
                        // On success
                        categorySuccess()
//                        shippingAddressSuccess()
                        mailSuccess()
                    }
                    
                ) {
                    // 👇 These run in parallel
                    async let categoryTask: () = viewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
                    async let mailTask: () = viewModel.getMailClasses()
                    
                    // Wait for all
                    _ = try await (categoryTask, mailTask)
                }
                
                
//               guard Reachability.isConnectedToNetwork() else {
//                    hudMsg = "No Internet Connection"
//                    showhud = true
//                    return
//                }
//                SVProgressHUD.show()
//                await viewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
//                await SVProgressHUD.dismiss()
//                if self.viewModel.errorMessage == nil || self.viewModel.errorMessage == "" {
//                    categorySuccess()
//                }else{
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: self.viewModel.errorMessage ?? "",
//                        primaryBtnText: "",
//                        secondaryBtnText: AppString.ok.localized
//                    )
//                    await SVProgressHUD.dismiss()
//                    showError = true
//                }
//                self.viewModel.errorMessage?.removeAll()
//                await viewModel.getAddresses()
                
//                if self.viewModel.errorMessage == nil || self.viewModel.errorMessage == "" {
//                    shippingAddressSuccess()
//                }else{
//                    await SVProgressHUD.dismiss()
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: self.viewModel.errorMessage ?? "",
//                        primaryBtnText: "",
//                        secondaryBtnText: AppString.ok.localized
//                    )
//                    showError = true
//                }
//                self.viewModel.errorMessage?.removeAll()
//                await viewModel.getMailClasses()
//                await SVProgressHUD.dismiss()
//                if self.viewModel.errorMessage == nil || self.viewModel.errorMessage == "" {
//                    mailSuccess()
//                }else{
//                    alertType = .sheetType(
//                        icon: .alert,
//                        title: "Error",
//                        message: self.viewModel.errorMessage ?? "",
//                        primaryBtnText: "",
//                        secondaryBtnText: AppString.ok.localized
//                    )
//                    showError = true
//                }
            }
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func mailSuccess() {
        let response = viewModel.mailClassResponse
        if viewModel.errorMessage == nil {
            let data = response?.data.mail_classes ?? [MailClass]()
            self.mailClassList = data.map {$0.label }
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            
            
        }
    }
    
    func saveProductDetails(as status: String) {
        // 🔹 Step 1: Validation
        guard validateRequest(request, imageUrls: imageUrls) else {
            showhud = true
            return
        }
        
        // 🔹 Step 2: Update status
        request.status = status
        
        // 🔹 Step 3: Perform Sequential API calls
        Task {
            await performAPICalls(
                isConcurrent: false,
                onError: { error in
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            ) {
                viewModel.errorMessage?.removeAll()
                try await viewModel.uploadStoreImage(images: imageUrls, key: "images[]")
                if let errorMessage = self.viewModel.errorMessage, errorMessage != "" {
                    alertType = .sheetType(
                        icon: .alert,
                        title: "Error",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
                else  {
                    guard let response = self.viewModel.storeImageResponse,
                          response.status == "success" else { return }
                    
                    // 🔹 Build uploaded image data
                    let uploadedUrls: [[String: String]] = response.data.map {
                        ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
                    }
                    
                    // 🔹 Build extra fields
                    let variantArray = buildVariantArray(extraFields: extraFields,
                                                         extraFieldValues: extraFieldValues,
                                                         selectedRadio: selectedRadio)
                    
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
                        "shipping_profile_id": "4",//static for now
                        "auction": "true",
                        // ✅ Newly added fields
                        "width": request.width,
                        "length": request.length,
                        "weight": request.weight,
                        "height": request.height,
                        "mail_class": request.mail_class,
                        "processing_category": request.processing_category,
                        "product_condition": request.product_condition,
                        // ✅ Images array (already present)
                        "images": uploadedUrls,
                        "type": "live"
                        
                    ]

                    if !variantArray.isEmpty {
                        productRequest["variant"] = variantArray
                    }
                    
                    // 🔹 Call product store API
                    self.viewModel.errorMessage?.removeAll()
                    try await viewModel.storeProduct(param: productRequest)
                    storeSuccess()
                }
            }
        }
    }
    
    
    func categorySuccess() {
       
        let response = viewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
            self.categoryNames = response?.data.map { $0.name ?? "No Category" } ?? [String]()
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
    
    func shippingAddressSuccess() {
       
        let response = viewModel.addressesResponse
        if response?.status == "success" {
            self.ShippingAddress = response?.data ?? [AddressModel]()
            self.shippingAddressName = response?.data.map { $0.name ?? "No Category" } ?? [String]()
            
            if self.productData != nil {
                selectedCategory = productData.category?.name ?? ""
                request = StoreProductParam(category_id: "\(productData.category?.id ?? 0)",
                                            title: productData.title ?? "",
                                            description: productData.description ?? "",
                                            quantity: "\(productData.quantity ?? "0")",
                                            pricing: "\(productData.pricing ?? "0.0")",
                                            flash_sale:productData.flashSale ?? false ? "1" : "0",
                                            accept_offers: productData.acceptOffers ?? false ? "1" : "0",
                                            reserve_for_live: productData.reserveForLive ?? false ? "1" : "0",
                                            shipping_profile_id: "\(productData.shippingProfileID ?? 0)",
                                            status: productData.status ?? "",
                                            width : "",
                                            length : "",
                                            weight : "",
                                            height : "",
                                            mail_class : "",
                                            processing_category : "",
                                            product_condition : "")
                
                isTappedFlash = productData.flashSale ?? false ? true : false
                isTappedAccept = productData.acceptOffers ?? false ? true : false
                isTappedReserve = productData.reserveForLive ?? false ? true : false
                
                self.imageUrls = productData.images ?? [String]()
                if request.category_id == "0"{
                    request.category_id.removeAll()
                }
                if request.quantity == "0"{
                    request.quantity.removeAll()
                }
                if request.pricing == "0.0" {
                    request.pricing.removeAll()
                }
                if imageUrls == [""]{
                    self.imageUrls.removeAll()
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
    
//    func uploadSuccess(){
//        guard let response = self.viewModel.storeImageResponse,
//                response.status == "success"
//                else {
//              return
//          }
////            let response = self.viewModel.storeImageResponse
//        if response.status == "success"{
//            let uploadedUrls: [[String: String]] = response.data.map {
//                return ["image": $0.images ?? "", "thumbnail": $0.thumbnail ?? ""]
//            }
//            var variantArray: [[String: Any]] = []
//
//            for field in extraFields {
//                guard let title = field.label, let type = field.type else { continue }
//
//                if type == "text" {
//                    // Handle text input
//                    let value = extraFieldValues[title] ?? ""
//                    variantArray.append([
//                        "title": title,
//                        "value": value
//                    ])
//                } else if type == "radio", let options = field.options {
//                    // Handle radio input
//                    let selected = selectedRadio[title] ?? ""
//                    
//                    // Find which option key is selected (e.g. option_1 or option_2)
//                    var selectedKey: String = ""
//                    var valueDict: [String: String] = [:]
//
//                    for (index, option) in options.enumerated() {
//                        let key = "option_\(index + 1)"
//                        valueDict[key] = option
//
//                        if option == selected {
//                            selectedKey = option
//                        }
//                    }
//
//                    valueDict["selected"] = selectedKey
//
//                    variantArray.append([
//                        "title": title,
//                        "value": valueDict
//                    ])
//                }
//            }
//
//                SVProgressHUD.dismiss()
//                Task{
//                    self.viewModel.errorMessage?.removeAll()
//                    var request = [
//                        
//                        "category_id": request.category_id,
//                        "sub_category_id": request.sub_category_id ?? "",
//                        "title": request.title,
//                        "description": request.description,
//                        "quantity": request.quantity,
//                        "pricing": request.pricing,
//                        "flash_sale": request.flash_sale,
//                        "accept_offers": request.accept_offers,
//                        "reserve_for_live": request.reserve_for_live,
//                        "shipping_profile_id": request.shipping_profile_id,
//                        "images": uploadedUrls
//                        
//                            
//                        ]
//                            
//                    if !variantArray.isEmpty {
//                        request["variant"] = variantArray
//                    }
//                        
//                    
//                    await viewModel.storeProduct(param: request)
//                    await SVProgressHUD.dismiss()
//                    if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
//                        storeSuccess()
//                    }else{
//                        alertType = .sheetType(
//                            icon: .alert,
//                            title: "Failed",
//                            message: viewModel.errorMessage ?? "",
//                            primaryBtnText: "",
//                            secondaryBtnText: AppString.ok.localized
//                        )
//                        showError = true
//                    }
//                }
//            }
//        
//    }
    
    // MARK: - Validation
    private func validateRequest(_ request: StoreProductParam, imageUrls: [String]) -> Bool {
        if imageUrls.isEmpty {
            hudMsg = "Please select images"
            return false
        }
        if request.category_id.isEmpty {
            hudMsg = "Please select category"
            return false
        }
        if request.title.isEmpty {
            hudMsg = "Please enter title"
            return false
        }
        if request.description.isEmpty {
            hudMsg = "Please enter description"
            return false
        }
        if request.quantity.isEmpty {
            hudMsg = "Please enter quantity"
            return false
        }
        guard let quantity = Double(request.quantity), quantity >= 1 else {
            hudMsg = "Please enter quantity greater than 1"
            return false
        }
        if request.width.isEmpty { hudMsg = "Please enter width"; return false }
        if request.height.isEmpty { hudMsg = "Please enter height"; return false }
        if request.length.isEmpty { hudMsg = "Please enter length"; return false }
        if request.weight.isEmpty { hudMsg = "Please enter weight"; return false }
        if request.mail_class.isEmpty { hudMsg = "Please select mail class"; return false }
        if request.processing_category.isEmpty { hudMsg = "Please select processing category"; return false }
        if request.product_condition.isEmpty { hudMsg = "Please select product condition"; return false }
        if request.pricing.isEmpty { hudMsg = "Please enter pricing"; return false }
        guard let price = Double(request.pricing), price >= 1 else {
            hudMsg = "Price should not be less than $1.00"
            return false
        }
//        if request.shipping_profile_id.isEmpty {
//            hudMsg = "Please select shipping address"
//            return false
//        }
        return true
    }

    // MARK: - Variant Builder
    private func buildVariantArray(
        extraFields: [ExtraFieldModel],
        extraFieldValues: [String: String],
        selectedRadio: [String: String]
    ) -> [[String: Any]] {
        var variantArray: [[String: Any]] = []
        
        for field in extraFields {
            guard let title = field.label, let type = field.type else { continue }
            
            if type == "text" {
                let value = extraFieldValues[title] ?? ""
                variantArray.append(["title": title, "value": value])
            } else if type == "radio", let options = field.options {
                let selected = selectedRadio[title] ?? ""
                var valueDict: [String: String] = [:]
                
                for (index, option) in options.enumerated() {
                    let key = "option_\(index + 1)"
                    valueDict[key] = option
                }
                valueDict["selected"] = selected
                
                variantArray.append(["title": title, "value": valueDict])
            }
        }
        return variantArray
    }

    
    func storeSuccess(){
        if let errorMessage = viewModel.errorMessage {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: errorMessage,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }else{
            let response = viewModel.storeProductResponse
            alertType = .sheetType(
                icon: .success,
                title: "Success",
                message: response?.message ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
            showError = true
        }
    }
   
}

//#Preview {
//    ListProductScreen()
//}
//
