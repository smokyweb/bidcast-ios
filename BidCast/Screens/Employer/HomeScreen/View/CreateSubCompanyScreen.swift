//
//  CreateSubCompanyScreen.swift
//  imperium
//
//  Created by JAM-E-221 on 25/01/25.
//

import SwiftUI
import BottomSheet
import AlertToast

struct CreateSubCompanyScreen: View {
    
        //MARK: - Environment Variable
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Detail Variable
//    @State var detailInfo: UserPersonalInfo = UserPersonalInfo(first_name: "", last_name: "", email: "", location: "", password: "", phone: "", description: "", profile_image: "")
    
    
    @State var detailInfo: SubCompanyParam = SubCompanyParam(first_name: "", last_name: "", email: "", user_name: "",phone: "", image: "", data: [])
    
    
    @State var detailInfoUser: SubCompanyUserParam = SubCompanyUserParam(first_name: "", last_name: "",phone: "", image: "")
    
    @State var detailInfoUpdate: SubCompanyParamUpdate = SubCompanyParamUpdate(first_name: "", last_name: "", email: "", user_id: "",phone: "", image: "", data: [])
    
        //MARK: - State Variable
    @State var openImageSheet: Bool = false
    @State var openActionSheet: Bool = false
    @State var locationArr: [String] = []
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImageArray: [String] = []
    @State var selectedAssignPermission: [[String : Any]] = []
    var selectedPermissions = [String]()
    @State var comeFromuserList : Bool
    @State var comeFromuserProfile : Bool
    @Binding var userId : Int
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    @State var image :String = ""
    
    var viewModel = CreateEmployerProfileViewModal()
    
        //MARK: - Primary View
    var body: some View {
        ZStack(content: {
            VStack {
                HeaderWithImage(
                    title: comeFromuserProfile || comeFromuserList ? "Update User" : "Create User",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSelectImage: {
                        openActionSheet = true
                    }, userImg: $image)
                
                ScrollView(showsIndicators: false, content: {
                    VStack {
                        if !comeFromuserList || !comeFromuserProfile{
                            
                            AuthTextField(floatingLabel: "User Name", placeholder: "Enter User Name", icon: .menuProfile, text: $detailInfo.user_name)
                                .textContentType(.familyName)
                        }else{
                            AuthTextField(floatingLabel: "User Name", placeholder: "Enter User Name", icon: .menuProfile, text: $detailInfo.user_name)
                                .textContentType(.familyName)
                                .disabled(true)
                        }
                        if comeFromuserProfile{
                            AuthTextField(floatingLabel: "First Name", placeholder: "Enter First Name", icon: .menuProfile, text: $detailInfoUser.first_name)
                                .textContentType(.givenName)
                            
                            AuthTextField(floatingLabel: "Last Name", placeholder: "Enter Last Name", icon: .menuProfile, text: $detailInfoUser.last_name)
                                .textContentType(.familyName)
                            
                            
                            AuthTextField(floatingLabel: "Phone Number", placeholder: "Enter Phone Number", icon: .phone, text: $detailInfoUser.phone){
                                phone in
                                detailInfoUser.phone = String(phone.filter(\.isWholeNumber).prefix(9)).toPhoneNumberUs()

                            }
                                .textContentType(.telephoneNumber)
                                .onChange(of: detailInfoUser.phone, perform: { value in
                                    detailInfoUser.phone = String(value.filter(\.isWholeNumber).prefix(10)).toPhoneNumberUs()
                                })
                        }else{
                            AuthTextField(floatingLabel: "First Name", placeholder: "Enter First Name", icon: .menuProfile, text: comeFromuserList ? $detailInfoUpdate.first_name : $detailInfo.first_name)
                                .textContentType(.givenName)
                            
                            AuthTextField(floatingLabel: "Last Name", placeholder: "Enter Last Name", icon: .menuProfile, text: comeFromuserList ? $detailInfoUpdate.last_name : $detailInfo.last_name)
                                .textContentType(.familyName)
                            
                            AuthTextField(floatingLabel: "Phone Number", placeholder: "Enter Phone Number", icon: .phone, text: comeFromuserList ? $detailInfoUpdate.phone : $detailInfo.phone){
                                phone in
                                if comeFromuserList{
                                    detailInfoUpdate.phone = String(phone.filter(\.isWholeNumber).prefix(9)).toPhoneNumberUs()

                                }else{
                                    detailInfo.phone = String(phone.filter(\.isWholeNumber).prefix(9)).toPhoneNumberUs()
                                }

                            }
                                .textContentType(.telephoneNumber)
                        }
                        if comeFromuserProfile{
                            AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: comeFromuserList ? $detailInfoUpdate.email : $detailInfo.email)
                                .textContentType(.emailAddress)
                                .disabled(true)

                        }else{
                            
                            AuthTextField(floatingLabel: "Email Address", placeholder: "Enter Email Address", icon: .mail, text: comeFromuserList ? $detailInfoUpdate.email : $detailInfo.email)
                                .textContentType(.emailAddress)
                        }
                        Spacer(minLength: 20)
                        if !comeFromuserProfile{
                            Text("Assign Permission")
                                .font(.custom(nunitoBold, fixedSize: 20))
                                .bold()
                                .foregroundStyle(.text)
                                .underline()
                            
                            let permissions = self.viewModel.companyResponse?.data.permission?.map { perm in
                                Permission(
                                    permission: perm.permission ?? "",
                                    isReadSelected: perm.read_access == "true" ? true : false,
                                    isWriteSelected: perm.write_access == "true" ? true : false,
                                    isDeleteSelected: perm.delete_access == "true" ? true : false
                                )
                            } ?? [
                                Permission(permission: "Jobs", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Company", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Perform Action of employee profile", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Document Verification", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Calendar Management", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Purchase Swipe", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false),
                                Permission(permission: "Interview List", isReadSelected: false, isWriteSelected: false, isDeleteSelected: false)
                            ]
                            PermissionsView(viewModel: PermissionsViewModel(permissions: permissions)) { selectedPermissions in
                                print("Live Updated Permissions: \(selectedPermissions)")
                                
                                selectedAssignPermission = selectedPermissions
                                if !comeFromuserList{
                                    detailInfo.data = selectedPermissions.map { permission in
                                        // Return an array containing a single AssignData object
                                        
                                        AssignData(
                                            permission: permission["permission"] as! String,
                                            read: (permission["read"] as? Bool ?? false) ? "true" : "false",
                                            write: (permission["write"] as? Bool ?? false) ? "true" : "false",
                                            delete: (permission["delete"] as? Bool ?? false) ? "true" : "false"
                                        )
                                        
                                    }
                                }else{
                                    detailInfoUpdate.data = selectedPermissions.map { permission in
                                        // Return an array containing a single AssignData object
                                        
                                        AssignData(
                                            permission: permission["permission"] as! String,
                                            read: (permission["read"] as? Bool ?? false) ? "true" : "false",
                                            write: (permission["write"] as? Bool ?? false) ? "true" : "false",
                                            delete: (permission["delete"] as? Bool ?? false) ? "true" : "false"
                                        )
                                        
                                    }
                                }
                                
                            }
                        }



                    }.padding([.leading, .trailing])
                    
                    
                    PrimaryButton(title: comeFromuserList ? "Update" : "Submit", isOutLine: false, onButtonClick: {
                        UIApplication.shared.endEditing()
                        validate()
                    }).padding()
                })
                
                Spacer()
            }
            .padding(.top, -topPadding)
            .onAppear(perform: {
               
                if comeFromuserList{
                    isLoading = true
                    print(userId)
                    detailInfoUpdate.user_id = "\(userId)"
                    self.viewModel.getSubCompanyDetails(user_id: "\(userId)")
                   
                }else if comeFromuserProfile{
                    self.viewModel.getSubCompanyUserDetails()
                }
            })
            .sheet(isPresented: $openImageSheet, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $openImageSheet) { image, imageURL in
                    if image != nil {
                        withAnimation(.easeIn) {
                            openImageSheet = false
                            selectedImageArray.append(imageURL ?? "")
                            self.image = imageURL ?? ""
//                            detailInfo.image = imageURL ?? ""
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
        
        if comeFromuserList{
            
            
            guard !detailInfoUpdate.first_name.isEmpty else {
                hudMsg = "First Name is required"
                showHud = true
                return
            }
            
            guard !detailInfoUpdate.last_name.isEmpty else {
                hudMsg = "Last Name is required"
                showHud = true
                return
            }
            
            guard !detailInfoUpdate.email.isEmpty else {
                hudMsg = "Email Address is required."
                showHud = true
                return
            }
            
            guard detailInfoUpdate.email.isValidEmail() else {
                hudMsg = "Email Address is not valid. Please enter valid mail"
                showHud = true
                return
            }
            
            guard !detailInfoUpdate.phone.isEmpty else {
                hudMsg = "Contact Info is required"
                showHud = true
                return
            }
            
            guard detailInfoUpdate.phone.digit.count <= 10 && detailInfoUpdate.phone.digit.count >= 8 else {
                hudMsg = "Contact Number is not valid."
                showHud = true
                return
            }
            
        }else if comeFromuserProfile{
            guard !detailInfoUser.first_name.isEmpty else {
                hudMsg = "First Name is required"
                showHud = true
                return
            }
            
            guard !detailInfoUser.last_name.isEmpty else {
                hudMsg = "Last Name is required"
                showHud = true
                return
            }
            
            guard detailInfoUser.phone.digit.count <= 10 && detailInfoUser.phone.digit.count >= 8 else {
                hudMsg = "Contact Number is not valid."
                showHud = true
                return
            }

        }else{
            
            guard !detailInfo.user_name.isEmpty else {
                hudMsg = "User Name is required"
                showHud = true
                return
            }
            
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
            guard !detailInfo.phone.isEmpty else {
                hudMsg = "Contact Info is required"
                showHud = true
                return
            }
            
            guard detailInfo.phone.digit.count <= 10 && detailInfo.phone.digit.count >= 8 else {
                hudMsg = "Contact Number is not valid."
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
            

            
            guard !detailInfo.data!.isEmpty else {
                hudMsg = "Please fill atleast one permission access"
                showHud = true
                return
            }
        }
        
        if selectedImageArray.count == 0 {
            hudMsg = "Please choose profile image"
            showHud = true
        }else{
            
            print(detailInfo)
            if comeFromuserList{
                self.viewModel.uploadImagesToUserUpdate(parameter: selectedImageArray,userParam: detailInfoUpdate)
            }else if comeFromuserProfile{
                self.viewModel.uploadImagesToCompanyUser(parameter: selectedImageArray, userParam: detailInfoUser)
            }else{
                self.viewModel.uploadImagesToUser(parameter: selectedImageArray,userParam: detailInfo)

            }
        }

        
//        guard !detailInfo.description.isEmpty else {
//            hudMsg = "Your short description is required"
//            showHud = true
//            return
//        }
//        
//        guard !detailInfo.location.isEmpty else {
//            hudMsg = "Location is required"
//            showHud = true
//            return
//        }
        
//        detailInfo.phone = detailInfo.phone.replacingOccurrences(of: "-", with: "")
        
//        if selectedImageArray.count > 0 {
//            viewModel.uploadImages(parameter: selectedImageArray)
//        } else {
        
        
        


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
        if viewModel.requestType == "GetCompany" {
            if let response = viewModel.companyResponse {
                isLoading = false
                if response.status == "success" {

                    detailInfoUpdate.first_name = response.data.first_name ?? ""
                    detailInfoUpdate.last_name = response.data.last_name ?? ""
                    detailInfo.user_name = response.data.user_name ?? ""
                    detailInfoUpdate.email = response.data.email ?? ""
                    detailInfoUpdate.phone = response.data.phone ?? ""
                    self.image = "\(response.data.profile_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    self.selectedImageArray.removeAll()
                    self.selectedImageArray.append(self.image)

                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModel.requestType == "GetCompanyUser"{
            if let response = viewModel.companyResponseDetails {
                isLoading = false
                if response.status == "success" {

                    detailInfoUser.first_name = response.data.first_name ?? ""
                    detailInfoUser.last_name = response.data.last_name ?? ""
                    detailInfo.user_name = response.data.user_name ?? ""
                    detailInfo.email = response.data.email ?? ""
                    detailInfoUser.phone = response.data.phone ?? ""
                    self.image = "\(response.data.profile_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                    self.selectedImageArray.removeAll()
                    self.selectedImageArray.append(self.image)

                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModel.requestType == "UpdateCompanyUser"{
            if let response = viewModel.response {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }else if viewModel.requestType == "UpdateCompany"{
            if let response = viewModel.updateCompanyResponse {
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

//#Preview {
////    CreateSubCompanyScreen(comeFromuserList: false, userId:  )
//}
