//
//  EmployerCompanyScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import SwiftUI
import BottomSheet

struct EmployerCompanyScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var userDetail: UserDetailModal = UserDetailModal()
    
    @State var isLoading: Bool = true
    @State var navigateToUpdateProfile: Bool = false
    @State var navigateToLinkedIn: Bool = false
    @State var navigateToCreateCompany: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var navigateToSubscription: Bool = false
  //  @State var navigateToGoogleCalender: Bool = false
    @State var eventData: String = ""

    
    var viewModal = CompanyDetailViewModal()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0, content: {
                HeaderWithImageTitle(
                    title: "My Company",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    userName: .constant(userDetail.company_data?.company_name ?? ""),
                    userImg: .constant(userDetail.company_data?.company_logo ?? ""))
                
                VStack {
                    if isLoading {
                        EmptyView()
                    } else {
                        ScrollView(showsIndicators: false, content: {
                            VStack(alignment: .leading, spacing: 12, content: {
                                
                                Text("Company Details")
                                    .font(.custom(nunitoRegular, fixedSize: 13))
                                    .foregroundStyle(.black)
                                
                                HStack {
                                    Text("Company Name")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_name ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                HStack(alignment: .top) {
                                    Text("Website link")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_website_link ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                HStack {
                                    Text("Industry")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_industry ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
//                                        .kerning(4)
                                        .foregroundStyle(.black)
                                }
                                
                                HStack {
                                    Text("Phone Number ")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_phone?.toPhoneNumber() ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                HStack {
                                    Text("Company Size")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_size ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                
                    
                                
//                                Divider()
                                
                                HStack {
                                    Text("Company Tagline")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_tag_line?.capitalized ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                HStack(alignment: .top) {
                                    Text("Address")
                                        .font(.custom(nunitoRegular, fixedSize: 13))
                                        .foregroundStyle(.gray)
                                    
                                    Spacer()
                                    
                                    Text(userDetail.company_data?.company_address ?? " - ")
                                        .font(.custom(nunitoRegular, fixedSize: 15))
                                        .foregroundStyle(.black)
                                }
                                
                            })
                            .padding(.all)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
                            )
                            .padding(.top)
                            .padding(.horizontal)
                            .padding(.bottom,20)

                            SubscriptionCard(userDetail: userDetail)
                            .padding(.horizontal)
                            
                                .padding(.bottom)
                        })
                        .refreshable(action: {
                            generateFeedback(type: .medium)
                            isLoading = true
                            self.viewModal.getDetail()
                        })
                        Spacer()
                        
                        if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                            PrimaryButton(
                                title: "Update Profile", isOutLine: false, onButtonClick: {
                                    navigateToUpdateProfile = true
                                })
                            .padding()
                        }else{
                            if UserDefaults.companyWriteAccess{
                                PrimaryButton(
                                    title: "Update Profile", isOutLine: false, onButtonClick: {
                                        navigateToUpdateProfile = true
                                    })
                                .padding()
                            }
                            
                        }
                        
                    }
                }
    //            .background(.backGround)
                .padding(.top, -topPadding)
                .onAppear(perform: {
                    isLoading = true
//                    NotificationCenter.default.addObserver(self, selector: #selector(handleData(_:)), name: Notification.Name("EventsDataGoogle"), object: nil)
                    
                    
                    viewModal.getDetail()
                    observe()
                })
                .onTapGesture(perform: {
                    UIApplication.shared.endEditing()
                })
                
                Spacer()
            })

            
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
                if alertType.primaryBtnText == "Proceed" {
                    showAlert = true
                }
            }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        if alertType.primaryBtnText == "Proceed" {
                            navigateToCreateCompany = true
                        }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                        if alertType.secondaryBtnText == "Go Back" {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    })
            })
            .fullScreenCover(isPresented: $navigateToLinkedIn) {
                ZStack {
                    
                    VStack(spacing: 0) {
                        
                        PrimaryHeader(
                            title: "LinkedIn",
                            trailingImgArr: [.cancel],
                            onClickTrailing: { _ in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    navigateToLinkedIn = false
                                }
                            }, count: .constant(0))
                        
                        LinkedInViewContainer(url: LinkedInConstants.AUTHURL + "?response_type=code&client_id=" + LinkedInConstants.CLIENT_ID + "&scope=" + LinkedInConstants.SCOPE + "&client_secret=" + LinkedInConstants.CLIENT_SECRET + "&redirect_uri=" + LinkedInConstants.REDIRECT_URI) { result in
                            switch result {
                                case .success(authCode: let authCode):
                                    withAnimation { navigateToLinkedIn = false }
                                    self.viewModal.linkLinkedIn(param: LinkedInLinkModel(code: authCode))
                                    observe()
                                case .inProgress:
                                    isLoading = true
                                case .aceessDenied, .loginCancel, .loginFailed, .error(error: _):
                                    withAnimation { navigateToLinkedIn = false }
                                    alertType = .sheetType(icon: .alert, title: "Error", message: result.message(), primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                                    showAlert = true
                                    return
                                case .stopLoading:
                                    isLoading = false
                            }
                        }
                    }
                    
                    if isLoading {
                        Loader(isLoading: $isLoading)
                    }
                }
            }

            
            if isLoading {
                Loader(isLoading: $isLoading)
            }

            
            CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen( isSubscription: userDetail.subscription ?? SubscriptionStatus()))
           
            CusNavLink(doNavigate: $navigateToUpdateProfile, destination: EmployerCreateCompany(isEdit: true))
            CusNavLink(doNavigate: $navigateToCreateCompany, destination: EmployerCreateCompany(isProfileFlow: true))
        }
    }

    
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = true
                case .dataLoaded:
                    handleSuccess()
                isLoading = false
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                    return
            }
        }
    }
    
    func handleSuccess() {
        if viewModal.requestType == "GetDetail" {
            if let response = viewModal.response {
                if response.status == "success" {
                    userDetail = response.data
                    if userDetail.emp_company_created ?? false == false {
                        alertType = .sheetType(icon: .alert, title: "Alert", message: "You have not created your Company Profile yet. Please proceed to create your Company Profile.", primaryBtnText: "Proceed", secondaryBtnText: "Go Back", sheetThemeColor: .pinkBtn)
                        showAlert = true
                    }
                    UserDefaultsManager.shared.setModel(response.data, forKey: .userDetail)
                    if userDetail.employer_matches_count != "" {
                        if let count: Int = Int(userDetail.employer_matches_count ?? "0") {
                            UserDefaultsManager.shared.setValue(count > 0, forKey: .isSubscribed)
                            if count > 0 {
                                UserDefaultsManager.shared.setValue(userDetail.subscription?.product_id ?? "", forKey: .subscriptionType)
                            }
                        }
                    }
                }
            }
        } else if viewModal.requestType == "LinkLinkedIn" {
            if let response = viewModal.linkedInResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                    viewModal.getDetail()
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    EmployerCompanyScreen()
}
