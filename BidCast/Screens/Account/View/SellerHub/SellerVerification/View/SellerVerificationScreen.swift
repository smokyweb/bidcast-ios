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
    @EnvironmentObject var deepLinkManager: DeepLinkManager
    @StateObject var viewModel = SellerVerificationViewModel()
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var navigateToOTP = false
    @State private var navigateToAddCard = false
    @State private var navigateToKYC = false
    @State private var showhud = false
    @State private var hudMsg = ""
    
    @State var cardDetails: CardDetails?
    @State var cardNumber: String?
    @State var expiry: String?
    @State var cvv: String?
    @State var cardTokenNumber: String?
    
    @State private var idVerificationComplete = false
    @State private var phoneVerificationComplete = false
    @State private var paymentMethodComplete = false
    @State private var manualVerificationComplete = false
    @State private var kycVerificationComplete = false
    @State private var kycStatus: String = "" // "active", "inactive", "pending"
    @State private var hasStartedKycFlow: Bool = false
    @State private var kycLink: String = ""
    
    @State var navigateToProfile: Bool = false
    @State var getCard: Bool = false
    @State private var idCardImageData: Data?
    @State private var selfieImageData: Data?
    @State private var selectedIDCardItem: PhotosPickerItem?
    @State private var selfieImage: UIImage? = nil
    @State private var selfiePath: String? = nil
    
    @State private var showSelfieCamera: Bool = false
    @State private var showIDCardPicker: Bool = false
    @State var cardId: String = ""
    @State var cardArr = [CardModel]()
    @State private var selectedCardIndex: Int? = nil
    
    @State var config: BottomSheetConfig = BottomSheetConfig(
        icon: "checkmark.seal.fill",
        title: "",
        message: "",
        primaryButtonTitle: "Okay",
        secondaryButtonTitle: nil,
        showButtons: true
    )
    
    @State private var isLoading = true
    @State var showError: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    // MARK: - Computed Properties
    var currentStep: Int {
          var count = 0
          if idVerificationComplete { count += 1 }
          if phoneVerificationComplete { count += 1 }
          if kycVerificationComplete { count += 1 }
          if paymentMethodComplete { count += 1 }
          return count
      }
      
      let totalSteps = 4.0
    
    private var phoneDetailText: String {
        let status = UserDefaults.sellerVerafied
        guard status == "pending" || status == "verified" || status == "processing" else { return "" }
        return viewModel.paymentDetailDict.data?.phoneNumber ?? ""
    }
    
    private var progressValue: Double {
        UserDefaults.sellerVerafied == "verified" ? totalSteps : Double(currentStep)
    }
    private var kycStatusMessage: String {
          switch kycStatus.lowercased() {
          case "active":
              return "KYC verified successfully"
          case "pending":
              return "KYC verification is pending. Please wait for approval."
          case "inactive":
              return "KYC verification failed. Please try again."
          default:
              return ""
          }
      }
      
      private var kycStatusColor: Color {
          switch kycStatus.lowercased() {
          case "active":
              return .green
          case "pending":
              return .orange
          case "inactive":
              return .red
          default:
              return .gray
          }
      }
    
    private var canCompleteVerification: Bool {
            return idVerificationComplete &&
                   phoneVerificationComplete &&
                   kycVerificationComplete &&
                   kycStatus.lowercased() == "active" &&
                   paymentMethodComplete &&
                   manualVerificationComplete
        }
    
    private var isSellerVerificationSubmittedOrApproved: Bool {
        let status = UserDefaults.sellerVerafied.lowercased()
        return status == "pending" || status == "verified"
    }
    
    private var isSellerVerificationEditable: Bool {
        // ✅ Only pending/verified are read-only. Anything else can be edited.
        return !isSellerVerificationSubmittedOrApproved
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            headerView
            contentView
            navigationLinks
        }
        .background(Color.backGround)
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarHidden(true)
        .onFirstAppear {
            fetchSellerStatus()
        }
       
        .onReceive(deepLinkManager.$destination) { destination in
            guard let destination else { return }

            if case .kycResult = destination {
                // ✅ App returned from KYC
                if hasStartedKycFlow {
                    checkKYCStatus()
                }
                deepLinkManager.clearDestination()
            }
        }
        .onReceive(NotificationCenter.default.publisher(
            for: UIApplication.willEnterForegroundNotification
        )) { _ in
            if hasStartedKycFlow {
                checkKYCStatus()
            }
        }

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
        .overlay(
            CustomBottomSheetView(
                isPresented: $showError,
                config: config,
                primaryAction: { withAnimation { showError = false } },
                secondaryAction: { withAnimation { showError = false } }
            )
        )
        
    }
    
    // MARK: - Content View
    private var contentView: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                progressSection
                verificationCards
            }
            .padding(.top, 20)
            .padding(.bottom, 30)
            .padding(.horizontal, 16)
        }
        .background(Color.backGround)
    }
    
    private var verificationCards: some View {
        VStack(spacing: 16) {
            FinalIDVerificationCard(
                idCardImageData: $idCardImageData,
                selfieImageData: $selfieImageData,
                showIDCardPicker: $showIDCardPicker,
                showSelfieCamera: $showSelfieCamera,
                idVerificationComplete: $idVerificationComplete,
                handleUpload: {
//                    await handleFinalUpload()
                    idVerificationComplete = true
                }
            )
            .disabled(!isSellerVerificationEditable)
            
            FinalVerificationCard(     
                iconName: "call",
                iconBackground: .defaultThemeLight,
                title: "Phone Verification",
                subtitle: "Verify your phone number",
                detailText: phoneDetailText,
                isCompleted: phoneVerificationComplete,
                actionLabel: "Verify",
                isActionEnabled: idVerificationComplete && !phoneVerificationComplete,
                onActionTap: { navigateToOTP = true }
            )
            .disabled(!isSellerVerificationEditable)
            
            FinalKYCVerificationCard(
                            isCompleted: kycVerificationComplete,
                            kycStatus: kycStatus,
                            statusMessage: kycStatusMessage,
                            statusColor: kycStatusColor,
                            isActionEnabled: isSellerVerificationSubmittedOrApproved ? true : (phoneVerificationComplete && !kycVerificationComplete),
                            onVerifyTap: {
                                Task {
                                    if isSellerVerificationSubmittedOrApproved {
                                        // Pending/verified: do nothing (read-only screen)
                                        return
                                    } else {
                                        hasStartedKycFlow = true
                                        if kycLink.isEmpty {
                                            await fetchKycLinkSilently()
                                        }
                                        openKYCInBrowser(url: kycLink)
                                    }
                                }
                            }
                        )
                        .disabled(isSellerVerificationEditable && !phoneVerificationComplete)
                        .opacity(isSellerVerificationEditable && !phoneVerificationComplete ? 0.5 : 1.0)
                        
            
            FinalPaymentMethodCard(
                isCompleted: paymentMethodComplete,
                cardArr: cardArr,
                selectedCardIndex: $selectedCardIndex,
                isActionEnabled: phoneVerificationComplete && !paymentMethodComplete,
                isPending: UserDefaults.sellerVerafied == "pending" || UserDefaults.sellerVerafied == "verified",
                allowAddCard: isSellerVerificationEditable,
                onAddCard: { navigateToAddCard = true },
                onSelectCard: { index in
                    selectedCardIndex = index
                    self.cardId = self.cardArr[index].card_id ?? ""
                    paymentMethodComplete = !cardId.isEmpty
                    updateManualVerificationIfNeeded()
                }
            )
            .disabled(!isSellerVerificationEditable)
            .opacity(isSellerVerificationEditable && (!phoneVerificationComplete || kycStatus.lowercased() != "active") ? 0.5 : 1.0)
            
            FinalVerificationCard(
                iconName: "verify",
                iconBackground: Color.defaultThemeLight,
                title: "Manual Verification",
                subtitle: "Final review by our team",
                statusText: viewModel.paymentDetailDict.data?.status?.capitalizingFirstLetter() ?? "",
                textColor: UserDefaults.sellerVerafied == "verified" ? Color.green : Color.gray,
                isCompleted: UserDefaults.sellerVerafied == "verified"
            )
            
            if isSellerVerificationEditable {
                completeVerificationButton
            }
        }
    }
    
    private var completeVerificationButton: some View {
           Button(action: {
               guard isSellerVerificationEditable else { return }
               
               guard phoneVerificationComplete else {
                   hudMsg = "Please verify phone number first"
                   showhud = true
                   return
               }
               
               guard kycVerificationComplete else {
                   hudMsg = "Please complete KYC verification"
                   showhud = true
                   return
               }
               
               guard kycStatus.lowercased() == "active" else {
                   if kycStatus.lowercased() == "pending" {
                       hudMsg = "KYC verification is pending. Please wait for approval."
                   } else {
                       hudMsg = "KYC verification is not active. Please complete KYC first."
                   }
                   showhud = true
                   return
               }
               
               Task { await handleFinalUpload() }
           }) {
               Text("Complete Verification")
                   .font(.custom(poppinsSemiBold, size: 16))
                   .foregroundColor(.white)
                   .frame(maxWidth: .infinity)
                   .padding()
                   .background(canCompleteVerification ? Color.defaultTheme : Color.gray)
                   .cornerRadius(32)
           }
           .padding()
           .disabled(!canCompleteVerification || UserDefaults.sellerVerafied == "verified")
       }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button { presentationMode.wrappedValue.dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Text("Seller Verification")
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.primary)
            
            Spacer()
            
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Verification Progress")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(UserDefaults.sellerVerafied == "verified" ? Int(totalSteps) : currentStep) of \(Int(totalSteps))")
                    .font(.custom(poppinsBold, size: 16))
                    .foregroundColor(.primary)
            }
            
            ProgressView(value: progressValue, total: totalSteps)
                .accentColor(.green)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentStep)
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Navigation Links
    private var navigationLinks: some View {
        Group {
            CusNavLink(doNavigate: $navigateToOTP, destination: OTPVerificationScreen(viewModel: viewModel, onSuccess: {
                phoneVerificationComplete = true
               
                // Fetch KYC link silently so "Verify" button can open browser,
                // but do not evaluate/show KYC status until user taps Verify.
                Task { await fetchKycLinkSilently() }
                navigateToOTP = false
            }))
            
            
            CusNavLink(doNavigate: $navigateToAddCard, destination: AddCardScreen(
                isNavFrom: "SellerVerification",
                onSuccess: { cardId in
                    SVProgressHUD.show()
                    Task {
                        await viewModel.getCard()
                        await SVProgressHUD.dismiss()
                        cardSuccess()
                        paymentMethodComplete = true
                        updateManualVerificationIfNeeded()
                    }
                }
            ))
            
            CusNavLink(doNavigate: $navigateToProfile, destination: AccountScreen())
        }
    }
    func openKYCInBrowser(url:String) {
           
            let kycURLString = url // Replace with actual URL
            
            if let url = URL(string: kycURLString) {
                UIApplication.shared.open(url) { success in
                    if success {
                        // URL opened successfully
                    } else {
                        self.hudMsg = "Failed to open KYC verification"
                        self.showhud = true
                    }
                }
            } else {
                hudMsg = "Invalid KYC URL"
                showhud = true
            }
        }
    
    func checkKYCStatus(forVerified : Bool = false) {
           Task {
               SVProgressHUD.show()
               await viewModel.checkKycDetail()
               await SVProgressHUD.dismiss()
               if viewModel.errorMessage == "" || viewModel.errorMessage == nil{
                   // Always keep latest KYC link cached for Verify button.
                   let link = viewModel.checkKycDict.data?.link ?? ""
                   if !link.isEmpty {
                       kycLink = link
                   }
                  
                   successKyC(forVerified: forVerified)
               }else{
                   print(viewModel.errorMessage ?? "")
               }
               
           }
       }

    @MainActor
    private func fetchKycLinkSilently() async {
        await viewModel.checkKycDetail()
        if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
            let link = viewModel.checkKycDict.data?.link ?? ""
            if !link.isEmpty {
                kycLink = link
            }
        }
        // Do NOT update kycStatus / kycVerificationComplete here.
    }
    func successKyC(forVerified: Bool = false) {
        let response = viewModel.checkKycDict

        guard response.status == "success" else { return }

        
        let status = response.data?.kycStatus ?? ""
        
        kycStatus = status
        
        if status.lowercased() == "active" {
            kycVerificationComplete = true
            if !forVerified {
                hudMsg = "KYC verified successfully"
            }
            if !forVerified, isSellerVerificationEditable {
                // ✅ In rejected / not-applied flow: after KYC is verified, always fetch cards.
                Task {
                    SVProgressHUD.show()
                    await viewModel.getCard()
                    await SVProgressHUD.dismiss()
                    cardSuccess()
                    // Do NOT mark payment complete until user selects a card (or adds a new one).
                    paymentMethodComplete = false
                }
            }
        } else if status.lowercased() == "pending" {
            // cmpbefoal00043ghgyp9byme4 #43: Stripe Identity doesn't immediately
            // return "active" after the user completes the KYC flow — it returns
            // "pending" first.  Keeping kycVerificationComplete=false causes the
            // "Verify" button to re-appear, misleading the user into thinking they
            // haven't submitted yet.  "pending" means the user DID submit; show the
            // checkmark and let the status message explain it's under review.
            kycVerificationComplete = true
            if !forVerified {
                hudMsg = "KYC verification is pending. Please wait for approval."
                showhud = true
            }
        } else {
            kycVerificationComplete = false
            if !forVerified {
                hudMsg = "KYC verification inactive."
                showhud = true
            }
        }
        
        
    }
    // MARK: - API / Helpers (same as your code)
    func fetchSellerStatus() {
        Task {
            SVProgressHUD.show()
            self.viewModel.errorMessage?.removeAll()
            await self.viewModel.fetchSellerPaymentDetail()
            await SVProgressHUD.dismiss()
            
            withAnimation { isLoading = false }
            
            if self.viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                success()
            } else {
                config = BottomSheetConfig(
                       icon: "exclamationmark.circle",
                       title: "Error",
                       message: self.viewModel.errorMessage ?? "",
                       primaryButtonTitle: nil,
                       secondaryButtonTitle: AppString.ok.localized
                   )
                showError = true
            }
        }
    }
    
    func handleFinalUpload() async {
        guard let idData = idCardImageData,
              let selfieData = selfieImageData,
              let idURL = compressAndSaveImage(data: idData),
              let selfieURL = compressAndSaveImage(data: selfieData)
        else {
            DispatchQueue.main.async {
                if idCardImageData == nil {
                    hudMsg = "Please Upload ID Card"
                } else if selfieImageData == nil {
                    hudMsg = "Please Upload Selfie"
                }
                showhud = true
            }
            return
        }
        
        guard phoneVerificationComplete else {
            hudMsg = "Please Verify Phone Number"
            showhud = true
            return
        }
        
        guard !cardId.isEmpty else {
            hudMsg = UserDefaults.hasCardAdded ? "Please Choose Payment Method" : "Please Add Payment Method"
            showhud = true
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        
        SVProgressHUD.show()
        
        let params: [String: Any] = [
            "card_id": cardId,
            "phone_verification": phoneVerificationComplete ? 1 : 0
        ]
        
        let images = [[idURL.path], [selfieURL.path]]
        let keys = ["id_card", "image"]
        let mime = ["image/jpeg", "image/jpeg"]
        
        await viewModel.SellerVerification(
            parameters: params,
            images: images,
            mimeType: mime,
            keysValue: keys
        )
        
        DispatchQueue.main.async { idUploadSuccess() }
    }
    
   
    private func updateManualVerificationIfNeeded() {
            if idVerificationComplete &&
               phoneVerificationComplete &&
               kycVerificationComplete &&
               kycStatus.lowercased() == "active" &&
               paymentMethodComplete &&
               !manualVerificationComplete {
                manualVerificationComplete = true
            }
        }
    
    func cardSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.cardDict
        if response.status == "success" {
            cardArr = viewModel.cardDict.data ?? [CardModel]()
            getCard = cardArr.isEmpty
        } else {
            config = BottomSheetConfig(
                icon: "exclamationmark.circle",
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryButtonTitle: nil,
                secondaryButtonTitle: AppString.ok.localized
            )
            showError = true
        }
    }
    
    func success() {
        let response = self.viewModel.paymentDetailDict
        if response.status == "success" {
            UserDefaults.sellerVerafied = response.data?.status ?? ""
            if isSellerVerificationSubmittedOrApproved {
                idVerificationComplete = true
                phoneVerificationComplete = true
                paymentMethodComplete = true
                let idCardURL = response.data?.idCard ?? ""
                let selfieURL = response.data?.image ?? ""
                loadImages(url: idCardURL, selfieUrl: selfieURL)
                if response.data?.cardDetails != nil{
                    if  !(UserDefaults.sellerVerafied.isEmpty || UserDefaults.sellerVerafied == "rejected"){
                        self.cardArr.removeAll()
                        let cardDetail = CardModel(exp_month: response.data?.cardDetails?.expMonth ?? 0,
                                                   last4: "**** **** **** \(response.data?.cardDetails?.last4 ?? "")",
                                                   exp_year: response.data?.cardDetails?.expYear ?? 0)
                        self.cardArr.append(cardDetail)
                    }
                }
                // Keep KYC link ready, but don't evaluate/show KYC status until user taps Verify.
                Task { await fetchKycLinkSilently() }
            } else if isSellerVerificationEditable {
                // ✅ "processing" (in-progress) or not-applied/rejected: prefill what we already have.
                let idCardURL = response.data?.idCard ?? ""
                let selfieURL = response.data?.image ?? ""
                if !idCardURL.isEmpty || !selfieURL.isEmpty {
                    loadImages(url: idCardURL, selfieUrl: selfieURL)
                }
                idVerificationComplete = !idCardURL.isEmpty && !selfieURL.isEmpty
                phoneVerificationComplete = (response.data?.numberOtpVerified ?? 0) == 1
                
                // If backend already has a card stored, show it as selected.
                if let cardDetails = response.data?.cardDetails,
                   let last4 = cardDetails.last4,
                   !last4.isEmpty {
                    self.cardArr.removeAll()
                    self.cardArr.append(
                        CardModel(
                            exp_month: cardDetails.expMonth ?? 0,
                            card_id: response.data?.cardID,
                            last4: "**** **** **** \(last4)",
                            exp_year: cardDetails.expYear ?? 0
                        )
                    )
                    selectedCardIndex = 0
                    cardId = response.data?.cardID ?? ""
                    paymentMethodComplete = !cardId.isEmpty
                } else {
                    paymentMethodComplete = false
                }
                
                // Keep KYC link ready once phone is verified.
                if phoneVerificationComplete {
                    Task { await fetchKycLinkSilently() }
                }
            } else {
                idVerificationComplete = false
                phoneVerificationComplete = false
                kycVerificationComplete = false
                paymentMethodComplete = false
            }
        } else {
            config = BottomSheetConfig(
                   icon: "exclamationmark.circle",
                   title: "Error",
                   message: self.viewModel.errorMessage ?? "",
                   primaryButtonTitle: nil,
                   secondaryButtonTitle: AppString.ok.localized
               )
            showError = true
        }
    }
    
    func loadImages(url: String, selfieUrl: String) {
        loadImageData(from: url) { data in
            DispatchQueue.main.async {
                idCardImageData = data
            }
        }
        
        loadImageData(from: selfieUrl) { data in
            DispatchQueue.main.async {
                selfieImageData = data
            }
        }
    }
    
    func loadImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to load image: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(data)
            }
        }.resume()
    }
    
    func idUploadSuccess() {
        let response = viewModel.sellerVerificationDict
        if viewModel.sellerVerificationDict?.status == "success" {
            hudMsg = "Seller Verification Successfully"
            showhud = true
            UserDefaults.sellerVerafied = "pending"
            SVProgressHUD.dismiss()
            self.fetchSellerStatus()
        } else {
            SVProgressHUD.dismiss()
            config = BottomSheetConfig(
                icon: "exclamationmark.circle",
                title: "Error",
                message: viewModel.errorMessage ?? "",
                primaryButtonTitle: nil,
                secondaryButtonTitle: AppString.ok
            )
            showError = true
        }
       
    }
    
}

//MARK: KYC
struct FinalKYCVerificationCard: View {
    let isCompleted: Bool
    let kycStatus: String
    let statusMessage: String
    let statusColor: Color
    let isActionEnabled: Bool
    var onVerifyTap: @MainActor () -> Void = { }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.defaultThemeLight)
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "checkmark.seal")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color.defaultTheme)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("KYC Verification")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black)
                    
                    if !isCompleted && kycStatus.isEmpty {
                        Text("Complete KYC to proceed")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                    }
                    
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.custom(poppinsMedium, size: 13))
                            .foregroundColor(statusColor)
                    }
                }
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                } else if isActionEnabled {
                    Button(action: onVerifyTap) {
                        Text("Verify")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.defaultTheme)
                            )
                    }
                }
            }
            
//            // Add "Check Status" button if KYC is pending or not completed
//            if !isCompleted && !kycStatus.isEmpty {
//                Button(action: onVerifyTap) {
//                    HStack {
//                        Image(systemName: "arrow.clockwise")
//                            .font(.system(size: 12))
//                        Text("Check KYC Status")
//                            .font(.custom(poppinsMedium, size: 13))
//                    }
//                    .foregroundColor(.defaultTheme)
//                    .padding(.vertical, 8)
//                    .padding(.horizontal, 12)
//                    .background(
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.defaultThemeLight)
//                    )
//                }
//            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}
// MARK: - Final ID Verification Card
struct FinalIDVerificationCard: View {
    @Binding var idCardImageData: Data?
    @Binding var selfieImageData: Data?
    @Binding var showIDCardPicker: Bool
    @Binding var showSelfieCamera: Bool
    @Binding var idVerificationComplete: Bool
    @State private var isLoadingIDCard: Bool = false
    @State private var isLoadingSelfie: Bool = false
    let handleUpload: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.defaultThemeLight)
                        .frame(width: 48, height: 48)
                    
                    Image("profileCard")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(Color.defaultTheme)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Id Verification")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.primary)
                    if !idVerificationComplete {
                        Text("Upload your ID card & take a selfie")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if idVerificationComplete {
                    ZStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.green)
                    }
                }
            }
            
            let boxSize = (UIScreen.main.bounds.width - 64) / 2
            
            HStack(spacing: 12) {
                // ID Card Image
                Button(action: {
                    if !isLoadingIDCard {
                        showIDCardPicker = true
                    }
                }) {
                    ZStack {
                        if let idData = idCardImageData, let uiImage = UIImage(data: idData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: boxSize, height: 120)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "person.text.rectangle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                
                                Text("ID Card")
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: boxSize, height: 120)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        }
                        
                        // Loading indicator for ID Card
                        if isLoadingIDCard {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                                .frame(width: boxSize, height: 120)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }
                    }
                }
                .disabled(isLoadingIDCard)
                
                // Selfie Image
                Button(action: {
                    if !isLoadingSelfie {
                        showSelfieCamera = true
                    }
                }) {
                    ZStack {
                        if let selfieData = selfieImageData, let uiImage = UIImage(data: selfieData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: boxSize, height: 120)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                                
                                Text("Selfie")
                                    .font(.custom(poppinsSemiBold, size: 13))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: boxSize, height: 120)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        }
                        
                        // Loading indicator for Selfie
                        if isLoadingSelfie {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.4))
                                .frame(width: boxSize, height: 120)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.2)
                        }
                    }
                }
                .disabled(isLoadingSelfie)
            }
            
            if !idVerificationComplete && idCardImageData != nil && selfieImageData != nil {
                Button(action: {
                    Task {
                        await handleUpload()
                    }
                }) {
                    Text("Upload")
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.defaultTheme)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("IDCardLoadingState"))) { notification in
            if let isLoading = notification.object as? Bool {
                isLoadingIDCard = isLoading
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("SelfieLoadingState"))) { notification in
            if let isLoading = notification.object as? Bool {
                isLoadingSelfie = isLoading
            }
        }
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
                    if !idVerificationComplete {
                        Text("Upload your ID card & take a selfie")
                            .font(.custom(poppinsRegular, size: 13.0))
                            .foregroundColor(.gray)
                    }
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
        .background(RoundedRectangle(cornerRadius: 16).stroke(Color.defaultTheme, lineWidth: 1))
    }
}

// MARK: - Final Verification Card
struct FinalVerificationCard: View {
    let iconName: String // Asset name
    let iconBackground: Color
    let title: String
    let subtitle: String
    var statusText: String = ""
    var detailText: String = ""
    var textColor: Color = .gray
    var isCompleted: Bool = false
    var actionLabel: String = "Verify"
    var isActionEnabled: Bool = false
    var onActionTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Asset Image with Background
            ZStack {
                Circle()
                    .fill(Color.defaultThemeLight)
                    .frame(width: 48, height: 48)
                
                Image(iconName) // Asset name
                    .resizable()
                    .renderingMode(.template)
                    .scaledToFit()
                    .foregroundColor(Color.defaultTheme)
                    .frame(width: 24, height: 24)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.primary)
                
                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.custom(poppinsMedium, size: 13))
                        .foregroundColor(textColor)
                } else {
                    if !isCompleted {
                        Text(subtitle)
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                if !detailText.isEmpty {
                                   Text(detailText)
                                       .font(.custom(poppinsBold, size: 13))
                                       .foregroundColor(.gray)
                               }
            }
            
            Spacer()
            
            if isCompleted {
                ZStack {
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.green)
                }
            } else if let action = onActionTap, isActionEnabled {
                Button(action: action) {
                    Text(actionLabel)
                        .font(.custom(poppinsSemiBold, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.defaultTheme)
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Final Payment Method Card
struct FinalPaymentMethodCard: View {
    let isCompleted: Bool
    let cardArr: [CardModel]
    @Binding var selectedCardIndex: Int?
    let isActionEnabled: Bool
    let isPending: Bool
    let allowAddCard: Bool
    let onAddCard: () -> Void
    let onSelectCard: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.defaultThemeLight)
                        .frame(width: 48, height: 48)
                    
                    Image("card") // Asset name
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .foregroundColor(Color.defaultTheme)
                        .frame(width: 24, height: 24)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Payment Method")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black)
                    if !isCompleted {
                        Text("Add your payment details")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if allowAddCard && (isActionEnabled || isCompleted || !cardArr.isEmpty) {
                    Button(action: onAddCard) {
                        Text("Add")
                            .font(.custom(poppinsSemiBold, size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.defaultTheme)
                            )
                    }
                }
            }
            
            // Card List
            if !cardArr.isEmpty && (isPending || isCompleted || isActionEnabled) {
                VStack(spacing: 12) {
                    ForEach(Array(cardArr.enumerated()), id: \.offset) { index, card in
                        FinalPaymentMethodRow(
                            isPending:isPending,
                            cardNumber: "**** **** **** \(card.last4 ?? "****")",
                            isSelected: /*(isPending || isCompleted) ? true :*/ selectedCardIndex == index,
                            onTap: {
                                onSelectCard(index)
                            }
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Final Payment Method Row (Matching Screenshot)
struct FinalPaymentMethodRow: View {
    let isPending : Bool
    let cardNumber: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // VISA Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: 48, height: 32)
                    
                    Text("VISA")
                        .font(.custom(poppinsBold, size: 12))
                        .foregroundColor(.white)
                }
                
                // Card Number (Format: XXXX4242)
                let lastFour = String(cardNumber.suffix(4))
                Text("**** **** \(lastFour)")
                    .font(.custom(poppinsSemiBold, size: 15))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Radio Button
                if !isPending{
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.defaultTheme : Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 24, height: 24)
                        
                        if isSelected {
                            Circle()
                                .fill(Color.defaultTheme)
                                .frame(width: 14, height: 14)
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
}
