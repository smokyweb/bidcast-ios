//
//  FAQScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct ContactUs: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showError: Bool = false
    @State var isLoading: Bool = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""

    var imageName = ["tagBorder", "streamBorder", "sellerBorder"]
    var tabName = ["List a Product", "Scheduled a show", "Seller Hub"]
    var subLabel = ["Create a listing for your item", "Go live and sell to your audience", "Manage your store and listings"]

    @State var request: ContactUsRequest = ContactUsRequest(name: "", email: "", subject: "", message: "")
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    var viewModel = ContactUsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                PrimaryHeader(
                    title: "Contact Us",
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .frame(height: 50)
                .background(Color.red)
                .shadow(radius: 2)

                // Scrollable Form
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        // Intro Text
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppString.getInTouch.localized)
                                .font(.custom(nunitoBlack, fixedSize: 18))
                                .bold()

                            Text(AppString.weAreHereToHelp.localized)
                                .font(.custom(nunitoBlack, fixedSize: 18))
                        }
                        .padding()
                        .background(Color.platinum)
                        .cornerRadius(12)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Form Fields
                        Group{
                            AuthTextField(
                                floatingLabel: AppString.fullName.localized,
                                placeholder: AppString.enterFullName.localized,
                                icon: .icMail,
                                text: $request.name,
                                enteredText: { request.name = $0 }
                            )
                            .textContentType(.name)

                            AuthTextField(
                                floatingLabel: AppString.email.localized,
                                placeholder: AppString.enterEmail.localized,
                                icon: .icMail,
                                text: $request.email,
                                enteredText: { request.email = $0 }
                            )
                            .textContentType(.emailAddress)

                            AuthTextField(
                                floatingLabel: AppString.subject.localized,
                                placeholder: AppString.enterSubject.localized,
                                icon: .icMail,
                                text: $request.subject,
                                enteredText: { request.subject = $0 }
                            )

                            AuthTextField(
                                floatingLabel: AppString.message.localized,
                                placeholder: AppString.enterYourMessage.localized,
                                icon: .icMail,
                                text: $request.message,
                                enteredText: { request.message = $0 }
                            )
                        }
                        .padding(.horizontal, 16)

                        // List Section
                        VStack(spacing: 16) {
                            ForEach(0..<tabName.count, id: \.self) { ind in
                                ListCell(
                                    image: imageName[ind],
                                    title: tabName[ind],
                                    subLabel: subLabel[ind],
                                    isVectorImgHidden: true
                                )
//                                .padding(.horizontal)
                            }
                        }

                        Spacer().frame(height: 80) // Space for button
                    }
                }
                .background(Color.pearl)
            }

            // Bottom Fixed Button
            VStack(spacing: 0) {
                PrimaryButton(title: AppString.sendMessage.localized, isOutLine: false) {
                    withAnimation {
                        UIApplication.shared.endEditing()
                        guard !request.name.isEmpty else {
                            hudMsg = "Please enter your name"
                                showhud = true
                                return
                            }
                        guard !request.email.isEmpty else {
                            hudMsg = AppString.pleaseEnterEmail.localized
                            showhud = true
                            return
                        }
                        guard !request.subject.isEmpty else {
                            hudMsg = "Please enter subject"
                                showhud = true
                                return
                            }
                        guard !request.message.isEmpty else {
                            hudMsg = "Please enter your message"
                                showhud = true
                                return
                            }
                        Task{
                            SVProgressHUD.show()
                            await self.viewModel.contactUs(parameters: request)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color.white)
            .shadow(radius: 3)
           
        }
        .onReceive(viewModel.$contactModel){ response in
            SVProgressHUD.dismiss()
            self.success()
            
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    let response = viewModel.contactModel
                    if response.status == "success" {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }

    
    func success() {
        let response = viewModel.contactModel
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
    ContactUs()
}
