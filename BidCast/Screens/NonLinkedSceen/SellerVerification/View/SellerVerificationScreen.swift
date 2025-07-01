//
//  SellerVerificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

//import SwiftUI
//import AlertToast
//import SVProgressHUD
//
//enum VerificationStatus {
//    case completed, pending
//}
//
//struct SellerVerificationScreen: View {
//    @Environment(\.presentationMode) var presentationMode
//    @State var viewModel = SellerVerificationViewModel()
//    @State var navigateToProfile: Bool = false
//    @State private var isLoading = false
//    @State private var showError = false
//    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State private var showhud = false
//    @State private var hudMsg = ""
//
//    var body: some View {
//        VStack(spacing: 0) {
//            
//            // Custom Primary Header
//            PrimaryHeader(
//                title: "Seller Verification",
//                isForLogo: false,
//                leadingImgArr: [.icBack],
//                trailingImgArr: [],
//                onClickLeading: { _ in
//                    self.presentationMode.wrappedValue.dismiss()
//                },
//                count: .constant(0)
//            )
//            .background(Color.white)
//            .padding(.horizontal)
//            .frame(height: 70)
//
//            ScrollView {
//                VStack(alignment: .leading, spacing: 24) {
//                    
//                    // Progress Section
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Verification Progress")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                        
//                        ProgressView(value: 2, total: 4)
//                            .accentColor(.blue)
//                        
//                        Text("2 of 4")
//                            .font(.caption.bold())
//                            .frame(maxWidth: .infinity, alignment: .trailing)
//                            .foregroundColor(.black)
//                    }
//                    .padding(.horizontal)
//
//                    // ID Verification
//                    VerificationSectionView(
//                        icon: "idcard.fill",
//                        title: "ID Verification",
//                        subtitle: "Upload your ID card & take a selfie",
//                        status: .completed,
//                        actions: ["ID Card", "Selfie"]
//                    )
//
//                    // Phone Verification
//                    VerificationSectionView(
//                        icon: "phone.fill",
//                        title: "Phone Verification",
//                        subtitle: "Verify your phone number",
//                        status: .pending,
//                        actionLabel: "Verify"
//                    )
//
//                    // Payment Method
//                    VerificationSectionView(
//                        icon: "creditcard.fill",
//                        title: "Payment Method",
//                        subtitle: "Add your payment details",
//                        status: .pending,
//                        actionLabel: "Add",
//                        showDashedCard: true
//                    )
//
//                    // Manual Verification
//                    VerificationSectionView(
//                        icon: "person.crop.circle.badge.checkmark",
//                        title: "Manual Verification",
//                        subtitle: "Final review by our team",
//                        statusText: "Pending"
//                    )
//                }
//                .padding()
//            }
//
//            // Bottom Action Button
//            Button(action: {
//                print("Complete Verification tapped")
//            }) {
//                Text("Complete Verification")
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(16)
//            }
//            .padding()
//        }
//        .background(Color(.systemGroupedBackground))
//        .ignoresSafeArea(edges: .bottom)
//        .onAppear {
//            UIScrollView.appearance().bounces = false
//            
//        }
//        .onDisappear {
//            UIScrollView.appearance().bounces = true
//        }
//        .toast(isPresenting: $showhud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
//        }
//        .bottomSheet(
//            isPresented: $showError,
//            height: screenHeight / 2.3,
//            topBarCornerRadius: 25,
//            showTopIndicator: false
//        ) {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    withAnimation(.snappy) { navigateToProfile = true
//                        showError = false  }
//                },
//                onSecondaryClick: {
//                    withAnimation { showError = false }
//                }
//            )
//        }
//    }
//    //MARK: handleSuccess.
//    func handleIDVerificationSuccess() {
//        SVProgressHUD.dismiss()
//        let response = viewModel.storeIDCardDict
//        if response?.status == "success" {
//    
//        } else {
//           
//        }
//    }
//}

import SwiftUI
import AlertToast
import PhotosUI
import SVProgressHUD

enum VerificationStatus {
    case completed, pending
}

struct SellerVerificationScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = SellerVerificationViewModel()

    @State private var navigateToOTP = false
    @State private var navigateToAddCard = false
    @State private var showhud = false
    @State private var hudMsg = ""
    @State var cardDetails: CardDetails?

    @State private var idVerificationComplete = false
    @State private var phoneVerificationComplete = false
    @State private var paymentMethodComplete = false
    @State private var manualVerificationComplete = false

    @State private var idCardImageData: Data?
    @State private var selfieImageData: Data?
    @State private var selectedIDCardItem: PhotosPickerItem?
    @State private var selfieImage: UIImage? = nil
    @State private var selfiePath: String? = nil

    @State private var showSelfieCamera: Bool = false
    @State private var showIDCardPicker: Bool = false

    var currentStep: Int {
        var count = 0
        if idVerificationComplete { count += 1 }
        if phoneVerificationComplete { count += 1 }
        if paymentMethodComplete { count += 1 }
        if manualVerificationComplete { count += 1 }
        return count
    }

    let totalSteps = 4.0

    var body: some View {
        VStack(spacing: 0) {
            VStack{
                PrimaryHeader(
                    title: "Seller Verification",
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in self.presentationMode.wrappedValue.dismiss() },
                    count: .constant(0)
                )
            }
           

            ScrollView {
                VStack(spacing: 18) {
                    // Progress Bar
                    VStack(alignment: .leading) {
                        Text("Verification Progress")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundColor(.gray)

                        ProgressView(value: Double(currentStep), total: totalSteps)
                            .accentColor(.blue)

                        Text("\(currentStep) of \(Int(totalSteps))")
                            .font(.custom(poppinsSemiBold, size: 11.0))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.black)
                    }

                    // ID Verification Card
                    IDVerificationCard(
                        idCardImageData: $idCardImageData,
                        selfieImageData: $selfieImageData,
                        showIDCardPicker: $showIDCardPicker,
                        showSelfieCamera: $showSelfieCamera,
                        idVerificationComplete: $idVerificationComplete,
                        handleUpload: {
                            SVProgressHUD.show()
                            await handleIDUpload()
                            await SVProgressHUD.dismiss()
                        }
                    )

                    // Phone Verification
                    VerificationSectionView(
                        icon: "phone.fill",
                        title: "Phone Verification",
                        subtitle: "Verify your phone number",
                        status: phoneVerificationComplete ? .completed : .pending,
                        actionLabel: "Verify",
                        isActionEnabled: idVerificationComplete && !phoneVerificationComplete,
                        onActionTap: {
                            navigateToOTP = true
                        }
                    )

                    // Payment Method
                    VerificationSectionView(
                        icon: "creditcard.fill",
                        title: "Payment Method",
                        subtitle: "Add your payment details",
                        status: paymentMethodComplete ? .completed : .pending,
                        actionLabel: "Add",
                        showDashedCard: true,
                        isActionEnabled: phoneVerificationComplete && !paymentMethodComplete,
                        onActionTap: {
                            navigateToAddCard = true
                        }
                    )

                    // Show Card or Empty View
                    if let card = cardDetails {
                        CardDetailsView(card: card)
                    } else if paymentMethodComplete {
                        Text("No Payment Method Found")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Manual Verification
                    VerificationSectionView(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Manual Verification",
                        subtitle: "Final review by our team",
                        statusText: manualVerificationComplete ? "Verified" : "Pending"
                    )
                }
                .padding()
            }

            // Final Button
            Button(action: {
                manualVerificationComplete = true
            }) {
                Text("Complete Verification")
                    .font(.custom(poppinsSemiBold, size: 16.0))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(currentStep == Int(totalSteps - 1) ? Color.blue : Color.gray)
                    .cornerRadius(16)
            }
            .padding()
            .disabled(currentStep != Int(totalSteps - 1))
        }
        .background(.white)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg)
        }
        .photosPicker(isPresented: $showIDCardPicker, selection: $selectedIDCardItem, matching: .images)
        .onChange(of: selectedIDCardItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    idCardImageData = data
                }
            }
        }
        .sheet(isPresented: $showSelfieCamera) {
            ImagePicker(sourceType: .camera, onImagePicked: { image, path in
                if let image = image, let data = image.jpegData(compressionQuality: 0.6) {
                    selfieImage = image
                    selfieImageData = data
                    selfiePath = path
                }
            })
        }
        .background(Color.white)
        .navigationBarHidden(true)

        CusNavLink(doNavigate: $navigateToOTP,
                   destination: OTPVerificationScreen(viewModel: viewModel, onSuccess: {
            phoneVerificationComplete = true
            navigateToOTP = false
        }))

        CusNavLink(
            doNavigate: $navigateToAddCard,
            destination: AddCardScreen(isNavFrom: "SellerVerification", onSuccess: {
                fetchPaymentDetails()
            }))
    }

    func handleIDUpload() async {
        guard let idData = idCardImageData,
              let selfieData = selfieImageData,
              let idURL = compressAndSaveImage(data: idData),
              let selfieURL = compressAndSaveImage(data: selfieData) else {
            hudMsg = "Failed to prepare images"
            showhud = true
            return
        }

        hudMsg = "Uploading..."
        showhud = true

        let params: [String: Any] = [:]
        let images = [[idURL.path], [selfieURL.path]]
        let keys = ["id_card", "image"]
        let mime = ["image/jpeg", "image/jpeg"]
        await viewModel.storeIDCard(parameters: params, images: images, mimeType: mime, keysValue: keys)
        idUploadSuccess()
    }

    func idUploadSuccess() {
        if viewModel.storeIDCardDict?.status == "success" {
            idVerificationComplete = true
            hudMsg = "ID Verification Successful"
        } else {
            hudMsg = "ID Verification Failed"
        }
        showhud = true
    }

    func fetchPaymentDetails() {
        Task {
            SVProgressHUD.show()
            await self.viewModel.fetchSellerPaymentDetail()
            await SVProgressHUD.dismiss()
            successPaymentDetail()
        }
    }

    func successPaymentDetail() {
        if viewModel.paymentDetailDict.status == "success",
           let card = viewModel.paymentDetailDict.data?.cardDetails {
            cardDetails = card
            paymentMethodComplete = true
            hudMsg = "Payment Method Added"
        } else {
            cardDetails = nil
            paymentMethodComplete = false
            hudMsg = "No Payment Method Found"
        }
        showhud = true
    }
}

private struct IDVerificationCard: View {
    @Binding var idCardImageData: Data?
    @Binding var selfieImageData: Data?
    @Binding var showIDCardPicker: Bool
    @Binding var showSelfieCamera: Bool
    @Binding var idVerificationComplete: Bool
    let handleUpload: () async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "idcard.fill")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.green.opacity(0.8))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text("ID Verification")
                        .font(.custom(poppinsSemiBold, size: 14.0))
                        .foregroundColor(.black)
                    Text("Upload your ID card & take a selfie")
                        .font(.custom(poppinsRegular, size: 13.0))
                        .foregroundColor(.gray)
                }

                Spacer()

                if idVerificationComplete {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.headline)
                }
            }

            let boxSize = (UIScreen.main.bounds.width - 64) / 2

            HStack(spacing: 12) {
                Button {
                    showIDCardPicker = true
                } label: {
                    if let idData = idCardImageData, let uiImage = UIImage(data: idData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: boxSize, height: 100)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "creditcard.fill")
                                .font(.system(size: 24))
                            Text("ID Card")
                                .font(.custom(poppinsSemiBold, size: 11.0))
                        }
                        .frame(width: boxSize, height: 100)
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray))
                    }
                }

                Button {
                    showSelfieCamera = true
                } label: {
                    if let selfieData = selfieImageData, let uiImage = UIImage(data: selfieData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: boxSize, height: 100)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        VStack(spacing: 4) {
                            Image(systemName: "person.crop.circle")
                                .font(.system(size: 24))
                            Text("Selfie")
                                .font(.custom(poppinsSemiBold, size: 11.0))
                        }
                        .frame(width: boxSize, height: 100)
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray))
                    }
                }
            }

            if !idVerificationComplete && idCardImageData != nil && selfieImageData != nil {
                Button("Upload") {
                    Task {
                        await handleUpload()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 1))
    }
}
