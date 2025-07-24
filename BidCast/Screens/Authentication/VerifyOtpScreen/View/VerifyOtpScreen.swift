//
//  VerifyOtpScreen.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 19/01/24.
//

import SwiftUI
import AlertToast
import SwiftfulLoadingIndicators
import SVProgressHUD
//import BottomSheet

struct VerifyOtpScreen: View {
    
    // MARK: - Static Properties
    @EnvironmentObject var appRootManager: AppRootManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
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
        VStack {
            VStack{
                PrimaryHeader(
                    title: AppString.verifyOtp.localized ,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        withAnimation {
                            appRootManager.currentRoot = .authentication
                        }
                    },
                    count: .constant(0)
                )
            }
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 5)
                    TitleWithLine(title: headingText, lineLength: sepratorLine)
                    SingleTitleLabel(title: AppString.successOtpMessage.localized, textColor: .mediumLightGray, fontValue: 13.0)
                    VStack(alignment: .trailing, spacing: 12, content: {
                        PinInputView(pin: $pin)
                        Button(action: {
                            UIApplication.shared.endEditing()
                            if let mail: String = UserDefaultsManager.shared.value(forKey: .mailId) {
                                forgetOtpRequest.email = mail
                                
                                Task {
                                    SVProgressHUD.show()
                                    self.viewModel.errorMessage?.removeAll()
                                    await forgetOtpModel.forgotEmail(parameters: forgetOtpRequest)
                                    await SVProgressHUD.dismiss()
                                    handleForgetPassSuccess()
                                }
                            }
                        }, label: {
                            Text(AppString.resendOtp.localized)
                                .font(.custom(poppinsMedium, fixedSize: 13))
                                .foregroundStyle(.secondary)
                        }).padding(.trailing, 35)
                    })
                    
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
                                Task {
                                    guard Reachability.isConnectedToNetwork() else {
                                        hudMsg = "No Internet Connection"
                                        showhud = true
                                        return
                                    }
                                    SVProgressHUD.show()
                                    await viewModel.verifyCode(parameters: request)
                                    await SVProgressHUD.dismiss()
                                    handleSuccess()
                                }
                            } else {
                                hudMsg = AppString.otpNumeric.localized
                                showhud = true
                            }
                        }
                    },btnTextColor: .white)
                }
                CusNavLink(doNavigate: $navigateToResetPassword, destination: ResetPasswordScreen())
            }

        }
//        .frame(width: screenWidth, height: screenHeight)
        
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false, content: {
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
    
    
    
    func handleSuccess() {
        let response = viewModel.verifyResponse
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(request.email, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
            showError = true
            isPassword = true
            withAnimation(.snappy) { navigateToResetPassword = true }
        } else {
            alertType = .sheetType(icon: .alert, title: "Failed", message: viewModel.errorMessage ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
            withAnimation(.snappy) { showError = true }
        }
    }
    
    func handleForgetPassSuccess() {
        let response = forgetOtpModel.forgotResponseDict
        if response.status == "success" {
            UserDefaultsManager.shared.setValue(forgetOtpRequest.email, forKey: .mailId)
            alertType = .sheetType(icon: .success, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .secondary)
            showError = true
            isPassword = false
        } else {
            alertType = .sheetType(icon: .alert, title: "Failed", message: viewModel.errorMessage ?? "", primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .red)
            withAnimation(.snappy) { showError = true }
        }
    }
   
    
}

#Preview {
    VerifyOtpScreen()
}


struct PinInputView: View {
    
    @Binding var pin: String
    @State private var isCursorVisible = true
    @FocusState private var focusedField: Int?
    
    var maxDigits = 4 // You can change this to your desired PIN length
    
    var body: some View {
        VStack {
            pinDots
        }
        .onAppear {
            startCursorTimer()
            focusedField = 0
        }
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
                    
                    
                    if index < pin.count {
                        let otp = self.getImageName(at: index)
                        Text(otp)
                            .font(.custom(poppinsSemiBold, size: 16.0))
                            .foregroundColor(.black)
                    }
                   
                    else if index == pin.count && isCursorVisible {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 2, height: 25)
                            .animation(.easeInOut(duration: 0.5).repeatForever(), value: isCursorVisible)
                    }
                }
                .onTapGesture {
                    UIApplication.shared.endEditing()
                    focusedField = 0
                }
            }
            Spacer()
        }
        .background(
            hiddenTextField
        )
        .onChange(of: pin) { newValue in
            if newValue.count == maxDigits {
                UIApplication.shared.endEditing()
            }
        }
    }
    
    private var hiddenTextField: some View {
        let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
            if newValue.count <= maxDigits {
                self.pin = newValue
            }
        })
        return TextField("", text: boundPin)
            .keyboardType(.numberPad)
            .accentColor(.clear)
            .tint(.clear)
            .foregroundColor(.clear)
            .submitLabel(.done)
            .focused($focusedField, equals: 0)
            .frame(width: 0, height: 0)
            .opacity(0.01)
    }
    
    private func startCursorTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            isCursorVisible.toggle()
        }
    }
    
    private func getImageName(at index: Int) -> String {
        let pinArray = Array(pin)
        guard index < pinArray.count else { return "" }
        return String(pinArray[index])
    }
}
