//
//  AddressesScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//

import SwiftUI
import AlertToast



struct AddressesScreen: View {

    @State var sampleAddresses = [AddressModel]()
    

    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var navigateToCreate = false
    @State var isDefault = false
    var viewModel = AddressViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            PrimaryHeader(
                title: "My Addresses",
                isForLogo: false,
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)

            // Address list with space for bottom button
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(sampleAddresses.indices, id: \.self) { index in
                        let address = sampleAddresses[index]
                        AddressListCell(address: address,onTapDefault: {
                            print("indexx \(index)")
                            self.viewModel.setDefaultAddress(parameters: AddressDefaultParam(address_id: "\(sampleAddresses[index].id ?? 0)"))
                        },isDefault: address.is_default ?? false)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .padding(.horizontal,Leading/2)
            .background(Color(.systemGroupedBackground))

            //Bottom fixed button
            PrimaryButton(
                title: "Add New Address",
                isOutLine: false,
                onButtonClick: {
                    print("Add New Address tapped")
                    navigateToCreate = true
                },
                width: screenWidth - 45,
                cornerRadius: 25.0, imageName: "plus_btn",
                btnTextColor : .black, btnColor: .white
            )
//            .padding(.vertical, 10)
            .background(Color.white)
            .padding(.all)
            .padding(.bottom,-24)
            CusNavLink(doNavigate: $navigateToCreate, destination: CreateAddress())
        }
        .onAppear{
            observe()
            self.viewModel.getAddresses()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ){
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
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
                success()
            case .error(let error):
                let msg = error?.localizedDescription ?? AppString.error.localized
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: msg, primaryBtnText: "", secondaryBtnText: AppString.ok.localized)
                showError = true
            }
        }
    }

    func success() {
        if self.viewModel.requestType == "get"{
            let response = viewModel.getAddressDict
            if response.status == "success" {
                sampleAddresses = response.data ?? [AddressModel]()
                
            } else {
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
            
        }else{
            let response = viewModel.addressDict
            if response.status == "success" {
                self.viewModel.getAddresses()
            } else {
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
           
        }
    }
    
}

//#Preview {
//    AddressesScreen()
//}
