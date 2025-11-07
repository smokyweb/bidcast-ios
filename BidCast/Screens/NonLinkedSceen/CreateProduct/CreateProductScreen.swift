//
//  CreateProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

enum CreateProductNavigation {
    case inventry
    case other
}


struct CreateProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
    //previuos Data
    @Binding var requests : StoreScheduleShowRequest
    @Binding var thumbNail : String
    @Binding var backToPrepare : Bool
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
    //category request data
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "1", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "2", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"")
    
    @State var viewModel = ListProductViewModel()
    @State var imageUrls: [String] = []
    
    @State var showSellerSheet = false
    @State var navigateToSeller = false
    @State var showSubCategorySheet = false
    @State var selectedOption: Set<String> = []
    @State var selectedSubCategory = ""
    @State var subCategoryList: [CategoryDataModel] = []
    @State var subCategoryName : [String] = [""]
//    @Binding var productData : InventoryDataModel
    @State var extraFields: [ExtraFieldModel] = []
    @State var processingListArr = ["LETTERS","FLATS","MACHINABLE","NONSTANDARD","NON_MACHINABLE"]
    @State var extraFieldValues: [String: String] = [:]
    @State var selectedRadio: [String: String] = [:]
    @State var navigateToAddProduct = false
    @State var navigateToSalesFormat = false
    @State var navigateToProuct = false
    @Binding var fromPrepare : Bool
    var delegate: ShowStepDelegate?
    
    var isComeFrom: CreateProductNavigation = .other
    
    var body: some View {
        
//        ZStack {
            VStack{
                VStack{
                    PrimaryHeader(
                        title: "Create Product".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                ScrollView(showsIndicators:false) {
                    
                    MediaPickerView(uploadedImageUrls: $imageUrls)
                        .padding(.horizontal,12)
                        .background(.clear)
                    
                    VStack(alignment:.leading,spacing: 8){
                        
                        DropDownSelection(
                            options: $categoryNames,
                            floatingLabel:"Category",
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
                                Task {
                                    await performAPICalls(
                                        isConcurrent: false,
                                        onError: { error in
                                            showSubCategorySheet = false
                                        }
                                    ) {
                                        let request = CategoryRequest(category_id: request.category_id)
                                        await self.viewModel.getSubCategoryList(param: request)
                                        self.subCategoryList.removeAll()
                                        if let response = self.viewModel.categoryResponse{
                                            self.subCategoryList = response.data
                                            self.subCategoryName = self.subCategoryList.map { $0.name ?? ""}
                                        }
                                        if subCategoryList.count != 0{
                                            showSubCategorySheet = true
                                        }
                                    }
                                }
                            }
                        )
                        .disabled(isComeFrom == .inventry ? false : !selectedCategory.isEmpty)
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
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.processing_category = value
//                                } else {
//                                    request.processing_category = ""
//                                }
                            }
                        )
                       
                        .padding([.leading,.trailing],16)
                        .background(.clear)
                        // Quantity Selector
                        HStack(spacing: 6) {
                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                if quantity > 1 {
                                    quantity -= 1
                                    request.quantity = "\(quantity)" // keep request in sync
                                }
                            }) {
                                Image(systemName: "minus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(request.quantity)")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(width: 50, alignment: .center)
                            
                            Button(action: {
                                var quantity = Int(request.quantity) ?? 0
                                quantity += 1
                                request.quantity = "\(quantity)"
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(width: 40, height: 40) // fixed size
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal,12)


                
                        PrimaryButton(
                            title: "Add Variants",
                            isOutLine: false,
                            custFontName : poppinsSemiBold,
                            custFontSize : 14.0,
                            onButtonClick: {
                                print("hell")
                            }, imageName: "ic_Plus", btnColor: .white)
                    }
                    
//                    .background(.white)
                    .cornerRadius(12)
                    .padding(.horizontal,12)

                    TwoButton(titleOne: "Continue", titleTwo: "Use Product Library", onFirstButtonClick: {
                        print(request)
                        print(imageUrls)
                        guard !imageUrls.isEmpty,imageUrls.count != 0 else{
                            hudMsg = "Please select images"
                            showhud = true
                            return
                        }
                        guard !requests.category_id.isEmpty else{
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
                        navigateToSalesFormat = true
                    }, onSecButtonClick: {
                        if self.fromPrepare{
                            navigateToProuct = true
                        }else{
                            navigateToAddProduct = true
                        }
                        
                    }, height: 45, firstBtnTitleColor: .darkGray, secBtnTitleColor: .white, firstBtnBgColor: .white, secBtnBgColor:.darkBlue)
                    .padding(.horizontal,12)
                    .padding(.bottom, 16)
                }
//                .edgesIgnoringSafeArea(.top)
                .padding(.horizontal,12)
//                .ignoresSafeArea(.all, edges: .bottom)
//                .background(.bg.opacity(0.5))
                
                .bottomSheet(
                    isPresented: $showSubCategorySheet,
                    height: selectedOption.count < 4 ? screenHeight * 0.35 : screenHeight/1.7,
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
//            }
//            .padding([.leading,.trailing],12)
        }
            
        
        CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$requests,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare, NavFromProductLibrary: .constant(false), backToCreateProduct:$navigateToAddProduct))
        
        CusNavLink(doNavigate: $navigateToProuct, destination: AddProductsScreen(request:$requests,thumbNail: $thumbNail,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare, NavFromProductLibrary: .constant(false), backToCreateProduct: .constant(false), delegate: delegate))
        
        CusNavLink(doNavigate: $navigateToSalesFormat, destination: SalesFormatScreen(request: $request,storeScheduleRequest: $requests, imageUrls : $imageUrls,thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: $fromPrepare,backToCreateProduct:$navigateToSalesFormat,delegate: delegate))
        .onFirstAppear(perform: {
           
            Task {
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
                    }
                ) {
                    // 👇 These run in parallel
                    async let categoryTask: () = viewModel.getSubCategoryList(param: CategoryRequest(category_id: ""))
                    async let addressTask: () = viewModel.getAddresses()
                    async let mailTask: () = viewModel.getMailClasses()
                    
                    // Wait for all
                    _ = try await (categoryTask, addressTask, mailTask)
                    
                    // On success
                    categorySuccess()
                    shippingAddressSuccess()
                    mailSuccess()
                }
            }
//            Task{
//                guard Reachability.isConnectedToNetwork() else {
//                    hudMsg = "No Internet Connection"
//                    showhud = true
//                    return
//                }
//                SVProgressHUD.show()
//            await viewModel.getCategoryList(param: CategoryRequest(category_id: ""))
//                if let errorMessage = self.viewModel.errorMessage, errorMessage != "" {
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
//                else  {
//                    categorySuccess()
//                }
//                self.viewModel.errorMessage?.removeAll()
//                await viewModel.getAddresses()
//                
//                if let errorMessage = self.viewModel.errorMessage, errorMessage != "" {
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
//                else  {
//                    shippingAddressSuccess()
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
//            
//                
//                
//            
//            }
        })
        .onAppear {
            //assign categoryId
            request.category_id = "\(requests.category_id)"
        }
        .background(.bg.opacity(0.5))
        .ignoresSafeArea(.container, edges: .bottom) 
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func mailSuccess() {
       
        let response = viewModel.mailClassResponse
        if response?.status == "success" {
            let data = response?.data.mail_classes ?? [MailClass]()
            self.mailClassList = data.map {$0.label }
        } else {
            alertType = .sheetType(
                icon: .success,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    func categorySuccess() {
       
        let response = viewModel.categoryResponse
        if response?.status == "success" {
            self.categoryList = response?.data ?? [CategoryDataModel]()
            self.selectedCategory = self.categoryList.filter({$0.id == Int(requests.category_id)}).first?.name ?? ""
            self.categoryNames = response?.data.map { $0.name ?? "No Category" } ?? [String]()
        } else {
            alertType = .sheetType(
                icon: .success,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
        }
    }
    
    func shippingAddressSuccess() {
       
        let response = viewModel.addressesResponse
        if response?.status == "success" {
            self.ShippingAddress = response?.data ?? [AddressModel]()
            self.shippingAddressName = response?.data.map { $0.name ?? "No Category" } ?? [String]()
            
//            if self.productData != nil {
//                selectedCategory = productData.category?.name ?? ""
//                request = StoreProductParam(category_id: "\(productData.category?.id ?? 0)",
//                                            title: productData.title ?? "",
//                                            description: productData.description ?? "",
//                                            quantity: "\(productData.quantity ?? 0)",
//                                            pricing: "\(productData.pricing ?? 0.0)",
//                                            flash_sale:productData.flashSale ?? false ? "1" : "0",
//                                            accept_offers: productData.acceptOffers ?? false ? "1" : "0",
//                                            reserve_for_live: productData.reserveForLive ?? false ? "1" : "0",
//                                            shipping_profile_id: "\(productData.shippingProfileID ?? 0)",
//                                            status: productData.status ?? "",
//                                            width : "",
//                                            length : "",
//                                            weight : "",
//                                            height : "",
//                                            mail_class : "",
//                                            processing_category : "")
//                
//                quantity = productData.quantity ?? 1
//                request.quantity = "\(quantity)"
//             
//                isTappedFlash = productData.flashSale ?? false ? true : false
//                isTappedAccept = productData.acceptOffers ?? false ? true : false
//                isTappedReserve = productData.reserveForLive ?? false ? true : false
//               
//                self.imageUrls = productData.images ?? [String]()
//                if request.category_id == "0"{
//                    request.category_id.removeAll()
//                }
//                if request.quantity == "0"{
//                    request.quantity.removeAll()
//                }
//                if request.pricing == "0.00"{
//                    request.pricing.removeAll()
//                }
//                if imageUrls == [""]{
//                    self.imageUrls.removeAll()
//                }
//                
//            }
        } else {
            alertType = .sheetType(
                icon: .success,
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText:""
            )
            showError = true
            
            
        }
    }
    
//    func uploadSuccess() {
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
//    }
    
    
//    func storeSuccess(){
//        let response = viewModel.storeProductResponse
//        if response?.status == "success"{
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
   
}


