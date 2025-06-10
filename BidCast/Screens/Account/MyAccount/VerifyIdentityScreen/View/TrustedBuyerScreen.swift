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

struct TrustedBuyerScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var viewModel = TrustedBuyerViewModel()
    @State var navigateToProfile: Bool = false
    
    @State private var isLoading = false
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var showhud = false
    @State private var hudMsg = ""
    
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var uploadedImage: Image? = nil
    @State private var isPhotoSelected = false
    @State var navigateToCreateAddress = false
    var body: some View {
        VStack {
            PrimaryHeader(
                title: "Become a Trusted Buyer".localized,
                isForLogo : false, leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(.white)
            .frame(height: 50)
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Step Header
                    VStack(spacing: 8) {
                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                        
                        Text("Verify Your Identity")
                            .font(.title2)
                            .bold()
                        Text("To become a Trusted Buyer, we need to verify your identity. This helps create a safe trading environment.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // MARK: - Step Indicator
                    HStack(spacing: 0) {
                        StepCircle(step: "1", label: "Upload", isActive: true)
                        Rectangle()
                               .fill(Color.gray.opacity(0.4))
                               .frame(height: 1)
                               .frame(maxWidth: .infinity)
                        StepCircle(step: "2", label: "Review", isActive: true)
                        Rectangle()
                               .fill(Color.gray.opacity(0.4))
                               .frame(height: 1)
                               .frame(maxWidth: .infinity)
                        StepCircle(step: "3", label: "Verified", isActive: false)
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Upload Card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Upload ID Photo")
                            .font(.headline)
                        
                        Text("Please upload a clear photo of your valid government-issued ID (driver’s license or passport).")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        VStack {
                            if let image = uploadedImage {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 150)
                                    .cornerRadius(8)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "idcard")
                                        .resizable()
                                        .frame(width: 40, height: 30)
                                        .foregroundColor(.gray)
                                    Text("Tap to upload your ID photo")
                                        .foregroundColor(.gray)
                                }
                                .frame(height: 150)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [5])))
                            }
                            
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Text("Choose File")
                                    .font(.body.bold())
                                    .padding()
                                    .frame(width: 150)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(75)
                            }
                            .onChange(of: selectedPhoto) { newItem in
                                Task {
                                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        uploadedImage = Image(uiImage: uiImage)
                                        isPhotoSelected = true
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // MARK: - Requirements Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Requirements")
                            .font(.headline)
                        HStack(spacing: 8) {
                               Image(systemName: "checkmark.circle.fill")
                                   .foregroundColor(.green)
                               Text("Government-issued ID (driver’s license or passport)")
                                   .foregroundColor(.primary)
                           }

                           HStack(spacing: 8) {
                               Image(systemName: "checkmark.circle.fill")
                                   .foregroundColor(.green)
                               Text("Clear, well-lit photo")
                                   .foregroundColor(.primary)
                           }

                           HStack(spacing: 8) {
                               Image(systemName: "checkmark.circle.fill")
                                   .foregroundColor(.green)
                               Text("All corners visible")
                                   .foregroundColor(.primary)
                           }

                           HStack(spacing: 8) {
                               Image(systemName: "checkmark.circle.fill")
                                   .foregroundColor(.green)
                               Text("Verification usually takes 3 business days")
                                   .foregroundColor(.primary)
                           }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // MARK: - Submit Button
                    Button(action: {
                        Task {
                               guard let selectedPhoto else { return }
                               do {
                                   // Load the image data
                                   let imageData = try await selectedPhoto.loadTransferable(type: Data.self)

                                   // Ensure it's not nil or empty
                                   guard let data = imageData, !data.isEmpty else {
                                       print("Image data is empty")
                                       return
                                   }

                                   // Save the image data to a temp file
                                   let imageURL = saveImageToTemporaryDirectory(data: data)
                                   guard let path = imageURL?.path else {
                                       print("Could not save image to file")
                                       return
                                   }

                                   print("📸 Saved Image Path:", path)

                                   // Call your existing ViewModel method
                                   self.viewModel.addTrustedBuyer(param: [:], keysValue: ["image"], mimeTypes: ["image/png"], musics: [[path]])

                               } catch {
                                   print("❌ Failed to load image:", error)
                               }
                           }
                    }) {
                        Text("Submit for Review")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    .disabled(!isPhotoSelected) // Disable if no photo selected
                }
            }
            
            
            CusNavLink(doNavigate: $navigateToCreateAddress, destination: CreateAddress())
        }
        .onAppear {
            UIScrollView.appearance().bounces = false
            
        }
        .onDisappear {
            UIScrollView.appearance().bounces = true
        }
        .onReceive(viewModel.$addTrustedBuyerDict) { respone in
            handleSuccess()
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .bottomSheet(
            isPresented: $showError,
            height: screenHeight / 2.3,
            topBarCornerRadius: 25,
            showTopIndicator: false
        ) {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showError = false }
                },
                onSecondaryClick: {
                    withAnimation { showError = false }
                }
            )
        }
    }
    
    func handleSuccess() {
        SVProgressHUD.dismiss()
//        let response = viewModel.addTrustedBuyerDict
//        
//        if response?.status == "success" {
//            alertType = .sheetType(icon: .success, title: response?.status?.capitalized!, message: response?.message?.capitalized!, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .green)
//            showError = true
//            withAnimation(.snappy) { navigateToProfile = true }
//        } else {
//            alertType = .sheetType(icon: .alert, title: response?.status?.capitalized!, message: response?.message?.capitalized!, primaryBtnText: "", secondaryBtnText: AppString.ok.localized, sheetThemeColor: .defaultTheme)
//            withAnimation(.snappy) { showError = true }
//        }
    }
}

#Preview {
    TrustedBuyerScreen()
}

struct StepCircle: View {
    var step: String
    var label: String
    var isActive: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Circle()
                .fill(isActive ? Color.blue : Color.gray.opacity(0.4))
                .frame(width: 28, height: 28)
                .overlay(
                    Text(step)
                        .font(.caption)
                        .foregroundColor(.white)
                )
            Text(label)
                .font(.caption)
                .foregroundColor(isActive ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

func saveImageToTemporaryDirectory(data: Data) -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
    let fileName = "\(Int(Date().timeIntervalSince1970)).png"
    let fileURL = tempDir.appendingPathComponent(fileName)
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error writing image to file:", error)
        return nil
    }
}
