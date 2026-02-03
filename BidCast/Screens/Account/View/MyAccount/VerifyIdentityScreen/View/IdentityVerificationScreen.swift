//
//  IdentityVerificationScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/01/26.
//

import Foundation
import SwiftUI

import SwiftUI
import SVProgressHUD

struct IdentityVerificationScreen: View {

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL

    @StateObject var viewModel = KycViewModel()
    @State private var isLoading = false
    @State private var isFetchingMore = false
    @State private var canLoadMore = true
    @State private var showError = true
    @State var kycData = CheckKycModel()
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    @State private var showKycWebView = false
    @State private var kycURL: URL?
    @State private var didOpenKyc = false
    var body: some View {
        VStack(spacing: 0) {

            // Header
            PrimaryHeader(
                title: kycURL == nil ? "Update KYC" : "Add KYC",
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
//            ScrollView{
//                VStack(spacing: 16){
//                    contentView
//                }
//            }
//            .padding(.top,24)
//            .padding(.horizontal,16)
            Group {
                if let url = kycURL {
                    KycWebView(url: url) {
                        presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    ScrollView{
                        VStack(spacing: 16){
                            contentView
                        }
                    }
                    .padding(.horizontal,16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
       
        .background(.backGround)
        .navigationBarHidden(true)
        .onAppear {
            loadKycStatus()
            
        }
        
    }

    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {

//        Text("Identity Verification")
//            .font(.custom(poppinsBold, size: 24))
//            .foregroundColor(.black)
//
//        HStack {
//            Text("KYC Status")
//                .font(.custom(poppinsRegular, size: 16))
//                .foregroundColor(.darkGray)
//
//            Spacer()
//
//            Text(kycData.kycStatus?.capitalizingFirstLetter() ?? "")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.success)
//        }

        if kycData.kycStatus == "active" {

            // 🔹 Profile header
            KycProfileHeaderView(
                profileImageURL: UserDefaults.profileURL, fullName: UserDefaults.fullName,
                username: UserDefaults.userName.capitalizingFirstLetter() ,
                status: kycData.kycStatus ?? ""
            )

            // 🔹 KYC details
            if let details = kycData.kycDetails {
                KycDetailsView(details: details)
            }
            
            PrimaryButton(title: "Update KYC",onButtonClick: {
                if let urlString = viewModel.checkKycDict.data?.link,
                   let url = URL(string: urlString) {
                    openURL(url)
                }
            })
        }
    }

//    // MARK: - Inactive KYC View
//    private var inactiveKycView: some View {
//        VStack(spacing: 12) {
//
//            Text("Complete your KYC to continue")
//                .font(.custom(poppinsRegular, size: 16))
//                .foregroundColor(.gray)
//
//            PrimaryButton(title: "Start KYC",onButtonClick: {
//                if let urlString = viewModel.checkKycDict.data?.link,
//                   let url = URL(string: urlString) {
//                    openURL(url)
//                }
//            }).padding(.horizontal, 16)
//        }
//        .padding(.top, 40)
//    }
//
//    // MARK: - Active / Completed KYC View
//    private var activeKycView: some View {
//            VStack(spacing: 12) {
//               
//                Text("Your KYC has been completed.")
//                    .font(.custom(poppinsRegular, size: 16))
//                    .foregroundColor(.success)
//            }
//        
//    }

    
    private func loadKycStatus() {

        Task {
            await performAPICalls(
                isConcurrent: false,
                showLoader: true,
                onError: { error in
                    config = BottomSheetConfig(
                        icon: "exclamationmark.circle",
                        title: "Error",
                        message: errorDesc(error: error, message: viewModel.errorMessage),
                        primaryButtonTitle: AppString.ok.localized,
                        secondaryButtonTitle: nil
                    )
                    showError = true
                },
                onSuccess: {
                    success()
                    detailSuccess()
                }
            ) {
               
                try await viewModel.checkKycDetail()
//                try await viewModel.getKycDetail()
                
            }
        }
    }

    func success() {
        let response = viewModel.checkKycDict

        guard response.status == "success" else { return }

        // ✅ Always store KYC data
        kycData = response.data ?? CheckKycModel()

        // 🚀 If inactive → open web view
        if kycData.kycStatus == "inactive",
           let link = kycData.link,
           let url = URL(string: link) {

            kycURL = url
        }

        // ✅ If active → show content view only
        if kycData.kycStatus == "active" {
            kycURL = nil
        }
    }


    func detailSuccess(){
        let response = viewModel.kycDetailsDict
        if response.status == "success"{
//            kycData = response.data ?? KycDetailsModel()
        }
    }
}

import SwiftUI
import WebKit
import SVProgressHUD

struct KycWebView: UIViewRepresentable {

    let url: URL
    let onKycCompleted: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onKycCompleted: onKycCompleted)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // 🔄 Start loader
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }

        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate {

        let onKycCompleted: () -> Void

        init(onKycCompleted: @escaping () -> Void) {
            self.onKycCompleted = onKycCompleted
        }

        // 🔄 Page started loading
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            SVProgressHUD.show()
        }

        // ✅ Page loaded successfully
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            SVProgressHUD.dismiss()
        }

        // ❌ Page failed
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            SVProgressHUD.dismiss()
        }

        func webView(
            _ webView: WKWebView,
            didFailProvisionalNavigation navigation: WKNavigation!,
            withError error: Error
        ) {
            SVProgressHUD.dismiss()
        }

        // 🔍 Detect KYC completion redirect
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
        ) {

            if let urlString = navigationAction.request.url?.absoluteString {
                if urlString.contains("kyc-success") ||
                   urlString.contains("completed") {

                    SVProgressHUD.dismiss()
                    onKycCompleted()
                }
            }

            decisionHandler(.allow)
        }
    }
}

struct KycDetailsView: View {
    let details: KycDetailsModel

    var body: some View {
        VStack(spacing: 0) {

            KycDetailRow(title: "Phone", value: details.phone ?? "N/A")
            Divider()

            KycDetailRow(title: "City", value: details.city ?? "N/A")
            Divider()

            KycDetailRow(title: "Country", value: details.country ?? "N/A")
            Divider()

            KycDetailRow(title: "Postal Code", value: details.postalCode ?? "N/A")
            Divider()

            KycDetailRow(title: "Bank ID", value: details.bankID ?? "N/A")
            Divider()

            KycDetailRow(title: "Routing Number", value: details.rountingNumber)
            Divider()

            KycDetailRow(title: "Currency", value: details.currency)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
    }
}
struct KycDetailRow: View {
    let title: String
    let value: String?

    var body: some View {
        HStack {
            Text(title)
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.darkGray)

            Spacer()

            Text(value ?? "-")
                .font(.custom(poppinsMedium, size: 14))
                .foregroundColor(.black)
        }
        .padding(.vertical, 10)
    }
}
struct KycProfileHeaderView: View {
    let profileImageURL: String?
    let fullName : String
    let username: String
    let status: String

    var body: some View {
        VStack(spacing: 12) {
CustomProfileImage(url: profileImageURL ?? "", isCircular: true, size: 80)
//            AsyncImage(url: URL(string: profileImageURL ?? "")) { image in
//                image
//                    .resizable()
//                    .scaledToFill()
//            } placeholder: {
//                Circle()
//                    .fill(Color.gray.opacity(0.3))
//            }
//            .frame(width: 80, height: 80)
//            .clipShape(Circle())
            Text(fullName.capitalizingFirstLetter())
                .font(.custom(poppinsSemiBold, size: 18))
                .foregroundColor(.black)
            Text(username)
                .font(.custom(poppinsSemiBold, size: 14))
                .foregroundColor(.darkGray)

            Text(status.capitalizingFirstLetter())
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.defaultTheme)
        }
        .padding(.top, 16)
    }
}
