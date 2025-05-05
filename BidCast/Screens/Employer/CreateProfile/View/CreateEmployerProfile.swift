//
//  CreateEmployerProfile.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 13/02/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct CreateEmployerProfile: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
        //MARK: - Variable's Initializer's
    @State var isLoading: Bool = false
    @State var navigateToVidResTuto: Bool = false
    
    @State var userImageSelected: Bool = false
    @State var showActionSheet: Bool = false
    @State var showImageSelector: Bool = false
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImage: UIImage = UIImage(resource: .userDummy)
    @State var selectedImageArray: [String] = []
    
    @State var request: UserPersonalInfo = UserPersonalInfo(first_name: "", last_name: "", email: "", location: "", password: "", phone: "", description: "", profile_image: "")
    
    var viewModal = CreateEmployerProfileViewModal()
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showAlert: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
        //MARK: - Primary View Body
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                PrimaryHeader(
                    title: "Create Profile",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .welcome
                        }
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 16, content: {
                        Text(userImageSelected ? "Continue adding a short Description and Contact Number of yours." : "Adding a photo helps people recognize you.")
                            .font(.custom(nunitoBlack, fixedSize: 20))
                            .multilineTextAlignment(.leading)
                        
                        VStack {
                            VStack {
                                if userImageSelected {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: screenWidth/3, height: screenWidth/3)
                                        .foregroundStyle(.text.opacity(0.5))
                                        .clipShape(Circle())
                                        .padding(.all, 4)
                                } else {
                                    Image(.menuProfile)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: screenWidth/6, height: screenWidth/6)
                                        .foregroundStyle(.text.opacity(0.5))
                                        .padding()
                             //           .background(.backGround)
                                        .clipShape(Circle())
                                        .padding(.all, 4)
                                }
                            }
                            .background(.white).clipShape(Circle())
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                            .overlay(alignment: .bottomTrailing, content: {
                                if userImageSelected {
                                    Button(action: {
                                        withAnimation(.easeOut) {
                                            userImageSelected = false
                                        }
                                    }, label: {
                                        Image(.menuLogout)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .padding(.all, 2)
                                            .background(.pinkBtn)
                                            .foregroundStyle(.white)
                                            .clipShape(Circle())
                                            .padding(.all,2)
                                            .background(.white)
                                            .clipShape(Circle())
                                    }).offset(x: 4, y: 3)
                                }
                            })
                            
                            
                            Text("\(request.first_name) \(request.last_name)")
                                .font(.custom(nunitoBlack, fixedSize: 24))
                                .multilineTextAlignment(.leading)
                        }
                        .frame(width: screenWidth - 30)
                        .padding(.vertical)
               //         .background(.backGround)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if userImageSelected {
                            
                            AuthTextField(
                                floatingLabel: "Contact Number",
                                placeholder: "Enter Number",
                                icon: .phone,
                                text: $request.phone,
                                enteredText: {
                                    text in
                                    request.phone = text
                                })
                            .keyboardType(.numberPad)
                            
                            MultilineTextField(
                                floatingLabel: "Add Short Description of you",
                                placeholder: "Description goes here",
                                text: $request.description,
                                enteredText: {
                                    value in
                                    request.description = value
                                })
                        }
                        
                        if !userImageSelected {
                            PrimaryButton(title: "Continue", isOutLine: false, onButtonClick: {
                                withAnimation(.snappy) {
                                    showActionSheet = true
                                }
                            })
                            
                            PrimaryButton(title: "Skip for Now", isOutLine: true, onButtonClick: {
                                withAnimation{ navigateToVidResTuto = true }
                            })
                        } else {
                            PrimaryButton(title: "Next", isOutLine: false, onButtonClick: {
                                validate()
                            })
                        }
                    })
                    .padding([.horizontal, .vertical])
                })
                .padding(.top, -topPadding)
                
                Spacer()
            }
            .sheet(isPresented: $showImageSelector, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $showImageSelector) { image, imageURL in
                    if let img = image {
                        withAnimation(.easeIn) {
                            selectedImage = img
                            userImageSelected = true
                            showImageSelector = false
                            selectedImageArray.append(imageURL ?? "")
                        }
                    }
                }
            })
            .actionSheet(isPresented: $showActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [ActionSheet.Button.default(Text("Take a Photo").font(.custom(nunitoRegular, fixedSize: 14)), action: {
                    imageSelectorSource = .camera
                    showImageSelector = true
                }), ActionSheet.Button.default(Text("Choose from Gallery"), action: {
                    imageSelectorSource = .photoLibrary
                    showImageSelector = true
                }), ActionSheet.Button.cancel()])
            }
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .welcome
                        }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.snappy) { showAlert = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.snappy) { showAlert = false }
//                        DispatchQueue.main.async {
//                            appRootManager.currentRoot = .welcome
//                        }
//                    })
//            }
            
            CusNavLink(doNavigate: $navigateToVidResTuto, destination: WelcomeScreen())
            
        }.onAppear(perform: {
            if let data: SignInData = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                request.first_name = data.first_name ?? ""
                request.last_name = data.last_name ?? ""
                request.email = data.email ?? ""
                request.location = data.location ?? ""
                request.profile_image = data.profile_image ?? ""
            }
            observe()
        })
    }
    
        //MARK: - Validate Field
    func validate() {
        guard !request.phone.isEmpty else {
            hudMsg = "Contact Number is required"
            showhud = true
            return
        }
        
        guard request.phone.digit.count <= 10 && request.phone.digit.count >= 8 else {
            hudMsg = "Contact Number is not valid."
            showhud = true
            return
        }
        
        guard !request.description.isEmpty else {
            hudMsg = "Description is required"
            showhud = true
            return
        }
        
        isLoading = true
        self.viewModal.uploadImages(parameter: selectedImageArray)
        observe()
    }
    
        //MARK: - View Modal Observer
    func observe() {
        viewModal.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
        //MARK: - View Modal Handle Success
    func handleSuccess() {
        if let response = viewModal.response {
            if response.status == "success" {
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Continue", secondaryBtnText: "", sheetThemeColor: .green)
                showAlert = true
            } else {
                alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
        
        if let response = viewModal.imageUploadResponse {
            if response.status == "success" {
                request.profile_image = response.data.first ?? ""
                self.viewModal.updateEmployerDetails(parameter: request)
                self.observe()
                self.viewModal.imageUploadResponse = nil
            } else {
                self.viewModal.updateEmployerDetails(parameter: request)
                self.observe()
            }
        }
    }
}

#Preview {
    CreateEmployerProfile()
}
