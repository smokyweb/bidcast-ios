//
//  UpdateEmployerProfile.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 05/03/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct UpdateEmployerProfile: View {
    
        //MARK: - Environment Variable
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Detail Variable
    @State var detailInfo: UserPersonalInfo = UserPersonalInfo(first_name: "", last_name: "", email: "", location: "", password: "", phone: "", description: "", profile_image: "")
    
        //MARK: - State Variable
    @State var openImageSheet: Bool = false
    @State var openActionSheet: Bool = false
    @State var locationArr: [String] = []
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImageArray: [String] = []
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModel = CreateEmployerProfileViewModal()
    
        //MARK: - Primary View
    var body: some View {
        ZStack(content: {
            VStack {
                HeaderWithImage(
                    title: "Update Profile",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSelectImage: {
                        openActionSheet = true
                    }, userImg: $detailInfo.profile_image)
                
                ScrollView(showsIndicators: false, content: {
                    VStack {
                        AuthTextField(floatingLabel: "First Name", placeholder: "Enter First Name", icon: .menuProfile, text: $detailInfo.first_name)
                            .textContentType(.givenName)
                        
                        AuthTextField(floatingLabel: "Last Name", placeholder: "Enter Last Name", icon: .menuProfile, text: $detailInfo.last_name)
                            .textContentType(.familyName)
                        
                        AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: $detailInfo.email)
                            .textContentType(.emailAddress)
                        
                        AuthTextField(floatingLabel: "Contact Info", placeholder: "Enter Contact Info", icon: .phone, text: $detailInfo.phone)
                            .keyboardType(.numberPad)
                            .textContentType(.telephoneNumber)
                            .onChange(of: detailInfo.phone, perform: { value in
                                detailInfo.phone = String(value.filter(\.isWholeNumber).prefix(10)).toPhoneNumber()
                            })
                        
                        MultilineTextField(floatingLabel: "About", placeholder: "Enter Description", text: $detailInfo.description, isForDescription: true, enteredText: { text in
                            detailInfo.description = text
                        })
                        .textContentType(.addressCityAndState)
                    }.padding([.leading, .trailing])
                    
                    VStack(spacing: 15) {
                        Text("Location")
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .frame(width: screenWidth - 30, alignment: .leading)
                        
                        DropDownTextField(
                            hint: "Confirm your location",
                            text: $detailInfo.location,
                            options: $locationArr,
                            leadingIcon: .location,
                            showLeadingIcon: true,
                            showTrailingIcon: false,
                            onOptionSelected: { text in
                            },
                            anchor: .top)
                        .onChange(of: detailInfo.location) { newValue in
                            if !isLoading {
                                GooglePlacesManager.shared.findPlaces(query: newValue) { result in
                                    switch result {
                                        case .success(let places):
                                            withAnimation(.easeIn(duration: 0.5)) {
                                                locationArr.removeAll()
                                                places.forEach { place in
                                                    locationArr.append(place.name)
                                                }
                                            }
                                        case .failure(let error):
                                            print(error)
                                    }
                                }
                            }
                        }
                    }
                    .padding([.top, .bottom], 20)
                    .padding([.leading, .trailing])
                    .background(.text.opacity(0.1))
                    .zIndex(1300.0)
                    
                    PrimaryButton(title: "Update Profile", isOutLine: false, onButtonClick: {
                        UIApplication.shared.endEditing()
                        validate()
                    }).padding()
                })
                
                Spacer()
            }
            .padding(.top, -topPadding)
            .onAppear(perform: {
                isLoading = true
                if let detail: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                    detailInfo.first_name = detail.first_name ?? ""
                    detailInfo.last_name = detail.last_name ?? ""
                    detailInfo.email = detail.email ?? ""
                    detailInfo.location = detail.location ?? ""
                    detailInfo.phone = detail.phone ?? ""
                    detailInfo.description = detail.description ?? ""
                    detailInfo.profile_image = detail.profile_image ?? ""
                    isLoading = false
                }
            })
            .sheet(isPresented: $openImageSheet, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $openImageSheet) { image, imageURL in
                    if image != nil {
                        withAnimation(.easeIn) {
                            openImageSheet = false
                            selectedImageArray.append(imageURL ?? "")
                            detailInfo.profile_image = imageURL ?? ""
                        }
                    }
                }
            })
            .actionSheet(isPresented: $openActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [ActionSheet.Button.default(Text("Take a Photo").font(.custom(nunitoRegular, fixedSize: 14)), action: {
                    imageSelectorSource = .camera
                    openImageSheet = true
                }), ActionSheet.Button.default(Text("Choose from Gallery"), action: {
                    imageSelectorSource = .photoLibrary
                    openImageSheet = true
                }), ActionSheet.Button.cancel()])
            }
            .onAppear(perform: {
                observe()
            })
            .onTapGesture(perform: {
                UIApplication.shared.endEditing()
            })
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        self.presentationMode.wrappedValue.dismiss()
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
//                        withAnimation{ showAlert = false }
//                    }, rightButtonAction: {
//                        withAnimation{ showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
        })
    }
    
        //MARK: - Validate Detail
    func validate() {
        guard !detailInfo.first_name.isEmpty else {
            hudMsg = "First Name is required"
            showHud = true
            return
        }
        
        guard !detailInfo.last_name.isEmpty else {
            hudMsg = "Last Name is required"
            showHud = true
            return
        }
        
        guard !detailInfo.email.isEmpty else {
            hudMsg = "Email Address is required."
            showHud = true
            return
        }
        
        guard detailInfo.email.isValidEmail() else {
            hudMsg = "Email Address is not valid. Please enter valid mail"
            showHud = true
            return
        }
        
        guard !detailInfo.phone.isEmpty else {
            hudMsg = "Contact Info is required"
            showHud = true
            return
        }
        
        guard !detailInfo.description.isEmpty else {
            hudMsg = "Your short description is required"
            showHud = true
            return
        }
        
        guard !detailInfo.location.isEmpty else {
            hudMsg = "Location is required"
            showHud = true
            return
        }
        
        detailInfo.phone = detailInfo.phone.replacingOccurrences(of: "-", with: "")
        
        if selectedImageArray.count > 0 {
            viewModel.uploadImages(parameter: selectedImageArray)
        } else {
            viewModel.updateEmployerDetails(parameter: detailInfo)
        }
    }
    
    //MARK: View Modal Observer
    func observe() {
        viewModel.eventHandler = { event in
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
                    print(error as Any)
            }
        }
    }
    
        //MARK: View Modal Handle Success
    func handleSuccess() {
        if viewModel.requestType == "UploadImage" {
            if let response = viewModel.imageUploadResponse {
                if response.status == "success" {
                    detailInfo.profile_image = response.data.first ?? ""
                    viewModel.updateEmployerDetails(parameter: detailInfo)
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModel.requestType == "UpdateDetail" {
            if let response = viewModel.response {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    UpdateEmployerProfile()
}
