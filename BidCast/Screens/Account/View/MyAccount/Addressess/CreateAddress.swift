//
//  AddressesScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD


struct CreateAddress: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var addressType : [String] = ["Home","Office","Other"]
    
    @State var stateArr : [String] = [""]
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var selectedType = ""
    @State var selectedState = ""
    @State var country = "Unites States"
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var request : AddressRequest = AddressRequest(type: "", name: "", phone_number: "", street_address: "", pincode: "",city: "",state: "")
    
    @State var viewModel = AddressViewModel()
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            VStack{
                PrimaryHeader(
                    title: "Create New Address",
                    isForLogo: false,
                    leadingImgArr: ["chevron.left"],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                        // maybe open menu or do nothing
                    },
                    onClickTrailing: nil,
                    count: .constant(0)
                )
               
            }

            // Address list with space for bottom button
            ScrollView {
                VStack(spacing: 16) {
                    Group{
                        RadioButtonGroup(
                            options: addressType,
                            selected: $selectedType,
                            onSelect: { value in
                                request.type = value
                            }
                        )
//                        .padding([.leading,.trailing],8)
                        
                        AuthTextField(
                            floatingLabel: "Full Name",
                            placeholder: "Enter full name",
                            icon: .icMail,
                            text: $request.name,
                            isIconDisplay : false,
                            enteredText: {
                                request.name = $0
                            }
                        )
                        .textContentType(.name)

                        AuthTextField(
                            floatingLabel: "Phone Number",
                            placeholder: "Enter phone number",
                            icon: .phone,
                            text: $request.phone_number,
                            isIconDisplay : false,
                            enteredText: {
                                request.phone_number = $0
                            }
                        )
                        .textContentType(.telephoneNumber)
                        .keyboardType(.numberPad)

                        AuthTextField(
                            floatingLabel: "Street Address",
                            placeholder: "Enter street address",
                            icon: .icMail,
                            text: $request.street_address,
                            isIconDisplay : false,
                            enteredText: {
                                request.street_address = $0
                            }
                        )
                        AuthTextField(
                            floatingLabel: "City",
                            placeholder: "Enter city",
                            icon: .icMail,
                            text: $request.city,
                            isIconDisplay : false,
                            enteredText: {
                                request.city = $0
                            }
                        )
//                        DropDownSelection(
//                            options: $stateArr, floatingLabel:"State",
//                           hint: "Select state",
//                            selected: $selectedState,
//                            anchor: .top,
//                           onOptionSelected: { value in
//                               if let iso = value.components(separatedBy: " - ").last {
//                                          request.state = iso
//                                      }
//                               self.selectedState = value
//                           }
//                       )
//                       .zIndex(1201.0)
                        
                        // Drop Down for Auction Type
                        DropDownTextField(
                            hint: "Select state",
                            floatingLabel: "State",
                            text: $selectedState,
                            options: $stateArr,
                            leadingIcon: .location,
                            showLeadingIcon: false,
                            showTrailingIcon: false,
                            showDropDownIcon: true,
                            onOptionSelected: { value in
                                if let iso = value.components(separatedBy: " - ").last {
                                           request.state = iso
                                       }
                                self.selectedState = value
                            },
                            anchor: .top
                        ).zIndex(1201.0)
                        
                        AuthTextField(
                            floatingLabel: "Pin code",
                            placeholder: "Enter pin code",
                            icon: .icMail,
                            text: $request.pincode,
                            isIconDisplay : false,
                            enteredText: {
                                request.pincode = $0
                            }
                        )
                        .keyboardType(.numberPad)
                        
                        AuthTextField(
                            floatingLabel: "Country",
                            placeholder: "Enter country",
                            icon: .icMail,
                            text: $country,
                            isIconDisplay : false,
                            enteredText: { _ in 
                               
                            }
                        )
                        .disabled(true)
                    }
//                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
//            .padding(.horizontal,Leading/2)
            .background(Color.bg.opacity(0.4))

            //Bottom fixed button
            PrimaryButton(
                title: "Submit",
                isOutLine: false,
                onButtonClick: {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        guard !request.type.isEmpty else {
                            hudMsg = "Please select address type"
                            showhud = true
                            return
                        }
                        
                        guard !request.name.isEmpty else {
                            hudMsg = "Please enter name of address"
                            showhud = true
                            return
                        }
                        
                        guard !request.phone_number.isEmpty else {
                            hudMsg = "Please enter phone number"
                            showhud = true
                            return
                        }
                        guard !request.street_address.isEmpty else {
                            hudMsg = "Please enter street address"
                            showhud = true
                            return
                        }
                        guard !request.pincode.isEmpty else {
                            hudMsg = "Please enter pin code"
                            showhud = true
                            return
                        }
                        let request = self.request
                        Task {
                            guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            await viewModel.storeAddress(parameters: request)
                            await SVProgressHUD.dismiss()
                            if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                                success()
                            }else{
                                alertType = .sheetType(
                                    icon: .success,
                                    title: "Failed",
                                    message: self.viewModel.errorMessage ?? "",
                                    primaryBtnText: AppString.ok.localized,
                                    secondaryBtnText: ""
                                )
                                showError = true
                            }
                        }
                    }
                },
                width: screenWidth - 45,
                cornerRadius: 12.0, imageName: "",
                btnTextColor : .black, btnColor: .white
            )
            .padding(.vertical, 10)
            .background(Color.white)
//            .padding(.all)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false,onDismiss:{
                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                    showError = true
                }else{
                    showError = false
                }
            }
        ){
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                   if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                       withAnimation {
                           showError = false
                           self.presentationMode.wrappedValue.dismiss()
                       }
                    }else{
                        
                        withAnimation {
                            showError = false
//                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
        .onFirstAppear {
            Task{
                SVProgressHUD.show()
                self.viewModel.errorMessage?.removeAll()
                await self.viewModel.getState()
                await SVProgressHUD.dismiss()
                if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil {
                    if let response = viewModel.stateResponse.data {
                        self.stateArr = response.map { "\($0.name ?? "") - \($0.iso2 ?? "")" }
                    }
                }else{
                    alertType = .sheetType(
                        icon: .success,
                        title: "Failed",
                        message: viewModel.errorMessage ?? "",
                        primaryBtnText: AppString.ok.localized,
                        secondaryBtnText: ""
                    )
                    withAnimation(.snappy){
                        showError = true
                    }
                }
            }
        }
    }
    
   

    func success() {
        let response = viewModel.addressResponse
        if response.status == "success" {
            UserDefaults.sellerAddress = true
            alertType = .sheetType(
                icon: .success,
                title: response.status?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
        showError = true
    }
}



