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
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var selectedType = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var request : AddressRequest = AddressRequest(type: "", name: "", phone_number: "", street_address: "", pincode: "")
    
    @State var viewModel = AddressViewModel()
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
//            PrimaryHeader(
//                title: "Create New Addresses",
//                isForLogo: false,
//                leadingImgArr: [.icBack],
//               
//                onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                },
//                count: .constant(0)
//            )
//            .frame(height: 50)
//            .background(Color.white)
            VStack{
                PrimaryHeader(
                    title: "Create New Address",
                    isForLogo: false,
                    leadingImgArr: [.icBack],
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
                         DropDownSelection(
                            options: $addressType, floatingLabel:"Type",
                            hint: "Select Type",
                            selected: $selectedType,
                            anchor: .bottom,
                            onOptionSelected: { value in
                                request.type = value
                                self.selectedType = value
                            }
                        )
                        .zIndex(1201.0)
//                        .padding([.leading,.trailing],8)
                        
                        AuthTextField(
                            floatingLabel: "Name",
                            placeholder: "Enter name",
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
                    }
//                    .padding(.horizontal, 16)
                }
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
//            .padding(.horizontal,Leading/2)
            .background(Color(.systemGroupedBackground))

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
                       }
                    }else{
                        
                        withAnimation {
                            showError = false
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
   

    func success() {
        let response = viewModel.addressResponse
        if response.status == "success" {
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

#Preview {
    AddressesScreen()
}
