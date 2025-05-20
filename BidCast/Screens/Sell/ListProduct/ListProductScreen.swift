//
//  ListProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import SwiftUI
import SwiftfulLoadingIndicators

struct ListProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isLoading : Bool = false
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
    
    @State private var categoryNames: [String] = []
    @State private var selectedCategory = ""
    @State private var categoryList: [CategoryDataModel] = []
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var request : StoreProductParam = StoreProductParam(category_id: "", title: "", description: "", quantity: "", pricing: "", flash_sale: "0", accept_offers: "0", reserve_for_live: "0", shipping_profile_id: "", status: "")
    
    var viewModel = ListProductViewModel()
    
    var body: some View {
        
        ZStack {
            VStack{
                VStack(spacing: 0, content: {
                    PrimaryHeader(
                        title: "List a Product".localized,
                        isForLogo : false, leadingImgArr: [.sideArrow],
                        trailingImgArr: [],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                })
                
                
                ScrollView(showsIndicators:false){
                    
                    MediaPickerView()
                    
                    VStack(alignment:.leading,spacing: 8){
                        Text("Product Details".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        DropDownSelection(
                            options: $categoryNames, floatingLabel:"Category",
                            hint: "Select Category",
                            selected: $categorySelect,
                            anchor: .bottom,
                            onOptionSelected: { value in
                                if let id = categoryList.first(where: { $0.name == value })?.id {
                                    request.category_id = "\(id)"
                                } else {
                                    request.category_id = ""
                                }
                            }
                        )
                        .zIndex(1201.0)
                        .padding([.leading,.trailing],8)
                        
                        AuthTextField(floatingLabel: "Title".localized, placeholder: "Enter Product title".localized, icon: .menuProfile, text: $request.title ,isIconDisplay : false) { email in
                            request.title = email
                        }
                        .keyboardType(.alphabet)
                        .padding([.leading,.trailing],4)
                        
                        DescriptionFieldView(){ message in
                            request.description = message
                        }
                        AuthTextField(floatingLabel: "Quantity".localized, placeholder: "Enter Quantity".localized, icon: .menuProfile, text: $request.quantity ,isIconDisplay : false) { email in
                            request.quantity = email
                        }
                        .keyboardType(.numberPad)
                        .padding([.leading,.trailing],6)
                        
                        
                        PrimaryButton(title: "Add Variants", isOutLine: false, onButtonClick: {
                            print("hell")
                        },width: screenWidth - 45, imageName: "plus_btn", btnColor: .white)
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    VStack(alignment:.leading,spacing: 12){
                        Text("Pricing".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        AuthTextField(floatingLabel: "Buy it Now Price".localized, placeholder: "0.00".localized, icon: .menuProfile, text: $request.pricing ,isIconDisplay : true) { email in
                            request.pricing = email
                        }
                        //                    .textContentType(.username)
                        .keyboardType(.alphabet)
                        .padding([.leading,.trailing],4)
                        
                        MenuCell( title: "Flash Sale",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedFlash,onToggle: { value in
                            if value == true{
                                request.flash_sale = "1"
                            }else{
                                request.flash_sale = "0"
                            }
                        })
                        MenuCell( title: "Accept offers",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedAccept,onToggle: { value in
                            print(value)
                            if value == true{
                                request.accept_offers = "1"
                            }else{
                                request.accept_offers = "0"
                            }
                        })
                        MenuCell( title: "Reserve for Live",fontValue: 18.0,menuImg: "",isSelectable: true, isTappedSwitch: $isTappedReserve,onToggle: { value in
                            print(value)
                            if value == true{
                                request.reserve_for_live = "1"
                            }else{
                                request.reserve_for_live = "0"
                            }
                        })
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    VStack(alignment:.leading,spacing: 12){
                        Text("Shipping".localized)
                            .font(.headline)
                            .padding(.top,8)
                            .padding([.leading,.trailing],8)
                        
                        DropDownSelection(
                            options: $categoyList,
                            floatingLabel:"Shipping Profile",
                            hint: "Select Profile",
                            selected: $categorySelect,
                            anchor: .top
                        )
                        .onChange(of: categorySelect) { newValue in
                            request.shipping_profile_id = "\(UserDefaults.userId)"
                        }
                        .padding(.bottom,8)
                        .padding([.leading,.trailing],8)
                        
                    }
                    
                    .background(.white)
                    .cornerRadius(12)
                    .padding(.all,12)
                    
                    TwoButton(titleOne: "Save Draft", titleTwo: "Publish", onFirstButtonClick: {
                        print(request)
                    }, onSecButtonClick: {
                        print(request)
                    }, height: 45, firstBtnTitleColor: .darkGray, secBtnTitleColor: .white, firstBtnBgColor: .white, secBtnBgColor:.darkBlue)

                }
                .edgesIgnoringSafeArea(.top)
                .padding(.all,12)
                .background(.bg.opacity(0.5))
                .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showError = true }, content: {
                    CommonBottomSheet(
                        sheetType: $alertType,
                        onPrimaryClick: {
                            withAnimation { showError = false }
                        }, onSecondaryClick: {
                            withAnimation { showError = false }
                        })
                })
                
                if isLoading {
                    LoadingIndicator()
                }
                
            }
//            .padding([.leading,.trailing],12)
        }
        .edgesIgnoringSafeArea(.top)
        .background(.bg.opacity(0.5))
        .onFirstAppear(perform: {
            self.isLoading = true
            viewModel.getCategoryList()
        })
        .onAppear(perform: {
            observe()
        })
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                categorySuccess()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: msg, primaryBtnText: "", secondaryBtnText: AppString.ok.localized)
                showError = true
            }
        }
    }

    func categorySuccess() {
        if viewModel.request == "Category" {
            if let response = viewModel.categoryDict {
                if response.status == "success" {
                    self.categoryList = response.data
                    self.categoryNames = response.data.map { $0.name ?? "No Category" }
                    
                } else {
                    alertType = .sheetType(
                        icon: .alert,
                        title: response.error_type?.capitalized ?? "",
                        message: response.message?.capitalized ?? "",
                        primaryBtnText: "",
                        secondaryBtnText: AppString.ok.localized
                    )
                    showError = true
                }
            }
        }
    }
}

#Preview {
    ListProductScreen()
}




//
//struct TwoPrimaryButtonsRow: View {
//    var btn1Title : String = "Save Draft"
//    var btn2Title : String = "Publish"
//    var btn1Color  : Color = .gray
//    var body: some View {
//        HStack(spacing: 12) {
//            
//            Button(action: {
//                print("Add Variants tapped")
//            }) {
//                Text(btn1Title)
//                    .fontWeight(.bold)
//            }
//            .padding(.vertical, 12)
//            .frame(maxWidth: .infinity)
//            .background(
//                RoundedRectangle(cornerRadius: 8)
//                    .stroke(btn1Color, lineWidth: 2)
//            )
//            
//            .foregroundColor(btn1Color)
//            
//            // Filled “Save”
//            Button(action: {
//                print("Save tapped")
//            }) {
//                Text(btn2Title)
//                    .fontWeight(.bold)
//                    .padding(.vertical, 12)
//                    .frame(maxWidth: .infinity)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.blue)
//                    )
//            }
//            .foregroundColor(.white)
//        }
//        .padding(.horizontal, 16)
//        .shadow(color: .gray.opacity(0.25), radius: 2, x: 0, y: 0)
//    }
//}
//
//#Preview {
//    TwoPrimaryButtonsRow()
//}
