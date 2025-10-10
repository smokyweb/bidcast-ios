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
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var viewModel = ContactUsViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Header
                VStack{
                    PrimaryHeader(
                        title: "Contact Us",
                        isForLogo: false,
                        leadingImgArr: [.icBack],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 15) {
                        // Intro Text
                        VStack(alignment: .leading, spacing: 8) {
                            Text(AppString.getInTouch.localized)
                                .font(.custom(poppinsSemiBold, fixedSize: 16))
                                .bold()

                            Text(AppString.weAreHereToHelp.localized)
                                .font(.custom(poppinsSemiBold, fixedSize: 13))
                        }
                        .padding()
                        .background(Color.platinum)
                        .cornerRadius(12)
//                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                        // Form Fields
                        Group{
                            AuthTextField(
                                floatingLabel: AppString.fullName.localized,
                                placeholder: AppString.enterFullName.localized,
                                icon: .icUser,
                                text: $request.name,
                                isIconDisplay : true,
                                enteredText: { request.name = $0 }
                            )
                            .textContentType(.name)

                            AuthTextField(
                                floatingLabel: AppString.email.localized,
                                placeholder: UserDefaults.userEmail,
                                icon: .icMail,
                                text: .constant(UserDefaults.userEmail),
                                isIconDisplay : true,
                                enteredText: {_ in 
                                    request.email = UserDefaults.userEmail
                                }
                            )
                            .disabled(true)
                            .textContentType(.emailAddress)

                            AuthTextField(
                                floatingLabel: AppString.subject.localized,
                                placeholder: AppString.enterSubject.localized,
                                icon: .icMail,
                                text: $request.subject,
                                isIconDisplay : true,
                                enteredText: { request.subject = $0 }
                            )

//                            AuthTextField(
//                                floatingLabel: AppString.message.localized,
//                                placeholder: AppString.enterYourMessage.localized,
//                                icon: .icMail,
//                                text: $request.message,
//                                isIconDisplay : false,
//                                isForDescription: true,
//                                enteredText: { request.message = $0 }
//                            )
                            
                        }

                        VStack(spacing: 16) {
                            DescriptionFieldView(
                                description:$request.message,
                                title:AppString.message.localized,
                                placeholder:AppString.enterYourMessage.localized,
                                custFontName : robotoMedium,
                                custFontSize : 14.0
                                )
                            { message in
                                request.message = message
                            }
//                            ListCell(image:"mail",title:"Email",subLabel: "support@company.com",isVectorImgHidden: true,imgSize: 24)
//                                .padding(.horizontal)
                        }

                        Spacer().frame(height: 80) // Space for button
                    }
                }
                .background(Color.pearl)
            }

            // Bottom Fixed Button
            VStack(spacing: 0) {
                PrimaryButton(title: AppString.sendMessage.localized, isOutLine: true) {
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
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                                                
                            SVProgressHUD.show()
                            await self.viewModel.contactUs(parameters: request)
                            await SVProgressHUD.dismiss()
                            self.success()
                        }
                    }
                }
            }
            .background(Color.white)
            .shadow(radius: 3)
           
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
