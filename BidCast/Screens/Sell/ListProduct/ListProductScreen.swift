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
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "",sub_category_id: "")
    
    @State var viewModel = ListProductViewModel()
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
    
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]

    var body: some View {
        
        ZStack {
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
                                    let request = CategoryRequest(category_id: request.category_id)
                                    SVProgressHUD.show()
                                    await self.viewModel.getCategoryList(param: request)
                                    self.subCategoryList.removeAll()
                                    await SVProgressHUD.dismiss()
                                    if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil {
                                        if let response = self.viewModel.categoryResponse{
                                            self.subCategoryList = response.data
                                            self.subCategoryName = self.subCategoryList.map { $0.name ?? ""}
                                        }
                                        if subCategoryList.count != 0{
                                            showSubCategorySheet = true
                                        }
                                    }else{
                                        showSubCategorySheet = false
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
                        
                         let extraFields = self.extraFields
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
                        
                        AuthTextField(floatingLabel: "Buy it Now Price".localized, placeholder: "0.00".localized, icon: .menuProfile, text: $request.pricing,isIconDisplay : true, isForPrice:true,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { price in
                            request.pricing = price
                        })
                        .keyboardType(.numberPad)
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
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal,12)
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Shipping".localized)
                            .font(.custom(robotoMedium, size: 16.0))
                            .padding(.top,8)
                            .padding([.leading,.trailing],16.0)
                        
                        DropDownSelection(
                            options: $shippingAddressName,
                            floatingLabel:"Shipping Profile",
                            hint: "Select Profile",
                            selected: $shippingId,
                            anchor: .top,custFontName: robotoMedium,
                            custFontSize:  14.0,
                            custCategory : robotoRegular,
                            custCategorySize : 13.0,
                            onOptionSelected: { value in
                                if let id = ShippingAddress.first(where: { $0.name == value })?.id {
                                    request.shipping_profile_id = "\(id)"
                                    shippingId = value
                                } else {
                                    request.shipping_profile_id = ""
                                }
                            }
                        )
                        .padding(.bottom,8)
                        .padding([.leading,.trailing],16)
                        
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal,12)
                    
                    TwoButton(titleOne: "Save Draft", titleTwo: "Publish", onFirstButtonClick: {
                        print(request)
                        print(imageUrls)
                        guard !imageUrls.isEmpty else{
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
                        guard !request.quantity.isEmpty else{
                            hudMsg = "Please enter quantity"
                            showhud = true
                            return
                        }
                        guard !request.pricing.isEmpty else{
                            hudMsg = "Please enter pricing"
                            showhud = true
                            return
                        }
                        guard !request.shipping_profile_id.isEmpty else{
                            hudMsg = "Please select shipping address"
                            showhud = true
                            return
                        }
                        request.status = "draft"
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            await viewModel.storeProduct(param: request, images: imageUrls, key: "images[]")
                            await SVProgressHUD.dismiss()
                            if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
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
                    }, onSecButtonClick: {
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
                        guard !request.quantity.isEmpty else{
                            hudMsg = "Please enter quantity"
                            showhud = true
                            return
                        }
                        guard !request.pricing.isEmpty else{
                            hudMsg = "Please enter pricing"
                            showhud = true
                            return
                        }
                        guard !request.shipping_profile_id.isEmpty else{
                            hudMsg = "Please select shipping address"
                            showhud = true
                            return
                        }
                        request.status = "active"
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            await viewModel.storeProduct(param: request, images: imageUrls, key: "images[]")
                            await SVProgressHUD.dismiss()
                            if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
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
                    }, height: 45, firstBtnTitleColor: .darkGray, secBtnTitleColor: .white, firstBtnBgColor: .white, secBtnBgColor:.darkBlue)

                }
//                .edgesIgnoringSafeArea(.top)
                .padding(.all,0)
//                .background(.bg.opacity(0.5))
                
                .bottomSheet(
                    isPresented: $showSubCategorySheet,
                    height: selectedOption.count < 4 ? screenHeight * 0.5 : screenHeight/1.7,
                    topBarCornerRadius: 25,
                    showTopIndicator: false,
                    onDismiss: {
                        showSubCategorySheet = true
                    },
                    content: {
                        SelectionBottomSheet(
                            title: "Select Sub-Category",
                            message: "Please select Sub-category.",
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
                .bottomSheet(isPresented: $showError, height: screenHeight * 0.3, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
                    if self.viewModel.errorMessage != "" || self.viewModel.errorMessage != nil{
                        showError = true
                    }else{
                        showError = false
                    }
                }, content: {
                    CommonBottomSheet(
                        sheetType: $alertType,
                        onPrimaryClick: {
                            self.presentationMode.wrappedValue.dismiss()
                            withAnimation { showError = false }
                        }, onSecondaryClick: {
                            withAnimation { showError = false }
                        })
                })
            }
//            .padding([.leading,.trailing],12)
        }
//        .edgesIgnoringSafeArea(.top/)
        .background(.bg.opacity(0.4))
        .onFirstAppear(perform: {
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await viewModel.getCategoryList(param: CategoryRequest(category_id: ""))
                
                categorySuccess()
                
                await viewModel.getAddresses()
                await SVProgressHUD.dismiss()
                shippingAddressSuccess()
                
                
            }
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
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
                                            quantity: "\(productData.quantity ?? 0)",
                                            pricing: "\(productData.pricing ?? 0.0)",
                                            flash_sale:productData.flashSale ?? false ? "1" : "0",
                                            accept_offers: productData.acceptOffers ?? false ? "1" : "0",
                                            reserve_for_live: productData.reserveForLive ?? false ? "1" : "0",
                                            shipping_profile_id: "\(productData.shippingProfileID ?? 0)",
                                            status: productData.status ?? "")
             
                isTappedFlash = productData.flashSale ?? false ? true : false
                isTappedAccept = productData.acceptOffers ?? false ? true : false
                isTappedReserve = productData.reserveForLive ?? false ? true : false
               
                self.imageUrls = productData.images ?? [""]
                
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
   
}

//#Preview {
//    ListProductScreen()
//}
//
