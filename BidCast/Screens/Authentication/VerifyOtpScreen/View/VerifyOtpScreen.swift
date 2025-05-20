//
//  VerifyOtpScreen.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import SwiftUI
import AlertToast
//import BottomSheet

struct VerifyOtpScreen: View {
    
    // MARK: - Static Properties
    @State var isRemeber: Bool = false
    @State var isLoading: Bool = false
    @State var forgetOtpRequest: ForgetRequest = ForgetRequest(email: "")
    @State var request: VerifyOtpRequest = VerifyOtpRequest(email: "", code: 0)
    @State var pin: String = ""
    @State var maxDigits: Int = 4
    @State var navigateToResetPassword: Bool = false
    @State var navigateToLogin: Bool = false
    @State var isPassword: Bool = false
    @FocusState private var focusedField: Int?
    @State private var focusedIndex: Int? = 0

    // MARK: - Properties
    var headingText = AppString.enterCode.localized
    var viewModel = VerifyOtpViewModel()
    var forgetOtpModel = ForgotViewModel()
    
    // MARK: - Custom Alert
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var body: some View {
        ZStack(alignment: .top) {
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 5)
                    TitleWithLine(title: headingText, lineLength: sepratorLine)
                    VStack(alignment: .trailing, spacing: 12, content: {
                        pinDots
                        Button(action: {
                            if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                                request.email = mail
                                self.forgetOtpModel.forgotEmail(parameters: self.forgetOtpRequest)
                            }
                        }, label: {
                            Text(AppString.resendOtp.localized)
                                .font(.custom(poppinsMedium, fixedSize: 13))
                                .foregroundStyle(.red)
                        }).padding(.trailing, 35)
                    })
                    .padding([.leading , .trailing], Leading)
                    
                    PrimaryButton(title: AppString.submit.localized,isOutLine: false,onButtonClick: {
                        
                        guard !pin.isEmpty else {
                            hudMsg = AppString.otpNotEmpty.localized
                            showhud = true
                            return
                        }
                        
                        guard pin.count == 4 else {
                            hudMsg = AppString.enterOtp.localized
                            showhud = true
                            return
                        }
                        
                        if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                            request.email = mail
                            if let codeInt = Int(pin) {
                                request.code = codeInt
                                self.viewModel.verifyCode(parameters: self.request)
                            } else {
                                hudMsg = AppString.otpNumeric.localized
                                showhud = true
                            }
                        }
                    },btnTextColor: .white)
                }
                .padding(.horizontal)
                .padding(.top, 80)
                .padding(.bottom, 32)
                
                if isLoading {
                    Loader(isLoading: $isLoading)
                }
                
                CusNavLink(doNavigate: $navigateToResetPassword, destination: ResetPasswordScreen())
            }
            // Primary Header
            PrimaryHeader(
                title: AppString.verifyOtp.localized ,
                leadingImgArr: [.icBack],
                onClickLeading: { _ in
                    self.navigateToLogin = true
                },
                count: .constant(0)
            )
            
            .frame(height: 80)
            .shadow(radius: 2)
        }
        .frame(width: screenWidth, height: screenHeight)
        .onAppear {
            observe()
            forgotOtpObserver()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2, topBarCornerRadius: 25, showTopIndicator: false, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                }, onSecondaryClick: {
                    if isPassword == true {
                        withAnimation(.snappy) { navigateToResetPassword = true }
                    } else {
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
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .pinkBtn)
                showError = true
            }
        }
    }
    
    func forgotOtpObserver() {
        self.forgetOtpModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                handleSuccess()
            case .error(let error):
                alertType = .sheetType(icon: .alert, title: AppString.error.localized, message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .pinkBtn)
                showError = true
            }
        }
    }
    
    func handleSuccess() {
        let response = viewModel.verifyResponceDict
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.email, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .green)
            showError = true
            isPassword = true
            withAnimation(.snappy) { navigateToResetPassword = true }
        } else {
            alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }
    }
    
    func handleForgetPassSuccess() {
        let response = forgetOtpModel.forgotResponceDict
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.email, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .green)
            showError = true
            isPassword = true
        } else {
            alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .pinkBtn)
            withAnimation(.snappy) { showError = true }
        }
    }

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
                        .font(.custom(poppinsSemiBold, fixedSize: 18))
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
