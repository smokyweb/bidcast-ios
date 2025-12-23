//
//  OTPVerificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 12/06/25.
//

import SwiftUI
import AlertToast
import SVProgressHUD

struct OTPVerificationScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: SellerVerificationViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    var onSuccess: () -> Void
    
    @State private var phoneNumber: String = ""
    @State private var otpDigits: [String] = Array(repeating: "", count: 4)
    @State private var otpSent = false
    @State private var showhud = false
    @State private var hudMsg = ""
    @FocusState private var focusedField: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                PrimaryHeader(
                    title: "OTP Verification",
                    leadingImgArr: ["chevron.left"],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    Color.clear.frame(height: 5)
                    TitleWithLine(title: "Verify OTP", lineLength: sepratorLine)
                    AuthTextField(
                        floatingLabel: "Phone Number",
                        placeholder: "Enter phone number",
                        icon: .icMail,
                        text: $phoneNumber,
                        isIconDisplay: false,
                        enteredText: { phoneNumber = $0 }
                    )
                    .keyboardType(.numberPad)
                    .onChange(of: phoneNumber) { newValue in
                        // If phone number changes, reset OTP state
                        otpSent = false
                        otpDigits = Array(repeating: "", count: 4)  // Clear the OTP fields
                    }
                    
                    if !otpSent {
                        PrimaryButton(
                            title: "Send OTP",
                            isOutLine: false,
                            onButtonClick: {
                                UIApplication.shared.endEditing()
                                Task {
                                    await sendOTP()
                                }
                            },
                            btnTextColor: .white
                        )
                    }
                    
                    if otpSent {
                        VStack(spacing: 12) {
                            Text("Enter the 4-digit OTP sent to your phone")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            otpBoxView()
                            PrimaryButton(
                                title: "Verify OTP",
                                isOutLine: false,
                                onButtonClick: {
                                    UIApplication.shared.endEditing()
                                    Task { await verifyOTP() }
                                },
                                btnTextColor: .white
                            )
                        }
                    }
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            focusedField = 0
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
    }
    
    // MARK: - OTP 4-digit Entry Boxes
    @ViewBuilder
    private func otpBoxView() -> some View {
        HStack(spacing: 12) {
            ForEach(0..<4, id: \.self) { index in
                TextField("", text: $otpDigits[index])
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .focused($focusedField, equals: index)
                    .frame(width: 48, height: 48)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .font(.title2)
                    .onChange(of: otpDigits[index]) { newValue in
                        if newValue.count > 1 {
                            otpDigits[index] = String(newValue.prefix(1))
                        }
                        if newValue.count == 1 && index < 3 {
                            focusedField = index + 1
                        } else if newValue.isEmpty && index > 0 {
                            focusedField = index - 1
                        }
                    }
            }
        }
    }
    
    // MARK: - sendOTP
    private func sendOTP() async {
       guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        
        guard !phoneNumber.isEmpty else {
            hudMsg = "Please Enter Phone Number"
            showhud = true
            return
        }
        
        SVProgressHUD.show()
        let req = StorePhoneNumberRequest(phone_number: phoneNumber)
        await viewModel.storePhoneNumber(parameters: req)
        await SVProgressHUD.dismiss()
        sendOTPSuccess()
    }
    
    // MARK: - sendOTPSuccess
    private func sendOTPSuccess() {
       
        DispatchQueue.main.async{
            let response = viewModel.storePhoneNumberDict
            if response.status == "success" {
                otpSent = true
                hudMsg = "OTP sent"
            } else {
                hudMsg = "Failed to send OTP"
            }
            showhud = true
        }
    }
    
    private func verifyOTP() async {
        let otp = otpDigits.joined()
        guard let otpCode = Int(otp), otp.count == 4 else {
            hudMsg = "Invalid OTP"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let req = OtpVerifyRequest(otp: otpCode)
        await viewModel.otpVerify(parameters: req)
        await SVProgressHUD.dismiss()
        verifyOTPSuccess()
    }
    
    private func verifyOTPSuccess() {
        let response = viewModel.storePhoneNumberDict
        if response.status == "success" {
            hudMsg = "Verification successfull"
            showhud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onSuccess()
            }
        } else {
            hudMsg = "Invalid OTP"
            showhud = true
        }
    }
}
