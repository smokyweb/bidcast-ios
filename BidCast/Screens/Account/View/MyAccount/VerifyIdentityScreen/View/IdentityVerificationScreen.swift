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
    var body: some View {
        VStack(spacing: 0) {

            // Header
            PrimaryHeader(
                title: "Add KYC",
                leadingImgArr: ["chevron.left"],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            ScrollView{
                VStack(spacing: 16){
                    contentView
                }
            }
            .padding(.top,24)
            .padding(.horizontal,16)
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
        Text("Identity Verification")
            .font(.custom(poppinsBold, size: 24))
            .foregroundColor(.black)
        
        HStack{
            Text("KYC Status")
                .font(.custom(poppinsRegular, size: 16))
                .foregroundColor(.darkGray)
            Spacer()
            Text(kycData.kycStatus?.capitalizingFirstLetter() ?? "")
                .font(.custom(poppinsSemiBold, size: 16))
                .foregroundColor(.defaultTheme)
        }
        
        if kycData.kycStatus == "inactive" {
            inactiveKycView
        } else {
            activeKycView
        }
    }

    // MARK: - Inactive KYC View
    private var inactiveKycView: some View {
        VStack(spacing: 12) {

            Text("Complete your KYC to continue")
                .font(.custom(poppinsRegular, size: 16))
                .foregroundColor(.gray)

            PrimaryButton(title: "Start KYC",onButtonClick: {
                if let urlString = viewModel.checkKycDict.data?.link,
                   let url = URL(string: urlString) {
                    openURL(url)
                }
            }).padding(.horizontal, 16)
        }
        .padding(.top, 40)
    }

    // MARK: - Active / Completed KYC View
    private var activeKycView: some View {
            VStack(spacing: 12) {
               
                Text("Your KYC has been completed.")
                    .font(.custom(poppinsRegular, size: 16))
                    .foregroundColor(.success)
            }
        
    }

    
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
                try await viewModel.getKycDetail()
                
            }
        }
    }

    func success(){
        let response = viewModel.checkKycDict
        if response.status == "success"{
            kycData = response.data ?? CheckKycModel()
        }
    }
    func detailSuccess(){
        let response = viewModel.kycDetailsDict
        if response.status == "success"{
//            kycData = response.data ?? KycDetailsModel()
        }
    }
}
