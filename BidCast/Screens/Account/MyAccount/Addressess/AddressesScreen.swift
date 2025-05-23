//
//  AddressesScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 21/05/25.
//

import SwiftUI
import AlertToast

struct Address: Identifiable {
    let id = UUID()
    var type: String
    var name: String
    var house: String
    var country: String
    var mobile: String
}

struct AddressesScreen: View {

    let sampleAddresses: [Address] = [
        Address(type: "Home", name: "John Doe", house: "1234 Elm Street", country: "USA", mobile: "+1 555 111 2222"),
        Address(type: "Work", name: "Jane Smith", house: "456 Office Blvd", country: "Canada", mobile: "+1 555 333 4444")
    ]

    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")

    var body: some View {
        VStack(spacing: 0) {
            // Top Header
            PrimaryHeader(
                title: "My Addresses",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [.icAdd],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .shadow(radius: 2)

            // Address list with space for bottom button
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(sampleAddresses) { address in
                        AddressListCell(address: address)
                    }
                }
                .padding(.top, 16)
                .padding(.bottom, 80)
            }
            .background(Color(.systemGroupedBackground))

            //Bottom fixed button
            PrimaryButton(
                title: "Add New Address",
                isOutLine: false,
                onButtonClick: {
                    print("Add New Address tapped")
                },
                width: screenWidth - 45,
                cornerRadius: 25.0, imageName: "plus_btn",
                btnTextColor : .white, btnColor: .white
            )
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(radius: 3)
            .padding(.all)
        }
        .edgesIgnoringSafeArea(.bottom)
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
}

#Preview {
    AddressesScreen()
}
