//
//  DocumentUploadScreen.swift
//  imperium
//
//  Created by JAM-E-221 on 23/01/25.
//

import SwiftUI
import AlertToast
import BottomSheet

struct DocumentUploadScreen: View {
    //MARK: Static Properties
@Environment(\.presentationMode) var presentationMode
@State var isLoading: Bool = false
@State var showAlert: Bool = false
@State var navigateToMenu: Bool = false
@State var navigateToNotification: Bool = false
@State var notiCount: Int = 0
@State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
@State private var selectedFileURL: URL? // State variable to hold the file URL from DocView

@State var showHud: Bool = false
@State var hudMsg: String = ""

@State var request: BusinessModelParam = BusinessModelParam(ein_number: "", business_email: "", id: "", business_name: "", file: "")

    //MARK: Properties
var contactUsViewModel = ContactUsViewModel()

    //MARK: Primary View
var body: some View {
    ZStack {
        VStack(spacing: 0, content: {
            PrimaryHeader(title: "Upload Document", leadingImgArr: [.sideArrow], trailingImgArr: [.notification,.sideMenu], onClickLeading: { _ in
                self.presentationMode.wrappedValue.dismiss()
            }, onClickTrailing: { ind in
                switch ind {
                    case 1:
                        navigateToMenu = true
                    default:
                        navigateToNotification = true
                }
            }, showAppIcon: true, count: $notiCount)
            
            VStack(alignment: .leading) {
                
                TitleWithLine(title: "Upload Document", lineLength: 36)
                    .padding([.top, .horizontal])
                
                ScrollView(showsIndicators: false){
                    VStack(spacing: 16, content: {
                        AuthTextField(floatingLabel: "Business Name", placeholder: "Enter Business Name", icon: .mail, text: $request.business_name) { email in
                            request.business_name = email
                        }.textContentType(.emailAddress)
                        
                        AuthTextField(floatingLabel: "Business Email", placeholder: "Enter Business Email", icon: .mail, text: $request.business_email) { email in
                            request.business_email = email
                        }.textContentType(.emailAddress)
                        
                        AuthTextField(floatingLabel: "EIN Number", placeholder: "EIN Number", icon: .phone, text: $request.ein_number) { password in
                            // This closure updates the EIN number on change
                            request.ein_number = String(password.filter(\.isWholeNumber).prefix(9)).toPhoneNumberUs()
                        }
                        .textContentType(.telephoneNumber)
                        .keyboardType(.numberPad)
                        .onChange(of: request.ein_number, perform: { value in
                            request.ein_number = String(value.filter(\.isWholeNumber).prefix(9)).toPhoneNumber()
                        })


                        
                        DocView(selectedFileURL: $selectedFileURL)
                        if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                            
                            PrimaryButton(title: "Submit",isOutLine: false) {
                                validate()
                            }
                        }else{
                            if UserDefaults.DocWrite{
                                PrimaryButton(title: "Submit",isOutLine: false) {
                                    validate()
                                }
                            }
                        }
                    }).padding([.horizontal, .vertical])
                }
                Spacer()
            }
            .background(.text.opacity(0.05))
            .padding(.top, -topPadding)
            
            Spacer()
        })
        .onAppear(perform: {
            observe()
            self.contactUsViewModel.getBusinessDetails()
            saveDummyFile()
        })
        .onTapGesture {
            UIApplication.shared.endEditing()}
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
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
        
        CusNavLink(doNavigate: $navigateToNotification, destination: NotificationScreen())

        .fullScreenCover(isPresented: $navigateToMenu, content: {
            NavigationContainer {
                if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
                    if role != "employer" {
                        UserHomeScreen()
                    }else{
                        EmployerHomeScreen()
                    }
                }
               
            }
        })
        
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation { showAlert = false }
//                    }, rightButtonAction: {
//                        withAnimation { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
    }
    .edgesIgnoringSafeArea(.bottom)
}
    
    func isValidEIN(_ value: String) -> Bool {
        return value.count == 9
    }


func validate() {
    

    
    guard request.business_name != "" else {
        hudMsg = "Business name is required."
        showHud = true
        return
    }
    
    guard request.business_email != "" else {
        hudMsg = "Business email is required."
        showHud = true
        return
    }
    guard request.ein_number != "" else {
        hudMsg = "EIN is required."
        showHud = true
        return
    }
    
    guard request.ein_number.count > 8 else {
        hudMsg = "Valid EIN is required."
        showHud = true
        return
    }
    
    guard request.business_email.isValidEmail() else {
        hudMsg = "Email is required."
        showHud = true
        return
    }
    
    
    guard let fileURL = selectedFileURL, !fileURL.absoluteString.isEmpty else {
        hudMsg = "Certificate is required."
        showHud = true
        return
    }

    

    
    
    Task {

        checkFileExistence()
        
        
        if let fileURL = selectedFileURL {
            let fileString = fileURL.absoluteString
            self.contactUsViewModel.createCompanyWithImage(parameters: request, images: [fileString])
        } else {
            print("No file selected")
        }



    }
}
    func saveDummyFile() {
        // Get the Document Directory
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate document directory.")
            return
        }

        // Create the file URL
        let fileURL = documentDirectory.appendingPathComponent("dummy-pdf_2.pdf")
        print("Saving file to: \(fileURL.path)")

        // Dummy data for testing
        let dummyData = "This is a dummy PDF content.".data(using: .utf8)

        // Write the file
        do {
            try dummyData?.write(to: fileURL)
            print("File saved successfully at: \(fileURL.path)")
        } catch {
            print("Failed to save file: \(error.localizedDescription)")
        }
    }
    func checkFileExistence() {
        let fileManager = FileManager.default
        guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to locate document directory.")
            return
        }

        let fileURL = documentDirectory.appendingPathComponent("dummy-pdf_2.pdf")
        print("Checking file at: \(fileURL.path)")

        if fileManager.fileExists(atPath: fileURL.path) {
            print("File exists at path: \(fileURL.path)")
            let pathstring = fileURL.absoluteString
            self.contactUsViewModel.createCompanyWithImage(parameters: request, images: [pathstring])
        } else {
            print("File does not exist at path: \(fileURL.path)")
        }
    }

func observe() {
    self.contactUsViewModel.eventHandler = { event in
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

func handleSuccess() {
    if contactUsViewModel.requestType == "getBusinessDetails"{
        let response = contactUsViewModel.businessModelDict
        if response.status == "success" {
            if response.data?.isEmpty != true{
                request.business_name = response.data?[0].business_name ?? ""
                request.business_email = response.data?[0].business_email ?? ""
                request.ein_number = response.data?[0].ein_number ?? ""
                 let id = "\(response.data?[0].id ?? 0)"
                request.id = id

            }
        }
    }else if contactUsViewModel.requestType == "UpdateBusinessDetails"{
        let response = contactUsViewModel.updateBusineedModelDict
        if response.status == "success" {
            alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
            withAnimation { showAlert = true }
        } else {
            alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
            withAnimation { showAlert = true }
        }
    }
}
}


#Preview {
    DocumentUploadScreen()
}
