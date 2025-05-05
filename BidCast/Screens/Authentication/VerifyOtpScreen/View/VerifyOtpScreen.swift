//
//  VerifyOtpScreen.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import SwiftUI
//import BottomSheet
//import AlertToast

struct VerifyOtpScreen: View {
    
        //MARK: Static Properties
    @State var isRemeber: Bool = false
    @State var isLoading: Bool = false
    @State var request: VerifyOtpRequest = VerifyOtpRequest(user_name: "", code: "")
    @State var pin: String = ""
    @State var maxDigits: Int = 5
    @State var navigateToResetPassword: Bool = false
    @State var navigateToLogin: Bool = false
    @State var isPassword: Bool = false
    @FocusState private var focusedField: Int?
    @State private var focusedIndex: Int? = 0

        //MARK: Properties
    var headingText = "User Name was good"
    var viewModel = VerifyOtpViewModel()
    
        //MARK: - Custom Alert
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
        //MARK: View
    var body: some View {
        ScrollView(showsIndicators: false) {

            ZStack {
                VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                    Image(.halfBackground)
                        .resizable()
                        .scaledToFill()
                        .frame(width: screenWidth, height: screenHeight/3)
                        .edgesIgnoringSafeArea(.top)
                        .overlay(alignment: .top, content: {
                            Image(.appName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: screenWidth/2, height: screenHeight/12)
                                .padding(.top, screenHeight/20)
                        })
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    TitleWithLine(title: headingText, lineLength: 32)
                    
                    Text("Please enter the code that was sent to the email associated with your account!")
                        .font(.custom(nunitoMedium, fixedSize: 18))
                        .foregroundStyle(.black)
                    
                    Text("Enter OTP")
                        .font(.custom(nunitoBold, fixedSize: 22))
                        .foregroundStyle(.black)
                    
                    VStack(alignment: .trailing, spacing: 12, content: {
                        
                        pinDots
                        
                        Button(action: {
                            if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                                pin = ""
                                self.viewModel.resendOTPCode(parameters: ForgetRequest(user_name: mail))
                            }
                        }, label: {
                            Text("Resend OTP")
                                .font(.system(size: 14))
                                .bold()
                                .foregroundStyle(.red)
                        }).padding(.trailing, 35)
                    })
                    
                    PrimaryButton(title: "Submit") {
                        
                        guard !pin.isEmpty else {
                            hudMsg = "OTP can not be empty"
                            showhud = true
                            return
                        }
                        
                        guard pin.count == 5 else {
                            hudMsg = "Please enter the OTP"
                            showhud = true
                            return
                        }
                        
                        if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                            request.user_name = mail
                            request.code = pin
                            self.viewModel.verifyCode(parameters: self.request)
                        }
                    }
                    
                    HStack(spacing:4) {
                        Spacer()
                        Text("Back to")
                            .font(.system(size: 14))
                            .foregroundStyle(.gray)
                        Button(action: {
                            navigateToLogin = true
                        }, label: {
                            Text("Login!")
                                .font(.system(size: 14))
                                .bold()
                                .foregroundStyle(.red)
                        })
                        Spacer()
                    }.padding([.top, .bottom], 16)
                }
                .padding([.leading, .trailing])
                
                .padding(.top, screenHeight/3)
                
                if isLoading {
                    Loader(isLoading: $isLoading)
                }
                
                //            if showError {
                //                AlertPopUp(presentAlert: $showError, alertType: alertType, rightButtonAction: {
                //                    withAnimation(.snappy) { showError = false }
                //                })
                //            }
                
//                CusNavLink(doNavigate: $navigateToResetPassword, destination: ResetPasswordScreen())
                CusNavLink(doNavigate: $navigateToLogin, destination: LoginScreen())
            }.frame(width: screenWidth, height: screenHeight)
        }
        .onAppear(){
            observe()
        }
//        .toast(isPresenting: $showhud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    if isPassword == true{
                        withAnimation(.snappy){ navigateToResetPassword = true }
                    }else{
                        withAnimation { showError = false }
                    }

                })
        })
    }
    
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showError = true
            }
        }
    }
    
    func handleSuccess() {
        let response = viewModel.verifyResponceDict
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.user_name, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .green)
            showError = true
            isPassword = true
//            withAnimation(.snappy) { navigateToResetPassword = true }
        } else {
            alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }
    }
    
        //MARK: Methods
    private func getImageName(at index: Int) -> String {
        if index >= pin.count {
            return ""
        }
        if pin.digit.count > 0 {
            return pin.digit[index].numberStrings
        }
        return ""
    }
    
    
    private var pinDots: some View {
        HStack(spacing: 12) {
            Spacer()
            ForEach(0..<maxDigits, id: \.self) { index in
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.gray.opacity(0.25))
                        .background(RoundedRectangle(cornerRadius: 10)
                            .fill(.white))
                        .frame(width: 50, height: 50)
                    backgroundField
                    let otp = self.getImageName(at: index)
                    Text(otp)
                        .font(.custom(nunitoSemiBold, fixedSize: 20))
                        .foregroundColor(.black)
                        .padding(.leading, 5)
                }
                .onTapGesture {
                    focusedIndex = index
                }
                .focused($focusedField, equals: index)
            }
            Spacer()
        }
        .onChange(of: pin) { newValue in
            if newValue.count > 0 && newValue.count < maxDigits {
                focusedField = newValue.count
            } else if newValue.count == maxDigits {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    private var backgroundField: some View {
        let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
            self.pin = newValue
            focusedField = newValue.count < maxDigits ? newValue.count : nil
        })
        return TextField("", text: boundPin)
            .font(.custom(nunitoSemiBold, fixedSize: 20))
            .accentColor(.clear)
            .tint(.clear)
            .foregroundColor(.clear)
            .keyboardType(.numberPad)
            .submitLabel(.done)
            .frame(width: 50, height: 50)
    }
}

#Preview {
    VerifyOtpScreen()
}
