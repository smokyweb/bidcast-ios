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
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var navigateToOTP = false
    @State private var navigateToAddCard = false
    @State private var showhud = false
    @State private var hudMsg = ""
    
    @State var cardDetails: CardDetails?
    @State var cardNumber : String?
    @State var expiry : String?
    @State var cvv : String?
    @State var cardTokenNumber : String?
    
    @State private var idVerificationComplete = false
    @State private var phoneVerificationComplete = false
    @State private var paymentMethodComplete = false
    @State private var manualVerificationComplete = false
    @State var navigateToProfile: Bool = false
    @State var getCard: Bool = false
    @State private var idCardImageData: Data?
    @State private var selfieImageData: Data?
    @State private var selectedIDCardItem: PhotosPickerItem?
    @State private var selfieImage: UIImage? = nil
    @State private var selfiePath: String? = nil
    
    @State private var showSelfieCamera: Bool = false
    @State private var showIDCardPicker: Bool = false
    @State var cardId : String = ""
    @State var cardArr = [PaymentProfile]()
    
    @State private var selectedCardIndex: Int? = nil
    
    var currentStep: Int {
        var count = 0
        if idVerificationComplete { count += 1 }
        if phoneVerificationComplete { count += 1 }
        if paymentMethodComplete { count += 1 }
        if manualVerificationComplete { count += 1 }
        return count
    }
    
    
    let totalSteps = 4.0
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var body: some View {
        VStack(spacing: 0) {
            VStack{
                PrimaryHeader(
                    title: AppString.SellerVerification,
                    isForLogo: false,
                    leadingImgArr: [.icBack],
                    trailingImgArr: [],
                    onClickLeading: { _ in self.presentationMode.wrappedValue.dismiss() },
                    count: .constant(0)
                )
            }
            
            if UserDefaults.sellerVerafied == "pending"{
                ReviewScreen(imageName: "verify", title: AppString.PendingVerification, content: "")
            }else{
                ScrollView {
                    VStack(spacing: 18) {
                        // Progress Bar
                        VStack(alignment: .leading) {
                            Text("Verification Progress")
                                .font(.custom(poppinsSemiBold, size: 13.0))
                                .foregroundColor(.gray)
                            
                            ProgressView(value: Double(UserDefaults.sellerVerafied == "verified" ? Int(totalSteps) : currentStep), total: totalSteps)
                                .accentColor(.defaultTheme)
                            
                            Text("\(UserDefaults.sellerVerafied == "verified" ? Int(totalSteps) : currentStep) of \(Int(totalSteps))")
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
                        .disabled(UserDefaults.sellerVerafied == "verified" ? true : false)
                        
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
                        .disabled(UserDefaults.sellerVerafied == "verified" ? true : false)
                        
                        // Payment Method
                        VerificationSectionView(
                            icon: "creditcard.fill",
                            title: "Payment Method",
                            subtitle: "Add your payment details",
                            status: paymentMethodComplete ? .completed : .pending,
                            actionLabel: UserDefaults.hasCardAdded ?  "Add" : "Add",
                            showDashedCard: getCard,
                            isActionEnabled: phoneVerificationComplete && !paymentMethodComplete,
                            onActionTap: {
//                                if UserDefaults.hasCardAdded{
//                                    Task{
//                                        SVProgressHUD.show()
//                                        await self.viewModel.getCard()
//                                        await SVProgressHUD.dismiss()
//                                        cardSuccess()
//                                        paymentMethodComplete = true
//                                        updateManualVerificationIfNeeded()
//                                    }
//                                }else{
                                    navigateToAddCard = true
//                                }
                            }
                        )
                        .disabled(UserDefaults.sellerVerafied == "verified" ? true : false)
                        
                        // Show Card or Empty View
                        if cardArr.count != 0 {
                            ForEach(0 ..< cardArr.count, id: \.self) { index in
                                let data = cardArr[index]
                                let card = data.payment?.creditCard
                                CardCell(
                                    image: "creditcard.fill",
                                    cardNo: card?.cardNumber ?? "",
                                    expires: "\(card?.expirationDate ?? "")/\(card?.expirationDate ?? "")",
                                    onTapCard : {
                                        selectedCardIndex = index
                                        self.cardId = self.cardArr[index].customerPaymentProfileId ?? ""
                                    },
                                    forSelect : true,
                                    isSelected:selectedCardIndex == index,
                                    isDefault: false
                                )
                            }
                            
                        }
                        
                        // Manual Verification
                        VerificationSectionView(
                            icon: "person.crop.circle.badge.checkmark",
                            title: "Manual Verification",
                            subtitle: "Final review by our team",
                            statusText: manualVerificationComplete ? "Pending" : "Verified",
                            textColor: UserDefaults.sellerVerafied == "verified" ? Color.defaultTheme : Color.gray
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
                .disabled(UserDefaults.sellerVerafied == "verified" ? true : false)
            }
        }
        .onAppear{
            if UserDefaults.sellerVerafied == "verified"{
                idVerificationComplete = true
                phoneVerificationComplete = true
                paymentMethodComplete = true
            }
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
        .fullScreenCover(isPresented: $showSelfieCamera) {
            ImagePicker(sourceType: .camera, onImagePicked: { image, path in
                if let image = image, let data = image.jpegData(compressionQuality: 0.6) {
                    selfieImage = image
                    selfieImageData = data
                    selfiePath = path
                }
            })
            .ignoresSafeArea()
        }
        .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                    if self.viewModel.errorMessage == "" || self.viewModel.errorMessage == nil{
                        self.presentationMode.wrappedValue.dismiss()
                        withAnimation { showError = false }
                    }else{
                        withAnimation { showError = false }
                    }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
        .background(Color.white)
        .navigationBarHidden(true)
        CusNavLink(doNavigate: $navigateToOTP,
                   destination: OTPVerificationScreen(viewModel: viewModel, onSuccess: {
            phoneVerificationComplete = true
            if UserDefaults.hasCardAdded{
                Task{
                    SVProgressHUD.show()
                    await viewModel.getCard()
                    await SVProgressHUD.dismiss()
                    cardSuccess()
                }
            }
            navigateToOTP = false
        }))
        
        CusNavLink(
            doNavigate: $navigateToAddCard,
            destination: AddCardScreen(
                isNavFrom: "SellerVerification",
                onSuccess: { cardId in
                    SVProgressHUD.show()
                    await viewModel.getCard()
                    await SVProgressHUD.dismiss()
                    cardSuccess()
                    //                    cardTokenNumber = cardToken
                    //                    self.cardDetails = CardDetails()
                    //                    self.cardId = cardId
                    //                    self.cardNumber = cardNumber
                    //                    self.expiry = expiry
                    //                    self.cvv = cvv
                    paymentMethodComplete = true
                    updateManualVerificationIfNeeded()
                }
            )
        )
        CusNavLink(doNavigate: $navigateToProfile, destination: AccountScreen())
    }
    
    //MARK: handleFinalUpload.
    func handleFinalUpload() async {
        guard let idData = idCardImageData,
              let selfieData = selfieImageData,
              let idURL = compressAndSaveImage(data: idData),
              let selfieURL = compressAndSaveImage(data: selfieData)
                //              let cardToken = cardTokenNumber
        else {
            //
            DispatchQueue.main.async {
                if idCardImageData == nil{
                    hudMsg = "Please Upload ID Card"
                }else if selfieImageData == nil{
                    hudMsg = "Please Upload Selfie"
                }
                showhud = true
            }
            return
        }
        
        guard phoneVerificationComplete == true else {
            hudMsg = "Please Verify Phone Number"
            showhud = true
            return
        }
        
        
        guard !cardId.isEmpty else {
            if UserDefaults.hasCardAdded{
                hudMsg = "Please Choose Payment Method"
            }else{
                hudMsg = "Please Add Payment Method"
            }
            showhud = true
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        DispatchQueue.main.async {
            hudMsg = "Uploading..."
            showhud = true
        }
        
        let params: [String: Any] = [
            "customerPaymentProfileId": cardId ,
            "phone_verification": phoneVerificationComplete == true ? 1 : 0
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
    func cardSuccess() {
        //        DispatchQueue.main.async{
        SVProgressHUD.dismiss()
        let response = viewModel.cardDict
        if response.status == "success" {
            cardArr = viewModel.cardDict.data?.paymentProfiles ?? [PaymentProfile]()
            if cardArr.count != 0{
                getCard = false
            }else{
                getCard = true
            }
        } else {
            showError = true
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
        //        }
    }
    
    //MARK: idUploadSuccess.
    func idUploadSuccess() {
        let response  = viewModel.sellerVerificationDict
        if viewModel.sellerVerificationDict?.status == "success" {
            hudMsg = "Seller Verification Successfully"
            UserDefaults.sellerVerafied = "pending"
//            navigateToProfile = true
            SVProgressHUD.dismiss()
            self.presentationMode.wrappedValue.dismiss()
            
        } else {
            SVProgressHUD.dismiss()
            hudMsg = "Seller Verification Failed"
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "Error",
                message: response?.message?.capitalized ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK"
            )
            showError = true
            paymentMethodComplete = true
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


struct ReviewScreen: View {
    var imageName: String = "verify"
    var title: String = "No Data Found"
    var content : String = "Under Processed"
    var yPosition = screenHeight/3
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 48) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray.opacity(0.6))
                VStack(alignment: .leading,spacing: 12){
                    Text(title)
                        .font(.custom(poppinsBold, size: 16))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                    
                    Text(content)
                        .font(.custom(poppinsRegular, size: 13))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y:yPosition )
        }
    }
}
