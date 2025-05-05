//
//  EmployerCreateCompany.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 20/04/24.
//

import SwiftUI
import AlertToast
import BottomSheet
import Kingfisher

struct EmployerCreateCompany: View {
    
    @Environment(\.presentationMode) var presentationMode

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var appRootManager: AppRootManager
    
        //MARK: - Initialized Variables
    @State var request: CreateCompanyRequest = CreateCompanyRequest(company_id: "", name: "", website_link: "", industry: "", address: "", phone: "", size: "", type: "", tag_line: "", logo: "",latitude: "",longitude: "")
    @State var requestSignUp: RegisterRequest = RegisterRequest(first_name: "", last_name: "", user_name: "", email: "", password: "", password_confirmation: "", location: "", role_id: "", linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))

    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var locationArr: [String] = []
    
    @State var showLoading: Bool = false
    @State private var placeSuggestions: [Place] = []

    @State var showActionSheet: Bool = false
    @State var showImagePicker: Bool = false
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedLocation: String = ""

    @State var navigateToSubscription: Bool = false
    @State var categoriesArr: [userCategories] = []
    @State var categoriesList : [String] = []
    @State var selectedImagesURL: [Imagee] = []
    @State var selectedImage: UIImage?
    
    @State var industryTypeArr: [String] = []
    @State var viewModal: CompanyDetailViewModal?
    var viewModel = SignupViewModel()
    @State var navigatetoUser : Bool = false
    @State var isLoginFlow: Bool = false
    @State var isProfileFlow: Bool = false
    @State var isEdit: Bool = false
    
    @State var checkCloseStatus: Bool = false
    
        //MARK: - Primary View
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        if isLoginFlow {
                            
                                            

//                            navigatetoUser = true
                            
//                            alertType = .sheetType(icon: .alert, title: "Alert", message: "Without creating Company you can not use this Application.", primaryBtnText: "Create Company", secondaryBtnText: "Close Application", sheetThemeColor: .pinkBtn)
//                            showAlert = true
//                            checkCloseStatus = true
                            self.presentationMode.wrappedValue.dismiss()

//                            DispatchQueue.main.async {
//                                appRootManager.currentRoot = .welcome
//                            }
                        } else {
                            dismiss()
                        }
                    }, showAppIcon: true, count: .constant(0))
                
                    TitleWithLine(title: "Company Info")
                    .padding()
                    ScrollView {
                        VStack(spacing: 20) {
                            AuthTextField(floatingLabel: "Company Name", placeholder: "Enter your Company Name", icon: .company, text: $request.name, enteredText: {
                                value in
                                request.name = value
                            }).textContentType(.givenName)
                            
                            AuthTextField(floatingLabel: "Website Link", placeholder: "Enter your Company Website", icon: .link, text: $request.website_link, enteredText: {
                                value in
                                request.website_link = value
                                let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
                                let urlPattern = "^(https?://|www\\.)[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(.*)?$"
                                let urlTest = NSPredicate(format: "SELF MATCHES %@", urlPattern)
                                
                                if urlTest.evaluate(with: trimmedValue) {
                                    hudMsg = ""
                                    showHud = false
                                } else {
                                    hudMsg = """
            Please enter a valid website link:
            - Starts with http://, https://, or www.
            - Includes a valid domain (e.g., .com, .org).
            """
                                    showHud = true
                                }
                            }).textContentType(.URL)
                                .keyboardType(.URL)
                            
                                //                        AuthTextField(floatingLabel: "Industry", placeholder: "", icon: .gradCap, text: $request.industry, enteredText: {
                                //                            value in
                                //                            request.industry = value
                                //                        }).textContentType(.organizationName)
                            
                            DropDownTextField(
                                hint: "Select your Company Industry type",
                                floatingLabel: "Industry",
                                text: $request.industry,
                                options: $categoriesList,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                anchor: .top)
                            .zIndex(2100.0)
                            
                            DropDownTextField(
                                hint: "Enter your location",
                                floatingLabel: "Address",
                                text: $request.address,
                                options: $locationArr,
                                leadingIcon: .location,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                anchor: .top)
                            .zIndex(2300.0)
                            .textContentType(.location)
                            .onChange(of: request.address) { newValue in
                                GooglePlacesManager.shared.findPlaces(query: newValue) { result in
                                    switch result {
                                    case .success(let places):
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            locationArr = places.map { $0.name }
                                            placeSuggestions = places // Store Place objects for lookup
                                        }

                                        // Try to resolve lat/long if user selected an exact match
                                        if let selectedPlace = places.first(where: { $0.name == newValue }) {
                                            GooglePlacesManager.shared.resolveLocation(for: selectedPlace) { result in
                                                switch result {
                                                case .success(let coordinate):
                                                    request.latitude = String(coordinate.latitude)
                                                    request.longitude = String(coordinate.longitude)
                                                case .failure(let error):
                                                    print("Failed to get coordinates: \(error)")
                                                }
                                            }
                                        }
                                    case .failure(let error):
                                        print("Failed to find places: \(error)")
                                    }
                                }
                            }

                            
                            
                            
                            AuthTextField(floatingLabel: "Phone Number", placeholder: "Enter Phone Number", icon: .phone, text: $request.phone, enteredText: {
                                value in
                                request.phone = String(value.filter(\.isWholeNumber).prefix(10)).toPhoneNumberUs()
                            })
                            .textContentType(.telephoneNumber)
                            .keyboardType(.numberPad)
                            .onChange(of: request.phone, perform: { value in
                                request.phone = String(value.prefix(10))
                            })
                            
                            AuthTextField(floatingLabel: "Company Size", placeholder: "# of employees", icon: .benefits, text: $request.size, enteredText: {
                                value in
                                request.size = value
                            })
//                            .keyboardType(.numberPad)
                            
                                //                        AuthTextField(floatingLabel: "Company Type", placeholder: "Enter Company Type", icon: .gradCap, text: $request.type, enteredText: {
                                //                            value in
                                //                            request.type = value
                                //                        })
                            
                            DropDownTextField(
                                hint: "Select your Company type",
                                floatingLabel: "Company Type",
                                text: $request.type,
                                options: $categoriesList,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                anchor: .top)
                            .zIndex(1300.0)
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Logo")
                                        .font(.custom(nunitoBold, size: 15))
                                        .bold()
                                        .foregroundStyle(.text)
                                    Spacer()
                                }
                                
                                if selectedImagesURL.count == 0 {
                                    Button(action: { showActionSheet = true }, label: {
                                        Image(.plusBtn)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundStyle(.black.opacity(0.5))
                                            .padding(.all, 5)
                                    })
                                } else {
                                    HStack {
                                        Spacer()
                                        KFImage.url(getMediaURL(url: request.logo))
                                            .placeholder({
                                                Image(uiImage: selectedImage ?? UIImage(resource: .organisation))
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .padding(.all)
                                                    .foregroundStyle(.text.opacity(0.5))
                                            })
                                            .retry(maxCount: 3, interval: .seconds(5))
                                            .cacheOriginalImage()
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .overlay(alignment: .topTrailing) {
                                                Button(action: {
                                                    request.logo = ""
                                                    withAnimation { selectedImagesURL.removeAll() }
                                                }, label: {
                                                    Image(.cancel)
                                                        .renderingMode(.template)
                                                        .resizable()
                                                        .tint(.pinkBtn)
                                                        .frame(width: 25, height: 25)
                                                        .padding(.all, 2)
                                                        .background(.white)
                                                        .clipShape(Circle())
                                                })
                                            }
//                                            .frame(width: 200, height: 200)
                                        Spacer()
                                    }
                                }
                            }
                            
                            AuthTextField(floatingLabel: "Company Tagline", placeholder: "Not Mandatory", icon: .licensure, text: $request.tag_line, enteredText: {
                                value in
                                request.tag_line = value
                            })
                            
                            
                            PrimaryButton(
                                title: isEdit ? "Update" : "Continue",
                                isOutLine: false,
                                onButtonClick: {
                                    withAnimation { validate() }
                                }).padding(.vertical)
                        }.padding(.horizontal)
                    }
                    .scrollIndicators(.never)
                    
                Spacer()
            }
            .padding(.top, -topPadding)
            .sheet(isPresented: $showImagePicker, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $showImagePicker) { image, imageURL in
                    if let url = imageURL {
                        if let img = image {
                            selectedImage = img
                            withAnimation(.easeOut) {
                                selectedImagesURL.append(Imagee(image: url))
                                showImagePicker = false
                            }
                        }
                    }
                }
            })
            .actionSheet(isPresented: $showActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [ActionSheet.Button.default(Text("Take a Photo").font(.custom(nunitoRegular, size: 14)), action: {
                    imageSelectorSource = .camera
                    showImagePicker = true
                }), ActionSheet.Button.default(Text("Choose from Gallery"), action: {
                    imageSelectorSource = .photoLibrary
                    showImagePicker = true
                }), ActionSheet.Button.cancel()])
            }
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        checkCloseStatus = false
                        if alertType.primaryBtnText != "Create Company" {
                            if isEdit || isProfileFlow {
                                dismiss()
                            } else {
                                navigateToSubscription = true
                            }
                        }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                        if checkCloseStatus {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0125) {
                                    exit(0)
                                }
                            }
                        }
                        
                    })
            })
            .onTapGesture {
                UIApplication.shared.endEditing()}
            .onAppear {
                print(requestSignUp.first_name)
                
                viewModal = CompanyDetailViewModal()
                if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                    data.category.forEach { type in
                        industryTypeArr.append(type.name)
                    }
                }
                
                if isEdit {
                    if let data: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                        request.company_id = "\(data.company_data?.id ?? 0)"
                        request.name = data.company_data?.company_name ?? ""
                        request.website_link = data.company_data?.company_website_link ?? ""
                        request.industry = data.company_data?.company_industry ?? ""
                        request.address = data.company_data?.company_address ?? ""
                        request.phone = data.company_data?.company_phone ?? ""
                        request.size = data.company_data?.company_size ?? ""
                        request.type = data.company_data?.company_type ?? ""
                        request.tag_line = data.company_data?.company_tag_line ?? ""
                        if data.company_data?.company_logo ?? "" != "" {
                            request.logo = data.company_data?.company_logo ?? ""
                            selectedImagesURL.append(Imagee(image: data.company_data?.company_logo ?? ""))
                        }
                        request.latitude = data.company_data?.latitude
                        request.longitude = data.company_data?.longitude
                    }
                }
                self.viewModal?.getCategories()
                observe()
            }
            
                //MARK: - Loading Indicator
            if showLoading {
                Loader(isLoading: $showLoading)
            }
            
            CusNavLink(doNavigate: $navigateToSubscription, destination: LoginScreen())

            
            CusNavLink(doNavigate: $navigatetoUser, destination: SignUpScreen(requestCompany : CreateCompanyRequest(company_id: "", name: request.name, website_link: request.website_link, industry: request.industry, address: request.address, phone: request.phone, size: request.size, type: request.size, tag_line: request.tag_line, logo: request.logo)))
        }
    }
    
    //MARK: - Validate Details
    func validate() {
        guard request.name != "" else {
            hudMsg = "Please provide Company name"
            showHud = true
            return
        }
        
        let urlPattern = "^(https?://|www\\.)[a-zA-Z0-9\\-\\.]+\\.[a-zA-Z]{2,}(.*)?$"
        let trimmedLink = request.website_link.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: trimmedLink),
              (url.scheme == "http" || url.scheme == "https" || trimmedLink.hasPrefix("www.")),
              NSPredicate(format: "SELF MATCHES %@", urlPattern).evaluate(with: trimmedLink) else {
            hudMsg = """
    Please provide a proper Company Website Link:
    - Must start with http://, https://, or www.
    - Must include a valid domain (e.g., .com, .org, .net).
    """
            showHud = true
            return
        }
        
        guard request.industry != "" else {
            hudMsg = "Please select Company Industry"
            showHud = true
            return
        }
        
        guard request.address != "" else {
            hudMsg = "Please provide Company Address"
            showHud = true
            return
        }
        
        guard request.phone != "" else {
            hudMsg = "Please provide Company Phone Number"
            showHud = true
            return
        }
        
        
        guard request.type != "" else {
            hudMsg = "Please provide Company Type"
            showHud = true
            return
        }
        

        
        request.phone = request.phone.filter(\.isWholeNumber)


        observe()
        if isLoginFlow{
            observeSignUp()
            viewModel.register(parameters: RegisterRequest(first_name: UserDefaults.firstName, last_name: UserDefaults.lastName, user_name: UserDefaults.userNameAdd, email: UserDefaults.userEmail, password: UserDefaults.password, password_confirmation: UserDefaults.password, location: UserDefaults.userLocaion, role_id: UserDefaults.userRole, linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: "")))
        }else{
                    if selectedImagesURL.count > 0 {
                        viewModal?.createCompanyWithImage(parameters: request, images: [selectedImagesURL.first?.image ?? ""])
                    } else {
                        viewModal?.createCompany(param: request)
                    }
        }
   }
    
    //MARK: - ViewModal Observer
    func observe() {
        viewModal?.eventHandler = {
            event in
            switch event {
                case .loading:
                    showLoading = true
                case .stopLoading:
                    showLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
    
    func observeSignUp() {
        viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.showLoading = true
            case .stopLoading:
                self.showLoading = false
            case .dataLoaded:
                handleSuccessSignUp()
            case .error(let error):
                self.showLoading = false
                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
    }
    
    //MARK: - ViewModal Success Handler
    func handleSuccess() {
        if viewModal?.requestType == "CreateCompanyProfile" {
            if let response = viewModal?.companyResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Continue", secondaryBtnText: "", sheetThemeColor: .green)
                    viewModal?.getDetail()
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
                }
            }
        } else if viewModal?.requestType == "GetDetail" {
            if let response = viewModal?.response {
                if response.status == "success" {
                    UserDefaultsManager.shared.setModel(response.data, forKey: .userDetail)
                    withAnimation(.easeIn) { showAlert = true }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
                }
            }
        }else{
            if let response = viewModal?.categoriesResponse {
                if response.status == "success" {
                    categoriesArr = response.data
                    response.data.forEach({ data in
                        if !categoriesList.contains(data.name ?? "") {
                            categoriesList.append(data.name ?? "")
                        }
                    })
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
            
        }
    }
    
    
    func handleSuccessSignUp() {
        
        if viewModel.signUpResponceDict.status == "success" {
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.token, forKey: .token)
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.role_id, forKey: .userRoleId)
            UserDefaultsManager.shared.setValue(viewModel.signUpResponceDict.data?.role_id == "2" ? "employee" : "employer", forKey: .userRole)
            if selectedImagesURL.count > 0 {
                request.phone = request.phone.filter(\.isWholeNumber)
                viewModal?.createCompanyWithImage(parameters: request, images: [selectedImagesURL.first?.image ?? ""])
            } else {
                request.phone = request.phone.filter(\.isWholeNumber)
                viewModal?.createCompany(param: request)
            }
        } else {
            alertType = .sheetType(icon: .alert, title: viewModel.signUpResponceDict.status.capitalized , message: viewModel.signUpResponceDict.message.capitalized , primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            showAlert = true
        }
        
    }
}

//struct ContentView: View {
//    @State private var text = ""
//    
//    var body: some View {
//        VStack {
//            TextEditor(text: $text)
//                .font(.body)
//                .padding()
//            
//            HStack {
//                Button(action: {
//                    applyFormatting(.bold)
//                }) {
//                    Text("Bold")
//                }
//                .padding()
//                
//                Button(action: {
//                    applyFormatting(.italic)
//                }) {
//                    Text("Italic")
//                }
//                .padding()
//                
//                Button(action: {
//                    applyBullet()
//                }) {
//                    Text("Bullet")
//                }
//                .padding()
//            }
//        }
//    }
//    
//    private func applyFormatting(_ formatting: TextFormatting) {
//            // Get the selected text range or cursor position
//        guard let range = selectedRange() else { return }
//        
//            // Apply the selected formatting to the text
//        switch formatting {
//            case .bold: break
//                    // Apply bold formatting to the selected range
//                    // Update the text with the new formatting
//            case .italic:
//                    // Apply italic formatting to the selected range
//                    // Update the text with the new formatting
//        }
//    }
//    
//    private func applyBullet() {
//            // Insert a bullet at the cursor position
//            // Update the text with the new bullet
//    }
//    
//    private func selectedRange() -> NSRange? {
//            // Implement logic to get the selected range or cursor position
//            // Return nil if no text is selected
//        return nil
//    }
//}
//
//enum TextFormatting {
//    case bold
//    case italic
//    case bullet
//}

#Preview {
    EmployerCreateCompany()
}
extension String {
    func toPhoneNumberUs() -> String {
        let numbers = self.filter { $0.isNumber } // Keep only numbers
        let formatted: String
        
        if numbers.count == 10 {
            let areaCode = numbers.prefix(3)
            let centralOfficeCode = numbers.dropFirst(3).prefix(3)
            let lineNumber = numbers.dropFirst(6)
            formatted = "(\(areaCode)) \(centralOfficeCode)-\(lineNumber)"
        } else {
            formatted = self // Return original if not 10 digits
        }
        
        return formatted
    }
}

