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
//                        .textContentType(.name)

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
//                        .textContentType(.telephoneNumber)
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
                        // MC sub-task cmp4932vk00l13mx1du6mmebo: optional 2nd line.
                        AuthTextField(
                            floatingLabel: "Apt / Suite / Unit (optional)",
                            placeholder: "e.g. Apt 4B",
                            icon: .icMail,
                            text: Binding(
                                get: { request.address_line_2 ?? "" },
                                set: { request.address_line_2 = $0 }
                            ),
                            isIconDisplay : false,
                            enteredText: {
                                request.address_line_2 = $0
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
                            floatingLabel: "Zip code",
                            placeholder: "Enter zip code",
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
                            hudMsg = "Please enter Zip code"
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
                                // MC cmpfoke6n0013oohgg2x74cdg (2026-05-22):
                                // use the .alert icon on failure (was
                                // mistakenly .success).
                                // MC cmpfokeio0017oohg96ywquzc (Trey 2026-05-21):
                                // Backend was leaking raw USPS OAuth error JSON
                                // ("Failed to get USPS access token: {...}") into
                                // this user-facing alert. Friendly-ize it before
                                // display.
                                let (sanitizedTitle, sanitizedMessage) = friendlyAddressError(
                                    rawTitle: "Failed",
                                    rawMessage: self.viewModel.errorMessage
                                )
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: sanitizedTitle,
                                    message: sanitizedMessage,
                                    primaryBtnText: AppString.ok.localized,
                                    secondaryBtnText: ""
                                )
                                showError = true
                            }
                        }
                    }
                },
            )
            .padding(.vertical, 12)
            .background(Color.white)
//            .padding(.all)
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        // MC cmpfoke6n0013oohgg2x74cdg (2026-05-22): the onDismiss
        // handler used to set `showError = true` when errorMessage was
        // nil, which caused the bottom sheet to re-present itself
        // immediately after a successful close. On some iOS versions
        // that re-presentation collides with the parent screen's own
        // dismiss (`presentationMode.wrappedValue.dismiss()` called from
        // `onPrimaryClick`), leaving the presentation stack in a state
        // where SwiftUI thinks two view controllers are dismissing at
        // the same root, which can manifest as a UI hang or a hard
        // kick to whichever root the AppRootManager last published. We
        // simply collapse onDismiss to clear the flag; the success path
        // is now driven only by `onPrimaryClick`.
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.5,
            topBarCornerRadius: 25,
            showTopIndicator: false,
            onDismiss: {
                showError = false
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
                    // MC cmpfoke6n0013oohgg2x74cdg (2026-05-22): use the
                    // .alert icon when state-load fails (was .success).
                    // MC cmpfokeio0017oohg96ywquzc (Trey 2026-05-21): sanitize
                    // server error before showing it on the address screen.
                    let (sanitizedTitle, sanitizedMessage) = friendlyAddressError(
                        rawTitle: "Failed",
                        rawMessage: viewModel.errorMessage
                    )
                    alertType = .sheetType(
                        icon: .alert,
                        title: sanitizedTitle,
                        message: sanitizedMessage,
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
            // MC cmpfokeio0017oohg96ywquzc (Trey 2026-05-21): the backend's
            // /storeAddress can return a 200 envelope whose `message` field
            // contains a raw USPS OAuth error dump ("Failed to get USPS
            // access token: {\"error\":\"invalid_client\", ...}"). That used
            // to be shown to the user verbatim. Run the message through the
            // friendly-error helper so what ends up on screen is clean copy.
            let (sanitizedTitle, sanitizedMessage) = friendlyAddressError(
                rawTitle: response.error_type?.capitalized,
                rawMessage: response.message
            )
            alertType = .sheetType(
                icon: .alert,
                title: sanitizedTitle,
                message: sanitizedMessage,
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
        showError = true
    }

    /// MC cmpfokeio0017oohg96ywquzc (Trey 2026-05-21): convert a possibly-raw
    /// server error payload into something safe to show end users.
    ///
    /// The Bidcast backend's address-store endpoint surfaces upstream USPS
    /// OAuth failures by stuffing the raw OAuth error body into the response
    /// envelope's `message`, prefixed with "Failed to get USPS access token:".
    /// That ended up on a user-facing modal verbatim, including the JSON dump
    /// and an RFC 6749 link.
    ///
    /// This helper detects messages that look like that leak (or any other
    /// raw JSON / OAuth-shaped payload) and substitutes a clean user-facing
    /// message. The raw message is preserved in the dev console via print()
    /// for debugging.
    private func friendlyAddressError(
        rawTitle: String?,
        rawMessage: String?
    ) -> (title: String, message: String) {
        let raw = (rawMessage ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = raw.lowercased()

        // Patterns we want to suppress from the UI (case-insensitive).
        let leakedPatterns: [String] = [
            "failed to get usps access token",
            "invalid_client",
            "error_description",
            "error_uri",
            "rfc6749",
            "rfc 6749",
            "apis.usps.com",
            "client authentication failed"
        ]
        let containsLeakedPattern = leakedPatterns.contains { lowered.contains($0) }

        // Looks like a raw JSON blob if it starts with { or [ and contains a colon.
        let looksLikeJSON: Bool = {
            guard let first = raw.first else { return false }
            return (first == "{" || first == "[") && raw.contains(":")
        }()

        if containsLeakedPattern || looksLikeJSON {
            print("⚠️ Suppressed raw address-verification error in UI: \(raw)")
            return (
                title: "Address verification unavailable",
                message: "We couldn't verify your address right now. Please double-check your address and try again. If this keeps happening, contact support."
            )
        }

        let safeTitle = (rawTitle?.isEmpty == false ? rawTitle! : "Failed")
        let safeMessage = raw.isEmpty
            ? "Something went wrong. Please try again."
            : raw
        return (title: safeTitle, message: safeMessage)
    }
}



