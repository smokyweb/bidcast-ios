//
//  TrustedBuyerScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//
import SwiftUI
import _PhotosUI_SwiftUI
import AlertToast
import SVProgressHUD
import UIKit

struct TrustedBuyerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel = TrustedBuyerViewModel()
    @State var navigateToProfile: Bool = false
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var showhud = false
    @State private var hudMsg = ""

    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uploadedImage: Image? = nil
    @State private var isPhotoSelected = false
    @State var navigateToCreateAddress = false
    @State var imageURL = ""
    @State var SavedImageURL = ""

    @State private var isVerified = false
    @State private var showImageSourceActionSheet = false
    @State private var showImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    @Binding var comeFromHome : Bool

    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: "Trusted Buyer".localized,
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { index in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // MARK: - Step Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .resizable()
                            .frame(width: 60, height: 50)
                            .foregroundColor(.defaultTheme)
                        
                        Text(isVerified ? "Identity Verification Submitted" : "Verify Your Identity")
                            .font(.custom(poppinsSemiBold, size: 13))
                        
                        Text(
                            isVerified
                            ? "Your identity has already been submitted for verification. We’re reviewing your details to make you a Trusted Buyer."
                            : "To become a Trusted Buyer, we need to verify your identity. This helps create a safe trading environment."
                        )
                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Step Indicator
                    HStack(spacing: 0) {
                        StepCircle(step: "1", label: "Upload", isActive: isVerified)
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                        StepCircle(step: "2", label: "Review", isActive: isVerified)
                        Rectangle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                        StepCircle(step: "3", label: "Verified", isActive: isVerified)
                    }
                    .padding(.horizontal, 12)
                    
                    // MARK: - Upload Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text(isVerified ? "ID Already Verified" : "Upload ID Photo")
                            .font(.custom(poppinsSemiBold, size: 13))
                        
                        Text(
                            isVerified
                            ? "Your ID has already been uploaded and is under review."
                            : "Please upload a clear photo of your valid government-issued ID (driver’s license or passport)."
                        )                            .font(.custom(poppinsRegular, size: 12))
                            .foregroundColor(.gray)
                        
                        VStack(spacing: 12) {
                            if let image = uploadedImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            }
                            else if isVerified {
                                VStack(spacing: 8) {
                                    CustomProfileImage(
                                        url: SavedImageURL,
                                        isCircular: false,
                                        size: .infinity,
                                        height: 150
                                    )
                                    .cornerRadius(8)

                                    Spacer()
                                }
                            }

                            else {
                                VStack(spacing: 8) {
                                    Image(systemName: "idcard")
                                        .resizable()
                                        .frame(width: 40, height: 30)
                                        .foregroundColor(.gray)
                                    Text("Tap to upload your ID photo")
                                        .font(.custom(poppinsRegular, size: 11))
                                        .foregroundColor(.gray)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 150)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                            
                            if !isVerified{
                                Button {
                                    showImageSourceActionSheet = true
                                } label: {
                                    Text("Choose File")
                                        .font(.custom(poppinsBold, size: 11))
                                        .padding()
                                        .frame(width: 150)
                                        .background(.defaultTheme)
                                        .foregroundColor(.white)
                                        .cornerRadius(75)
                                }
                                .frame(width: 150)
                            }
                            //                            .onChange(of: selectedPhoto) { newItem in
                            //                                Task {
                            //                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                            //                                       let uiImage = UIImage(data: data) {
                            //                                        uploadedImage = Image(uiImage: uiImage)
                            //                                        isPhotoSelected = true
                            //                                    }
                            //                                }
                            //                            }
                        }
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                    .padding(.horizontal, 12)
                    
                    // MARK: - Requirements Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .padding(.bottom, 8)
                        
                        requirementItem("Government-issued ID (driver’s license or passport)")
                        requirementItem("Clear, well-lit photo")
                        requirementItem("All corners visible")
                        requirementItem("Verification usually takes 3 business days")
                    }
                    .foregroundColor(.black)   // 👈 makes all text black
                    .padding(16)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                    .padding(.horizontal, 12)
                    
                    if !isVerified{

                    // MARK: - Submit Button
                    Button(action: handleSubmit) {
                        Text("Submit for Review")
                            .font(.custom(poppinsSemiBold, size: 13))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPhotoSelected ? Color.defaultTheme : Color.gray.opacity(0.4))
                            .foregroundColor(.white)
                            .cornerRadius(32)
                    }
                    .disabled(!isPhotoSelected)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 32)
                }
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color.backGround)


            CusNavLink(doNavigate: $navigateToProfile, destination: AccountScreen())
        }
        .onAppear {
            Task {
                SVProgressHUD.show()
                await viewModel.getBuyerVerificationStatus()
                await SVProgressHUD.dismiss()
                handleSuccessTrusted()
            }
        }


        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(sourceType: imagePickerSourceType) { image,url  in
                if let image = image {
                    uploadedImage = Image(uiImage: image)
                    self.imageURL = url ?? ""
                    isPhotoSelected = true
                }
            }
            .ignoresSafeArea()
        }
        .actionSheet(isPresented: $showImageSourceActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                message: Text("Choose a source"),
                buttons: [
                    .default(Text("Take Photo")) {
                        imagePickerSourceType = .camera
                        showImagePicker = true
                    },
                    .default(Text("Photo Library")) {
                        imagePickerSourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel()
                ]
            )
        }
        .onAppear { UIScrollView.appearance().bounces = false }
        .onDisappear { UIScrollView.appearance().bounces = true }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 3.3,
            topBarCornerRadius: 25,
            showTopIndicator: false,onDismiss: {
                showError = true
            }
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation(.snappy) {
                        if  comeFromHome == false{
                            self.presentationMode.wrappedValue.dismiss()
                        }else{
                            comeFromHome = false
                        }
                        
                        showError = false
                    }
                },
                onSecondaryClick: {
                    withAnimation {
                        showError = false
                    }
                }
            )
        }
    }

    // MARK: - Submit Handler
    func handleSubmit() {
//        guard let selectedPhoto else { return }
        guard  !imageURL.isEmpty else{
            hudMsg = "Please select image"
            showhud = true
            return
        }
        
        Task {
    
//                let imageData = try await selectedPhoto.loadTransferable(type: Data.self)
//                guard let data = imageData, !data.isEmpty else { return }
//
//                let imageURL = compressAndSaveImage(data: data) ?? saveImageToTemporaryDirectory(data: data)
//                guard let path = imageURL?.path else { return }
           guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
                SVProgressHUD.show()
            await viewModel.addTrustedBuyer(images: [imageURL], key: "image")
                await SVProgressHUD.dismiss()
            if self.viewModel.errorMessage == nil || self.viewModel.errorMessage == ""{
                handleSuccess()
            }else{
                alertType = .sheetType(
                    icon: .alert,
                    title: "Error",
                    message: viewModel.errorMessage ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
                showError = true
            }
//            } catch {
//                print("❌ Failed to load image:", error)
//            }
        }
    }

    func requirementItem(_ text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.defaultThemeLight)
            Text(text)
                .font(.custom(poppinsRegular, size: 12))
                .foregroundColor(.black)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    func handleSuccessTrusted() {
        let response = viewModel.getBuyerVerificationStatusDict

        if response.status == "success" {
            SavedImageURL = response.data?.image ?? ""
            let status = response.data?.status
            isVerified = (status == "pending" || status == "verified")
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response.error_type?.capitalized ?? "",
                message: response.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
            showError = true
        }
    }

    
    func handleSuccess() {
        SVProgressHUD.dismiss()
        let response = viewModel.addTrustedBuyerDict
        if response?.status == "success" {
            alertType = .sheetType(
                icon: .success,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: AppString.ok.localized,
                secondaryBtnText: ""
            )
        } else {
            alertType = .sheetType(
                icon: .alert,
                title: response?.error_type?.capitalized ?? "",
                message: response?.message?.capitalized ?? "",
                primaryBtnText: "",
                secondaryBtnText: AppString.ok.localized
            )
        }
        showError = true
    }
}

//#Preview {
//    TrustedBuyerScreen()
//}
