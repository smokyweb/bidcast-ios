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
                        leadingImgArr: ["chevron.left"],
                        onClickLeading: { _ in
                            self.presentationMode.wrappedValue.dismiss()
                        },
                        count: .constant(0)
                    )
                }
                .frame(height: 40)
                .background(Color.white)

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
                        .background(Color.defaultThemeLight)
                        .cornerRadius(12)
//                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.horizontal, 16)

                        // Form Fields
                        Group{
                            AuthTextField(
                                floatingLabel: AppString.fullName.localized,
                                placeholder: AppString.enterFullName.localized,
                                icon: .icUser,
                                text: $request.name,
                                isIconDisplay : false,
                                enteredText: { request.name = $0 }
                            )
                            .textContentType(.name)

                            AuthTextField(
                                floatingLabel: AppString.email.localized,
                                placeholder: UserDefaults.userEmail,
                                icon: .icMail,
                                text: .constant(UserDefaults.userEmail),
                                isIconDisplay : false,
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
                                isIconDisplay : false,
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
                        
                        EmailSupportView()
                            .padding(.horizontal, 16)
//                            .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 0)

                        Spacer().frame(height: 80) // Space for button
                    }
                }
                .padding()
                .background(.backGround)
            }

            // Bottom Fixed Button
            VStack(alignment: .center, spacing: 0) {
                PrimaryButton(title: AppString.sendMessage.localized, isOutLine: false, onButtonClick: {
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
                },cornerRadius : 32, btnTextColor: .white)
            }
            .padding(.horizontal,16)
            .padding(.bottom,8)
            .background(.backGround)
            .shadow(radius: 3)
           
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false,onDismiss: {
            showError = true
        }) {
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
        .onAppear() {
            request.email = UserDefaults.userEmail
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
//#Preview {
//    ContactUs()
//}
