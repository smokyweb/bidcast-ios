//
//  CreateProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI
import SVProgressHUD

//struct CreateProductScreen: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State private var selectedCategory = ""
//    @State private var title = ""
//    @State private var description = ""
//    @State private var quantity = 1
//    @State var imageUrls : [String] = [""]
//    @State var navigateToSalesFormat = false
//    @State var navigateToAddProduct = false
//    @State var showSubCategorySheet = false
//    @Binding var request : StoreScheduleShowRequest
//    @Binding var thumbNail : String
//    @Binding var backToPrepare : Bool
//    @State var categoryNames: [String] = []
//    @State var categoryList: [CategoryDataModel] = []
//    @State var selectedSubCategory = ""
//    @State var subCategoryList: [CategoryDataModel] = []
//    @State var subCategoryName : [String] = [""]
//    @State var mailClassList = [String]()
//    @State var processingListArr = ["LETTERS","FLATS","MACHINABLE","NONSTANDARD","NON_MACHINABLE"]
//    @State var selectedRadio: [String: String] = [:]
//    @State var selectedOption: Set<String> = []
//    @State var viewModel = ListProductViewModel()
//
//
//    var body: some View {
//        VStack(spacing: 16) {
//            // Header
//            VStack{
//                PrimaryHeader(
//                    title: "Create Product".localized,
//                    isForLogo : false ,leadingImgArr: [.icBack],
//                    onClickLeading: { _ in
//                        self.presentationMode.wrappedValue.dismiss()
//                    },
//                    count: .constant(0)
//                )
//            }
//
//            ScrollView{
//
//                HStack(alignment: .top, spacing: 8) {
//                    Image(systemName: "info.circle.fill")
//                        .foregroundColor(.blue)
//                    Text("Detailed product listings help buyers make informed decisions and increase your chances of making a sale.")
//                        .font(.custom(poppinsRegular, size: 11.0))
//                        .foregroundColor(.blue)
//                }
//                .padding()
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(8)
//                .padding(.horizontal)
//
//                // Photos
//                VStack(alignment: .leading, spacing: 8) {
//
//
//                    MediaPickerView(title:"Photos",uploadedImageUrls: $imageUrls)
//                        .frame(height:180)
//                        .padding(.horizontal,-12)
//
//                    Text("Add up to 8 photos")
//                        .font(.custom(poppinsRegular, size: 11.0))
//                        .foregroundColor(.gray)
//                }
//                .padding(.horizontal)
//
//                // Category Picker
//                VStack(alignment:.leading,spacing: 8){
//                    DropDownSelection(
//                        options: $categoryNames, floatingLabel:"Category",
//                        hint: "Select Category",
//                        selected: $selectedCategory,
//                        anchor: .bottom,
//                        custFontName: robotoMedium,
//                        custFontSize:  14.0,
//                        custCategory : robotoRegular,
//                        custCategorySize : 13.0,
//                        onOptionSelected: { value in
//                            selectedCategory = value
//                            if let id = categoryList.first(where: { $0.name == value })?.id {
//                                request.category_id = "\(id)"
//                            } else {
//                                request.category_id = ""
//                            }
//                            Task{
//                                let request = CategoryRequest(category_id: request.category_id)
//                                SVProgressHUD.show()
//                                await self.viewModel.getCategoryList(param: request)
//                                self.subCategoryList.removeAll()
//                                await SVProgressHUD.dismiss()
//                                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil {
//                                    if let response = self.viewModel.categoryResponse{
//                                        self.subCategoryList = response.data
//                                        self.subCategoryName = self.subCategoryList.map { $0.name ?? ""}
//                                    }
//                                    if subCategoryList.count != 0{
//                                        showSubCategorySheet = true
//                                    }
//                                }else{
//                                    showSubCategorySheet = false
//                                }
//                            }
//                        }
//                    )
//                    .zIndex(1201.0)
//                    .padding([.leading,.trailing],16)
//                    AuthTextField(
//                        floatingLabel: "Title".localized,
//                        placeholder: "Enter Product title".localized,
//                        icon: .menuProfile,
//                        text: $request.title ,
//                        isIconDisplay : false,
//                        custFontName : robotoMedium,
//                        custFontSize : 14.0,
//                        enteredText:  { title in
//                            request.title = title
//                        })
//                    .keyboardType(.alphabet)
//                    .padding([.top,.bottom],4)
//
//                    DescriptionFieldView(
//                        description:$request.description,
//                        custFontName : robotoMedium,
//                        custFontSize : 14.0
//                    )
//                    { message in
//                        request.description = message
//                    }
//                    AuthTextField(floatingLabel: "Quantity".localized, placeholder: "Enter Quantity".localized, icon: .menuProfile, text: $request.quantity ,isIconDisplay : false,
//                                  custFontName : robotoMedium,
//                                  custFontSize : 14.0,
//                                  enteredText:  { quantity in
//                        request.quantity = quantity
//                    })
//                    .keyboardType(.numberPad)
//                    .padding([.bottom],4)
//                    AuthTextField(floatingLabel: "Width (cm)".localized, placeholder: "Enter width".localized, icon: .menuProfile, text: $request.width ,isIconDisplay : false,
//                                  custFontName : robotoMedium,
//                                  custFontSize : 14.0,
//                                  enteredText:  { quantity in
//                        request.width = quantity
//                    })
//                    .keyboardType(.decimalPad)
//                    .padding([.bottom],4)
//                    AuthTextField(floatingLabel: "Height (cm)".localized, placeholder: "Enter height".localized, icon: .menuProfile, text: $request.height ,isIconDisplay : false,
//                                  custFontName : robotoMedium,
//                                  custFontSize : 14.0,
//                                  enteredText:  { quantity in
//                        request.height = quantity
//                    })
//                    .keyboardType(.decimalPad)
//                    .padding([.bottom],4)
//                    AuthTextField(floatingLabel: "Length (cm)".localized, placeholder: "Enter length".localized, icon: .menuProfile, text: $request.length ,isIconDisplay : false,
//                                  custFontName : robotoMedium,
//                                  custFontSize : 14.0,
//                                  enteredText:  { quantity in
//                        request.length = quantity
//                    })
//                    .keyboardType(.decimalPad)
//                    .padding([.bottom],4)
//                    AuthTextField(floatingLabel: "Weight (lbs)".localized, placeholder: "Enter Weight".localized, icon: .menuProfile, text: $request.weight ,isIconDisplay : false,
//                                  custFontName : robotoMedium,
//                                  custFontSize : 14.0,
//                                  enteredText:  { quantity in
//                        request.weight = quantity
//                    })
//                    .keyboardType(.decimalPad)
//                    .padding([.bottom],4)
//                    DropDownSelection(
//                        options: $mailClassList, floatingLabel:"Mail Class",
//                        hint: "Select",
//                        selected: $request.mail_class,
//                        anchor: .bottom,
//                        custFontName: robotoMedium,
//                        custFontSize:  14.0,
//                        custCategory : robotoRegular,
//                        custCategorySize : 13.0,
//                        onOptionSelected: { value in
//                            selectedCategory = value
//                            //                                if let id = categoryList.first(where: { $0.name == value })?.id {
//                            //                                    request.mail_class = "\(id)"
//                            //                                } else {
//                            request.mail_class = value
//                            //                                }
//
//                        }
//                    )
//
//                    .padding([.leading,.trailing],16)
//                    DropDownSelection(
//                        options: $processingListArr, floatingLabel:"Processing Category",
//                        hint: "Select",
//                        selected: $request.processing_category,
//                        anchor: .top,
//                        custFontName: robotoMedium,
//                        custFontSize:  14.0,
//                        custCategory : robotoRegular,
//                        custCategorySize : 13.0,
//                        onOptionSelected: { value in
//                            selectedCategory = value
//                            //                                if let id = categoryList.first(where: { $0.name == value })?.id {
//                            request.processing_category = value
//                            //                                } else {
//                            //                                    request.processing_category = ""
//                            //                                }
//                        }
//                    )
//
//                    .padding([.leading,.trailing],16)
//
//                    let extraFields = self.extraFields
//                    if extraFields.count != 0{
//                        ForEach(0 ..< extraFields.count) { index in
//                            let field = extraFields[index]
//                            if let type = field.type {
//                                if type == "text" {
//                                    AuthTextField(
//                                        floatingLabel: field.label ?? "",
//                                        placeholder: "Enter \(field.label ?? "")",
//                                        icon: .menuProfile,
//                                        text: Binding(
//                                            get: { self.extraFieldValues[field.label ?? ""] ?? "" },
//                                            set: { self.extraFieldValues[field.label ?? ""] = $0 }
//                                        ),
//                                        isIconDisplay: false,
//                                        custFontName: robotoMedium,
//                                        custFontSize: 14.0,
//                                        enteredText: { text in
//                                            self.extraFieldValues[field.label ?? ""] = text
//                                        }
//                                    )
//                                    .padding(.bottom, 4)
//
//                                } else if type == "radio", let options = field.options {
//
//                                    VStack(alignment: .leading) {
//                                        Text(field.label?.capitalizingFirstLetter() ?? "")
//                                            .padding(.horizontal,1)
//                                            .font(.custom(robotoMedium, size: 14))
//
//                                        ForEach(options, id: \.self) { option in
//                                            HStack {
//                                                Image(systemName: selectedRadio[field.label ?? ""] == option ? "largecircle.fill.circle" : "circle")
//                                                    .foregroundColor(Color.defaultTheme)
//                                                Text(option)
//                                                    .font(.custom(robotoMedium, size: 14))
//                                            }
//                                            .onTapGesture {
//                                                selectedRadio[field.label ?? ""] = option
//                                            }
//                                            .padding(.vertical, 2)
//                                        }
//                                    }
//                                    .padding(.horizontal,16)
//                                    .padding(.bottom, 8)
//                                }
//                            }
//
//                        }
//                    }
//                }
//
//                .background(.white)
//                .cornerRadius(12)
//                .padding(.horizontal,12)
//
//
//
//                // Quantity Selector
//                HStack{
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text("Quantity Available")
//                            .font(.subheadline).bold()
//
//                        HStack(spacing: 12) {
//                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
//                                Image(systemName: "minus")
//                                    .padding()
//                                    .background(Color(.systemGray5))
//                                    .clipShape(Circle())
//                            }
//
//                            Text("\(quantity)")
//                                .font(.headline)
//                                .frame(width: 40)
//
//                            Button(action: { quantity += 1 }) {
//                                Image(systemName: "plus")
//                                    .padding()
//                                    .background(Color(.systemGray5))
//                                    .clipShape(Circle())
//                            }
//                        }
//                    }
//                    .padding(.horizontal)
//                    Spacer()
//                }
//
//                Spacer()
//
//                // Action Buttons
//                HStack(spacing: 12) {
//                    Button(action: {
//                        navigateToAddProduct = true
//                    }) {
//                        Text("Use Product Library")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .padding()
//                            .background(Color.defaultTheme)
//                            .foregroundColor(.white)
//                            .cornerRadius(12)
//                    }
//
//                    Button(action: {
//                        navigateToSalesFormat = true
//                    }) {
//                        Text("Continue")
//                            .font(.headline)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .padding()
//                            .background(.gray)
//                            .foregroundColor(.black)
//                            .cornerRadius(12)
//                    }
//                    .disabled(true)
//                }
//                .padding(.horizontal)
//                //                .padding(.bottom, 16)
//            }
//            .edgesIgnoringSafeArea(.all)
//            .bottomSheet(
//                isPresented: $showSubCategorySheet,
//                height: selectedOption.count < 4 ? screenHeight * 0.5 : screenHeight/1.7,
//                topBarCornerRadius: 25,
//                showTopIndicator: false,
//                onDismiss: {
//                    showSubCategorySheet = true
//                },
//                content: {
//                    SelectionBottomSheet(
//                        title: "Select Sub-Category",
//                        message: "Please select Sub-category.",
//                        options: $subCategoryName,
//                        selectedOptions: $selectedOption,
//                        onSelectionDone: { selectedIndexes in
//                            if let index = selectedIndexes.first {
//                                let selectedValue = subCategoryList[index]
//                                selectedSubCategory = selectedValue.name ?? ""
//                                request.sub_category_id = "\(selectedValue.id ?? 0)"
//                                selectedCategory = "\(selectedCategory) (\(selectedValue.name ?? ""))"
//                                print("Selected SubCategory: \(selectedValue.name ?? "")")
//                                self.extraFields = selectedValue.extra_fields ?? []
//                                //                                    if let extraFields =  self.viewModel.categoryResponse?.data[index].extra_fields{
//                                //
//                                //                                    }
//                            }
//                            showSubCategorySheet = false
//                        }
//                    )
//                }
//            )
//
//            CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
//            CusNavLink(doNavigate: $navigateToSalesFormat, destination: SalesFormatScreen())
//        }
//        .background(Color.bg.opacity(0.4).ignoresSafeArea())
//    }
//}
//

import SwiftUI
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

struct CreateProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var categorySelect : String = ""
    @State var categoyList = [String]()
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
    @State var quantity: Int = 1
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "2", status: "",sub_category_id: "",width: "",length: "", weight: "",height:"",mail_class:"",processing_category:"")
    
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
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView(uploadedImageUrls: $imageUrls)
                    
                    VStack(alignment:.leading,spacing: 8){
                        
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
                                selectedCategory = value
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
                                selectedCategory = value
//                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.processing_category = value
//                                } else {
//                                    request.processing_category = ""
//                                }
                            }
                        )
                       
                        .padding([.leading,.trailing],16)
                        
                        // Quantity Selector
                        HStack(spacing: 12) {
                            Button(action: {
                                if quantity > 1 {
                                    quantity -= 1
                                    request.quantity = "\(quantity)"   // keep request in sync
                                }
                            }) {
                                Image(systemName: "minus")
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(width: 40)
                            
                            Button(action: {
                                quantity += 1
                                request.quantity = "\(quantity)"
                            }) {
                                Image(systemName: "plus")
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
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

                    TwoButton(titleOne: "Continue", titleTwo: "Use Product Library", onFirstButtonClick: {
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
                        navigateToSalesFormat = true
//                        }
                        
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
                    }, onSecButtonClick: {
                        navigateToAddProduct = true
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
//            }
//            .padding([.leading,.trailing],12)
        }
        CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$requests,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
        CusNavLink(doNavigate: $navigateToSalesFormat, destination: SalesFormatScreen(request: $request))
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
                shippingAddressSuccess()
                await viewModel.getMailClasses()
                await SVProgressHUD.dismiss()
                mailSuccess()
                
                
            
            }
        })
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
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
            
            
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
                        icon: .alert,
                        title: response?.error_type?.capitalized ?? "",
                        message: response?.message?.capitalized ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                
            
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

            for field in extraFields {
                guard let title = field.label, let type = field.type else { continue }

                if type == "text" {
                    // Handle text input
                    let value = extraFieldValues[title] ?? ""
                    variantArray.append([
                        "title": title,
                        "value": value
                    ])
                } else if type == "radio", let options = field.options {
                    // Handle radio input
                    let selected = selectedRadio[title] ?? ""
                    
                    // Find which option key is selected (e.g. option_1 or option_2)
                    var selectedKey: String = ""
                    var valueDict: [String: String] = [:]

                    for (index, option) in options.enumerated() {
                        let key = "option_\(index + 1)"
                        valueDict[key] = option

                        if option == selected {
                            selectedKey = option
                        }
                    }

                    valueDict["selected"] = selectedKey

                    variantArray.append([
                        "title": title,
                        "value": valueDict
                    ])
                }
            }

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
   
}

//#Preview {
//    ListProductScreen()
//}
//
