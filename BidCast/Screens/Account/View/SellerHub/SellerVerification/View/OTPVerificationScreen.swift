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
                VStack(spacing: 25) {
                    Color.clear.frame(height: 5)
                    TitleWithLine(title: "Verify OTP", lineLength: sepratorLine)
                    // FIX cmp41i95100rm4axy5gwqz0jp: US numbers only
                    VStack(alignment: .leading, spacing: 4) {
                        AuthTextField(
                            floatingLabel: "US Phone Number",
                            placeholder: "10-digit US number (e.g. 5551234567)",
                            icon: .icMail,
                            text: $phoneNumber,
                            isIconDisplay: false,
                            enteredText: { phoneNumber = $0 }
                        )
                        .keyboardType(.numberPad)
                        .onChange(of: phoneNumber) { newValue in
                            otpSent = false
                            otpDigits = Array(repeating: "", count: 4)
                        }
                        Text("US numbers only. Enter 10 digits without country code.")
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 4)
                    }
                    
                    if !otpSent {
                        HStack(alignment: .center) {
                            PrimaryButton(
                                title: "Send OTP",
                                isOutLine: false,
                                onButtonClick: {
                                    UIApplication.shared.endEditing()
                                    Task {
                                        await sendOTP()
                                    }
                                }
                            )
                        }
                       
                    }
                    
                    if otpSent {
                        VStack(spacing: 12) {
                            Text("Enter the 4-digit OTP sent to your phone")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            otpBoxView()
                            HStack(alignment: .center) {
                                PrimaryButton(
                                    title: "Verify OTP",
                                    isOutLine: false,
                                    onButtonClick: {
                                        UIApplication.shared.endEditing()
                                        Task { await verifyOTP() }
                                    }
                                )
                            }
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

        // FIX cmp41i95100rm4axy5gwqz0jp: US numbers only.
        // Strip all non-digit characters first.
        var digits = phoneNumber
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined()

        // Allow 11 digits if user typed the leading country code 1
        if digits.count == 11 && digits.hasPrefix("1") {
            digits = String(digits.dropFirst())
        }

        // SignalWire account is US-only — must be exactly 10 digits
        guard digits.count == 10 else {
            hudMsg = "US numbers only. Enter your 10-digit number (e.g. 5551234567)"
            showhud = true
            return
        }

        // Backend normalizePhone() adds +1 for 10-digit numbers automatically
        SVProgressHUD.show()
        let req = StorePhoneNumberRequest(phone_number: digits)
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
        // FIX cmp41i95100rm4axy5gwqz0jp: was incorrectly reading storePhoneNumberDict
        // (the send-OTP response) instead of otpVerifyDict (the verify-OTP response),
        // so success was never detected after entering the correct code.
        let response = viewModel.otpVerifyDict
        if response.status == "success" {
            hudMsg = "Verification successful"
            showhud = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onSuccess()
            }
        } else {
            hudMsg = response.message ?? "Invalid OTP"
            showhud = true
        }
    }
}
