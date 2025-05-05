////
////  ContactUsScreen.swift
////  imperium
////
////  Created by Abdul-JAM-E-157 on 20/01/24.
////
//
//import SwiftUI
//import AlertToast
//import BottomSheet
//
//struct ContactUsScreen: View {
//    
//        //MARK: Static Properties
//    @Environment(\.presentationMode) var presentationMode
//    @State var isLoading: Bool = false
//    @State var showAlert: Bool = false
//    @State var navigateToMenu: Bool = false
//    @State var navigateToNotification: Bool = false
//    @State var notiCount: Int = 0
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    
//    @State var showHud: Bool = false
//    @State var hudMsg: String = ""
//    
//    @State var request: ContactModelParam = ContactModelParam(email: "", phone: "", message: "")
//    
//        //MARK: Properties
//    var contactUsViewModel = ContactUsViewModel()
//    
//        //MARK: Primary View
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0, content: {
//                PrimaryHeader(title: "Contact Us", leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                }, onClickTrailing: { ind in
//                    switch ind {
//                        case 1:
//                            navigateToMenu = true
//                        default:
//                            navigateToNotification = true
//                    }
//                }, showAppIcon: true, count: $notiCount)
//                
//                VStack(alignment: .leading) {
//                    
//                    TitleWithLine(title: "Contact Us", lineLength: 36)
//                        .padding([.top, .horizontal])
//                    
//                    ScrollView(showsIndicators: false){
//                        VStack(spacing: 16, content: {
//                            AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: $request.email) { email in
//                                request.email = email
//                            }.textContentType(.emailAddress)
//                            
//                            AuthTextField(floatingLabel: "Phone", placeholder: "Enter Phone", icon: .phone, text: $request.phone) { password in
//                                request.phone = password
//                            }
//                            .textContentType(.telephoneNumber)
//                            .keyboardType(.numberPad)
//                            
//                            MultilineTextField(floatingLabel: "Message", placeholder: "Enter your message here...", text: $request.message) { message in
//                                request.message = message
//                            }.textContentType(.jobTitle)
//                            
//                            PrimaryButton(title: "Submit") {
//                                validate()
//                            }
//                        }).padding([.horizontal, .vertical])
//                    }
//                    Spacer()
//                }
//                .background(.text.opacity(0.05))
//                .padding(.top, -topPadding)
//                
//                Spacer()
//            })
//            .onAppear(perform: {
//                observe()
//            })
//            .onTapGesture {
//                UIApplication.shared.endEditing()}
//            .toast(isPresenting: $showHud) {
//                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
//                CommonBottomSheet(
//                    sheetType: $alertType,
//                    onPrimaryClick: {
//                        withAnimation { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    }, onSecondaryClick: {
//                        withAnimation { showAlert = false }
//                    })
//            })
//            
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//            
//            CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())
//
//            .fullScreenCover(isPresented: $navigateToMenu, content: {
//                NavigationContainer {
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role != "employer" {
//                            UserHomeScreen()
//                        }else{
//                            EmployerHomeScreen()
//                        }
//                    }
//                   
//                }
//            })
//            
////            if showAlert {
////                AlertPopUp(
////                    presentAlert: $showAlert,
////                    alertType: alertType,
////                    leftButtonAction: {
////                        withAnimation { showAlert = false }
////                    }, rightButtonAction: {
////                        withAnimation { showAlert = false }
////                        self.presentationMode.wrappedValue.dismiss()
////                    })
////            }
//        }
//        .edgesIgnoringSafeArea(.bottom)
//    }
//    
//    func validate() {
//        guard request.email.isValidEmail() else {
//            hudMsg = "Email is required."
//            showHud = true
//            return
//        }
//        
//        guard request.phone.count > 7 else {
//            hudMsg = "Phone is required."
//            showHud = true
//            return
//        }
//        
//        guard request.message != "" else {
//            hudMsg = "Message is required."
//            showHud = true
//            return
//        }
//        Task {
//            contactUsViewModel.contactUs(parameters: request)
//        }
//    }
//    
//    func observe() {
//        self.contactUsViewModel.eventHandler = { event in
//            switch event {
//                case .loading:
//                    self.isLoading = true
//                case .stopLoading:
//                    self.isLoading = false
//                case .dataLoaded:
//                    handleSuccess()
//                case .error(let error):
//                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//                    showAlert = true
//            }
//        }
//    }
//    
//    func handleSuccess() {
//        
//        let response = contactUsViewModel.contactModelDict
//        if response.status == "success" {
//            alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
//            withAnimation { showAlert = true }
//        } else {
//            alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
//            withAnimation { showAlert = true }
//        }
//    }
//}
//
//
//#Preview {
//    ContactUsScreen()
//}
