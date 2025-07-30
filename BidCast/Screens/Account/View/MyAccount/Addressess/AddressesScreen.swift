//
//  AddressesScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD



struct AddressesScreen: View {
    
    @State var sampleAddresses = [AddressModel]()
    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var navigateToCreate = false
    @State var isDefault = false
    var viewModel = AddressViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            VStack{
                PrimaryHeader(
                    title: "My Addresses",
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            // Address list with space for bottom button
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    if sampleAddresses.count != 0{
                        ForEach(sampleAddresses, id: \.id) { address in
                            //                        let address = sampleAddresses[index]
                            AddressListCell(address: address,onTapDefault: {
                                //                            print("indexx \(index)")
                                Task{
                                    guard Reachability.isConnectedToNetwork() else {
                                        hudMsg = "No Internet Connection"
                                        showhud = true
                                        return
                                    }
                                    SVProgressHUD.show()
                                    await self.viewModel.setDefaultAddress(parameters: AddressDefaultParam(address_id: "\(address.id ?? 0)"))
                                }
                            },onTapDelete: {
                                Task{
                                    guard Reachability.isConnectedToNetwork() else {
                                        hudMsg = "No Internet Connection"
                                        showhud = true
                                        return
                                    }
                                    SVProgressHUD.show()
                                    await self.viewModel.deleteAddress(parameters: AddressDefaultParam(address_id:"\(address.id ?? 0)"))
                                }
                            }, isDefault: address.is_default ?? false)
                        }
                    }else{
                        NoDataView(message: "No Address found")
                    }
                }
                .padding(.vertical, 16)
                .padding(.horizontal,2)
//                .padding(.bottom, 40)
            }
            .padding(.horizontal,Leading/2)
            .background(.bg.opacity(0.4))
            
            //Bottom fixed button
            PrimaryButton(
                title: "Add New Address",
                isOutLine: true,
                onButtonClick: {
                    print("Add New Address tapped")
                    navigateToCreate = true
                },
                width: screenWidth - 45,
                cornerRadius: 12.0, imageName: "plus_btn",
                btnTextColor : .white, btnColor: .defaultTheme
            )
            //            .padding(.vertical, 10)
            .background(Color.white)
            .padding(.all,8)
            .padding(.bottom,-24)
            CusNavLink(doNavigate: $navigateToCreate, destination: CreateAddress())
        }
        .toolbar(.hidden, for: .tabBar)
        .onAppear{
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await self.viewModel.getAddresses()
                await SVProgressHUD.dismiss()
                AddressesSuccess()
            }
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
    
    
    func AddressesSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.addressesResponse
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
        
    }

    func AddressSuccess(){
        SVProgressHUD.dismiss()
    let response = viewModel.addressResponse
            if response.status == "success" {
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                   await self.viewModel.getAddresses()
                }
               
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

//#Preview {
//    AddressesScreen()
//}
