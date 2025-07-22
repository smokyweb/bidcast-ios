//
//  SellerVerificationScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//


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
    @State var cardNumber : String?
    @State var cardTokenNumber : String?
    
    @State private var idVerificationComplete = false
    @State private var phoneVerificationComplete = false
    @State private var paymentMethodComplete = false
    @State private var manualVerificationComplete = false
    @State var navigateToProfile: Bool = false
    
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
                            .accentColor(.defaultTheme)
                        
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
                            idVerificationComplete = true
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
//                        Text("No Payment Method Found")
//                            .font(.custom(poppinsSemiBold, size: 13.0))
//                            .foregroundColor(.gray)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Manual Verification
                    VerificationSectionView(
                        icon: "person.crop.circle.badge.checkmark",
                        title: "Manual Verification",
                        subtitle: "Final review by our team",
                        statusText: manualVerificationComplete ? "Pending" : "Pending"
                    )
                }
                .padding()
            }

            // Final Button
            Button(action: {
                Task{
                    await handleFinalUpload()
                }
               
            }) {
                Text("Complete Verification")
                     .font(.custom(poppinsSemiBold, size: 16.0))
                     .foregroundColor(.white)
                     .frame(maxWidth: .infinity)
                     .padding()
                     .background(manualVerificationComplete ? Color.defaultTheme : Color.gray)
                     .cornerRadius(16)
            }
            .padding()
//            .disabled(!manualVerificationComplete)
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
            destination: AddCardScreen(
                isNavFrom: "SellerVerification",
                onSuccess: { cardToken in
                    cardTokenNumber = cardToken
                    paymentMethodComplete = true
                    updateManualVerificationIfNeeded()
                }
            )
        )
        CusNavLink(doNavigate: $navigateToProfile, destination: AccountScreen())
    }
    
    //MARK: handleFinalUpload.
    func handleFinalUpload() async {
        SVProgressHUD.show()
        guard let idData = idCardImageData,
              let selfieData = selfieImageData,
              let idURL = compressAndSaveImage(data: idData),
              let selfieURL = compressAndSaveImage(data: selfieData),
              let cardToken = cardTokenNumber else {
            
            DispatchQueue.main.async {
                hudMsg = "Missing required data"
                showhud = true
            }
            return
        }
        
        DispatchQueue.main.async {
            hudMsg = "Uploading..."
            showhud = true
        }
        
        let params: [String: Any] = [
            "cardToken": cardToken,
            "phone_verification": phoneVerificationComplete == true ? 0 : 1
        ]
        print("Seller Verification Param : \(params)")
        
        let images = [[idURL.path], [selfieURL.path]]
        let keys = ["id_card", "image"]
        let mime = ["image/jpeg", "image/jpeg"]
        
        await viewModel.SellerVerification(
            parameters: params,
            images: images,
            mimeType: mime,
            keysValue: keys
        )
        
        DispatchQueue.main.async {
            idUploadSuccess()
        }
    }

    //MARK: idUploadSuccess.
    func idUploadSuccess() {
        if viewModel.sellerVerificationDict?.status == "success" {
            hudMsg = "Seller Verification Successfully"
            navigateToProfile = true
            SVProgressHUD.dismiss()
            
        } else {
            SVProgressHUD.dismiss()
            hudMsg = "Seller Verification Failed"
        }
        showhud = true
    }
    
    //MARK: updateManualVerificationIfNeeded.
    private func updateManualVerificationIfNeeded() {
        if idVerificationComplete && phoneVerificationComplete && paymentMethodComplete && !manualVerificationComplete {
            manualVerificationComplete = true
        }
    }
    
    //MARK: successPaymentDetail.
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

//MARK: IDVerificationCard.
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
                    .background(.darkGreen)
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
