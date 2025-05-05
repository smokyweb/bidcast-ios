//
//  UserProfileImgSelection.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 24/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast


struct UserProfileImgSelection: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State var isLoading: Bool = false
    
    @State var showVideoTutorialSheet: Bool = false
    
    @State var userImageSelected: Bool = false
    @State var showActionSheet: Bool = false
    @State var showImageSelector: Bool = false
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImage: UIImage = UIImage(resource: .userDummy)
    @State var selectedImageArray: [String] = []
    @State var firstName: String = ""
    @State var lastName: String = ""
    
    @State var email: String = ""
    @State var password: String = ""
    @State var role: String = ""
    @State var location: String = ""
    @Binding var request: CreateUserProfSection
    
    @Binding var requestSignUp: RegisterRequest
    
    var viewModal = UserCreateProfileViewModal()
    var viewModel = SignupViewModel()
    
    @State var userDetail: SignInData = SignInData()
    
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showAlert: Bool = false
    @State var isPicSelected: Bool = false
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                PrimaryHeader(
                    title: "Create Profile",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                        //                        DispatchQueue.main.async {
                        //                            appRootManager.currentRoot = .welcome
                        //                        }
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 16, content: {
                        Text("Adding a photo helps people recognize you.")
                            .font(.custom(nunitoBlack, fixedSize: 24))
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
                                    //                   .background(.backGround)
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
                                        Image(.trash)
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
                            
                            
                            Text(userDetail.name ?? "")
                                .font(.custom(nunitoBlack, fixedSize: 24))
                                .multilineTextAlignment(.leading)
                        }
                        .frame(width: screenWidth - 30)
                        .padding(.vertical)
                        //         .background(.backGround)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        if !userImageSelected {
                            PrimaryButton(title: "Add Photo", isOutLine: false, onButtonClick: {
                                withAnimation(.snappy) {
                                    showActionSheet = true
                                }
                            })
                            
                            PrimaryButton(title: "Skip for Now", isOutLine: true, onButtonClick: {
                                if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                                    request.job_category_id = "\(data.category.first(where: { $0.name == request.job_category_id })?.id ?? 0)"
                                }
                                self.isPicSelected = false
                                observeSignUp()

                                viewModel.register(parameters: RegisterRequest(first_name: UserDefaults.firstName, last_name: UserDefaults.lastName, user_name: UserDefaults.userNameAdd, email: UserDefaults.userEmail, password: UserDefaults.password, password_confirmation: UserDefaults.password, location: UserDefaults.userLocaion, role_id: UserDefaults.userRole, linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: "")))
                            })
                        } else {
                            PrimaryButton(title: "Next", isOutLine: false, onButtonClick: {
                                if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                                    request.job_category_id = "\(data.category.first(where: { $0.name == request.job_category_id })?.id ?? 0)"
                                }
                                self.isPicSelected = true
                                observeSignUp()

                                viewModel.register(parameters: RegisterRequest(first_name: UserDefaults.firstName, last_name: UserDefaults.lastName, user_name: UserDefaults.userNameAdd, email: UserDefaults.userEmail, password: UserDefaults.password, password_confirmation: UserDefaults.password, location: UserDefaults.userLocaion, role_id: UserDefaults.userRole, linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: "")))
                                
                            })
                        }
                    }).padding([.horizontal, .vertical])
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
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        withAnimation(.bouncy) { showVideoTutorialSheet = true }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            CusNavLink(doNavigate: $showVideoTutorialSheet, destination: LoginScreen())
            
        }.onAppear(perform: {
            if let data: SignInData = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                userDetail = data
            }
            observe()
        })
    }
    
    func observeSignUp() {
        viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                handleSuccessSignUp()
            case .error(let error):
                self.isLoading = false
                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
    }
    
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
                self.isLoading = false
                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
    }
    
    func handleSuccess() {
        
        if viewModal.requestType == "GetProfile" {
            if let response = viewModal.profileResponse {
                if response.status == "success" {
                    UserDefaultsManager.shared.setModel(response.data, forKey: .userDetail)
                    showAlert = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }else{
            let response = viewModal.response
            if response?.status == "success" {
                alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                self.viewModal.getProfile()
            } else {
                alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
    }
    
    
    
    func handleSuccessSignUp() {
        
        if viewModel.signUpResponceDict.status == "success" {
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.token, forKey: .token)
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.role_id, forKey: .userRoleId)
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.role_id == "2" ? "employee" : "employer", forKey: .userRole)
            if isPicSelected != true{
                viewModal.updateBasicDetail(parameters: request)
            }else{
                viewModal.updateBasicDetailWithImage(parameters: request, images: selectedImageArray)
            }
        } else {
            alertType = .sheetType(icon: .alert, title: viewModal.signUpResponceDict.status.capitalized , message: viewModel.signUpResponceDict.message.capitalized , primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            showAlert = true
        }
        
    }
}

//#Preview {
//    UserProfileImgSelection(request: .constant(CreateUserProfSection(is_student: "", most_recent_job_title: "", most_recent_company: "", your_dream_job: "", profile_image: "")), requestSignUp: <#Binding<RegisterRequest>#>)
//}
