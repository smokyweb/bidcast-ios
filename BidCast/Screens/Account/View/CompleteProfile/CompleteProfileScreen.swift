//
//  CompleteProfileScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//
import SwiftUI
import AlertToast
import PhotosUI
import SVProgressHUD

struct CompleteProfileScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var bio = ""
    
    @State private var profileImage: UIImage? = nil
    @State var profileImageUrl = ""
    @State private var showImagePicker: Bool = false
    @State var email = ""
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var showError: Bool = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    @State var request = UpdateProfileRequest(first_name: "", last_name: "", username: "", bio: "")
    
    @State var accountDetail = ProfileModel()
    
    @State var viewModel = AccountViewModel()
    
    var body: some View {
        
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12){
                PrimaryHeader(
                    title: AppString.CompleteProfile.localized,
                    leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    VStack(alignment: .center) {
                        ZStack(alignment: .bottomTrailing) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                
                                Button(action: {
                                    profileImage = nil
                                    profileImageUrl = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.defaultTheme)
                                        .clipShape(Circle())
                                        .shadow(radius: 1)
                                }
                                .offset(x: 5, y: 5)
                            } else if accountDetail.profile_image == nil || accountDetail.profile_image == "<null>" {
                                
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.gray)
                                            .padding(30)
                                    )
                                
                                Button(action: {
                                    showPickerOptions = true
                                }) {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 1)
                                }
                                .offset(x: 5, y: 5)
                                
                                
                            }else {
                                AsyncImage(url: URL(string: accountDetail.profile_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) { phase in
                                    if let image = phase.image {
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                    } else if phase.error != nil {
                                        Circle()
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: 120, height: 120)
                                            .overlay(
                                                Image(systemName: "person.fill")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.gray)
                                                    .padding(30)
                                            )
                                    } else {
                                        ProgressView()
                                            .frame(width: 120, height: 120)
                                    }
                                }
                                
                                Button(action: {
                                    showPickerOptions = true
                                }) {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(radius: 1)
                                }
                                .offset(x: 5, y: 5)
                            }
                            
                        }
                        
                        Text(AppString.UploadPhoto.localized)
                            .foregroundColor(.blue)
                            .font(.custom(poppinsRegular, size: 13.0))
                            .padding(.top, 8)
                    }
                    
                    TitleWithLine(title: AppString.CompleteYourProfile, lineLength: sepratorLine)
                    
                    AuthTextField(
                        floatingLabel: AppString.firstName.localized,
                        placeholder: AppString.enterFirstName.localized,
                        icon: .menuProfile,
                        text: $request.first_name,
                        enteredText: { value in
                            request.first_name = value
                        }
                    )
                    .textContentType(.givenName)
                    .keyboardType(.default)
                    
                    AuthTextField(
                        floatingLabel: AppString.lastName.localized,
                        placeholder: AppString.enterLastName.localized,
                        icon: .menuProfile,
                        text: $request.last_name,
                        enteredText: { value in
                            request.last_name = value
                        }
                    )
                    .textContentType(.familyName)
                    .keyboardType(.default)
                    
                    AuthTextField(
                        floatingLabel: AppString.Username.localized,
                        placeholder: AppString.EnterUserName.localized,
                        icon: .menuProfile,
                        text: $request.username,
                        enteredText: { value in
                            request.username = value
                        }
                    )
                    .textContentType(.username)
                    .keyboardType(.default)
                    AuthTextField(
                        floatingLabel: AppString.email.localized,
                        placeholder: AppString.enterEmail.localized,
                        icon: .menuProfile,
                        text: $email,
                        enteredText: { value in
                           
                        }
                    )
                    .disabled(true)
                    .textContentType(.username)
                    .keyboardType(.default)
                    
                    AuthTextField(
                        floatingLabel: AppString.Bio.localized,
                        placeholder: AppString.TellUsAboutYourself,
                        icon: .icMail,
                        text: $request.bio,
                        enteredText: { value in
                            request.bio = value
                        }
                    )
                    .keyboardType(.default)
                    
                    PrimaryButton(title: AppString.Update.localized, isOutLine: false, onButtonClick: {
                        UIApplication.shared.endEditing()
                        
                        guard profileImageUrl != nil else {
                            hudMsg = AppString.PleaseUploadYourProfileImage.localized
                            showhud = true
                            return
                        }
                        
                        guard !request.first_name.isEmpty else {
                            hudMsg = AppString.PleaseEnterYourFirstName.localized
                            showhud = true
                            return
                        }
                        
                        guard !request.last_name.isEmpty else {
                            hudMsg = AppString.PleaseEnterYourLastName.localized
                            showhud = true
                            return
                        }
                        
                        guard !request.username.isEmpty else {
                            hudMsg = AppString.PleaseEnteraUsername
                            showhud = true
                            return
                        }
                        
                        guard !request.bio.isEmpty else {
                            hudMsg = AppString.PleaseEnteraBio.localized
                            showhud = true
                            return
                        }
                        
                        Task{
                           guard Reachability.isConnectedToNetwork() else {
                                hudMsg = "No Internet Connection"
                                showhud = true
                                return
                            }
                            SVProgressHUD.show()
                            await self.viewModel.UpdateProfile(param: request, images: [profileImageUrl], key: "profile_image")
                            await SVProgressHUD.dismiss()
                            if viewModel.errorMessage == "" || viewModel.errorMessage == nil{
                                let response = self.viewModel.accountInfo
                                alertType = .sheetType(
                                    icon: .success,
                                    title: response.status?.capitalized ?? "",
                                    message: response.message?.capitalized ?? "",
                                    primaryBtnText: AppString.ok.localized,
                                    secondaryBtnText: ""
                                )
                                showError = true
                            }else{
                                alertType = .sheetType(
                                    icon: .alert,
                                    title: "Failed",
                                    message: viewModel.errorMessage ?? "",
                                    primaryBtnText: "",
                                    secondaryBtnText: AppString.ok.localized
                                )
                                showError = true
                            }
                        }
                        
                    }, btnTextColor: .white)
                    
                }
                .padding()
            }
            .onAppear{
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    await viewModel.getProfile()
                    await SVProgressHUD.dismiss()
                    if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                        self.accountDetail = self.viewModel.accountInfo.data ?? ProfileModel()
                        self.email = accountDetail.email ?? ""
                        self.request.first_name = accountDetail.first_name ?? ""
                        self.request.last_name = accountDetail.last_name ?? ""
                        self.request.username = accountDetail.username ?? ""
                        self.request.bio = accountDetail.bio ?? ""
                        self.profileImageUrl = accountDetail.profile_image ?? ""
                        UserDefaults.profileURL = self.profileImageUrl
                    }else{
                        
                    }
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .confirmationDialog(AppString.SelectMediaSource, isPresented: $showPickerOptions) {
                Button(AppString.Camera) {
                    showCameraPicker = true
                }
                Button(AppString.PhotoLibrary) {
                    showPhotoLibrary = true
                }
                Button(AppString.Cancel, role: .cancel) {}
            }
            .sheet(isPresented: $showCameraPicker) {
                ImagePicker(sourceType: .camera) { image,url  in
                    if let image = image{
                        profileImage = image
                    }
                    if let url = url {
                        profileImageUrl = url
                    }
                }
            }
            .sheet(isPresented: $showPhotoLibrary) {
                PhotoPicker(count: 1) { images,urls in
                    
                    profileImage = images.first
                    profileImageUrl = urls.first ?? ""
                    
                    
                }
            }
            
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
            }
            .bottomSheet(isPresented: $showError, height: screenHeight / 2.5, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
                if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                    withAnimation { showError = true }
                }else{
                    withAnimation { showError = false }
                }
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                            withAnimation { showError = false }
                            Task{
                               guard Reachability.isConnectedToNetwork() else {
                                    hudMsg = "No Internet Connection"
                                    showhud = true
                                    return
                                }
                                SVProgressHUD.show()
                                await viewModel.getProfile()
                                await SVProgressHUD.dismiss()
                                if viewModel.errorMessage == "" || viewModel.errorMessage == nil {
                                    self.accountDetail = self.viewModel.accountInfo.data ?? ProfileModel()
                                    self.request.first_name = accountDetail.first_name ?? ""
                                    self.request.last_name = accountDetail.last_name ?? ""
                                    self.request.username = accountDetail.username ?? ""
                                    self.request.bio = accountDetail.bio ?? ""
                                    self.profileImageUrl = accountDetail.profile_image ?? ""
                                    UserDefaults.profileURL = self.profileImageUrl
                                }else{
                                    
                                }
                            }
                            
                        }else{
                            withAnimation { showError = false }
                        }
                       
                    },
                    onSecondaryClick: {
                        withAnimation { showError = false }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                )
            })
        }
    }
    
  
}
