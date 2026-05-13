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
    //
    // MC sub-tasks cmp4934lz00ll3mx1lw2qfq1r / cmp4935rh00lx3mx14etxsz0v /
    // cmp49365h00m13mx1vhyu727e / cmp4936fi00m33mx1oaygms9x (Trey 2026-05-13):
    // OTP never arrives on iOS seller verification because the user types a
    // raw US number ("5551234567") and the backend's Twilio dispatch requires
    // E.164 ("+15551234567"). Normalise to E.164 before sending. Strips all
    // non-digits, defaults to US (+1) when 10 digits are provided, and leaves
    // any user-typed leading "+" intact so international numbers still work.
    private func toE164(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        // Preserve a user-supplied + (international) prefix.
        let hasPlus = trimmed.hasPrefix("+")
        let digits = trimmed.unicodeScalars
            .filter { CharacterSet.decimalDigits.contains($0) }
            .map(String.init)
            .joined()
        if hasPlus { return "+" + digits }
        // No prefix: assume US when the user gave 10 digits, otherwise pass as-is
        // and let the backend reject if invalid.
        if digits.count == 10 { return "+1" + digits }
        if digits.count == 11 && digits.hasPrefix("1") { return "+" + digits }
        return digits
    }

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
        
        let normalized = toE164(phoneNumber)
        guard normalized.hasPrefix("+") else {
            hudMsg = "Please enter a valid phone number (10 digits or include country code)."
            showhud = true
            return
        }

        SVProgressHUD.show()
        let req = StorePhoneNumberRequest(phone_number: normalized)
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
