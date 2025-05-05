//
//  UserCreateProfile.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 24/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet

struct UserCreateProfile: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State var isToggleOn: Bool = false
    @State var isLoading: Bool = false
    @State var navigateToProfileImgSelector: Bool = false
    
    @State var request: CreateUserProfSection = CreateUserProfSection(is_student: "0", most_recent_job_title: "", most_recent_company: "", your_dream_job: "", job_category_id: "", profile_image: "")
    @State var requestSignUp: RegisterRequest = RegisterRequest(first_name: "", last_name: "", user_name: "", email: "", password: "", password_confirmation: "", location: "", role_id: "", linkedin_sub_id: "", linkedin_access: LinkedInAccessModel(access_token: "", expires_in: 0, scope: "", token_type: "", id_token: ""))
    @State var categoriesArr: [userCategories] = []
    @State var categoriesList : [String] = []
    @State var viewModal = UserCreateProfileViewModal()
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var categoryId: String = ""

    @State var email: String = ""
    @State var password: String = ""
    @State var role: String = ""
    @State var location: String = ""


    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
        
    @State var hudMsg: String = ""
    @State var showHud: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                PrimaryHeader(
                    title: "Create Profile",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        
                        self.presentationMode.wrappedValue.dismiss()
//                        UIApplication.shared.endEditing()
//                        alertType = .sheetType(icon: .alert, title: "Alert", message: "Without creating your basic profile you can not use this Application.", primaryBtnText: "Create Profile", secondaryBtnText: "Close Application", sheetThemeColor: .text)
//                        showAlert = true
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 16, content: {
                        Text("Your profile helps you discover people and opportunities")
                            .font(.custom(nunitoBlack, fixedSize: 24))
                            .multilineTextAlignment(.leading)
                            .padding([.top, .horizontal])
                        
                        HStack(content: {
                            Text("I'm a student")
                                .font(.custom(nunitoSemiBold, fixedSize: 16))
                                .foregroundStyle(.text)
                            
                            Spacer()
                            
                            Toggle("", isOn: $isToggleOn)
                                .tint(.text)
                        })
                        .padding(.all)
       //                 .background(.backGround)
                        
                        Section {
                            
                            if !isToggleOn {
                                AuthTextField( floatingLabel: "Most Recent Job Title", placeholder: "Enter Job Title", icon: .bag, text: $request.most_recent_job_title.toUnwrapped(defaultValue: ""), enteredText: {
                                    value in
                                    request.most_recent_job_title = value
                                })
                                
                                AuthTextField( floatingLabel: "Most Recent Company", placeholder: "Enter Company Name", icon: .menuNews, text: $request.most_recent_company.toUnwrapped(defaultValue: ""), enteredText: {
                                    value in
                                    request.most_recent_company = value
                                })
                            }
                            
                            AuthTextField( floatingLabel: "Your Dream Job", placeholder: "Enter Job Title", icon: .bag, text: $request.your_dream_job.toUnwrapped(defaultValue: ""), enteredText: {
                                value in
                                request.your_dream_job = value
                            })
                            
                            DropDownTextField(
                                hint: "Select your Job Category",
                                floatingLabel: "Preferred Job Category",
                                text: $categoryId,
                                options: $categoriesList,
                                leadingIcon: .licensure,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                anchor: .top)
                            
                        }.padding(.horizontal)
                        
                        PrimaryButton(title: "Next", isOutLine: false, onButtonClick: {
                            
                            UIApplication.shared.endEditing()
                            
                            if !isToggleOn {
                                guard !(request.most_recent_job_title ?? "" == "") else {
                                    hudMsg = "Please enter Most Recent Job Title."
                                    showHud = true
                                    return
                                }
                                
                                guard !(request.most_recent_company ?? "" == "") else {
                                    hudMsg = "Please enter Most Recent Company."
                                    showHud = true
                                    return
                                }
                            }
                            
                            guard !(request.your_dream_job ?? "" == "") else {
                                hudMsg = "Please enter Your Dream Job"
                                showHud = true
                                return
                            }
                            
                            request.is_student = isToggleOn ? "1" : "0"
                            request.job_category_id = categoryId != "" ? "\(viewModal.categoriesResponse?.data.first(where: { $0.name == categoryId })?.id ?? 0)" : ""

                            
                            withAnimation(.easeInOut) { navigateToProfileImgSelector = true }
                        }).padding(.all)
                    })
                })
                .padding(.top, -topPadding)
                .onTapGesture(perform: {
                    UIApplication.shared.endEditing()
                })
                .toast(isPresenting: $showHud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
                .onAppear(perform: {
                    print(firstName)
                    observe()
                    self.viewModal.getCategories()
//                    if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//                        data.category.forEach { cate in
//                            categoriesArr.append(cate.name)
//                        }
//                    }
                })
                
                Spacer()
            }
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0125) {
                                exit(0)
                            }
                        }
                    })
            })
            
            CusNavLink(doNavigate: $navigateToProfileImgSelector, destination: UserProfileImgSelection(firstName: firstName, request: $request,requestSignUp: $requestSignUp))
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
        
            if let response = viewModal.categoriesResponse {
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

#Preview {
    UserCreateProfile()
}
