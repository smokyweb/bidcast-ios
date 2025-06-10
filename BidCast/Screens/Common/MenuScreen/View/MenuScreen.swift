//
//  MenuScreen.swift
// BidSwipe
//
//  Created by JAM-E-282 on 22/01/24.
//

import SwiftUI
import SwiftfulLoadingIndicators
//import BottomSheet

struct MenuModal: Identifiable {
    var id = UUID()
    let title: String
    let img: ImageResource
}

struct MenuScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @State var userMenuOption: [MenuModal] = [
        MenuModal(title: "Home", img: .menuHome),
        MenuModal(title: "Profile", img: .menuProfile),
        MenuModal(title: "Second Look", img: .menuSecondLook),
        MenuModal(title: "Interview List", img: .menuTos),
        MenuModal(title: "About Us", img: .organisation),
        MenuModal(title: "News", img: .menuNews),
        MenuModal(title: "Contact Us", img: .menuContactUs),
        MenuModal(title: "Terms of Service", img: .menuTos),
        MenuModal(title: "Privacy Policy", img: .menuTos),
        MenuModal(title: "Delete Account", img: .trash),
        MenuModal(title: "Logout", img: .menuLogout),
    ]
    
    @State var employerMenuOption: [MenuModal] = [
        MenuModal(title: "Home", img: .menuHome),
        MenuModal(title: "My Company", img: .menuProfile),
        MenuModal(title: "Calendar Management", img: .menuTos),
        MenuModal(title: "Interview List", img: .menuTos),
        MenuModal(title: "About Us", img: .organisation),
        MenuModal(title: "News", img: .menuNews),
        MenuModal(title: "Verification", img: .menuTos),
        MenuModal(title: "User List", img: .menuProfile),
        MenuModal(title: "Contact Us", img: .menuContactUs),
        MenuModal(title: "Terms of Service", img: .menuTos),
        MenuModal(title: "Privacy Policy", img: .menuTos),
        MenuModal(title: "Delete Account", img: .trash),
        MenuModal(title: "Logout", img: .menuLogout)
    ]
    
    
    @State var companyUserMenuOption: [MenuModal] = {
        var menu: [MenuModal] = [
            MenuModal(title: "Home", img: .menuHome)
        ]
        
        if UserDefaults.companyReadAccess {
            menu.append(MenuModal(title: "My Company", img: .menuProfile))
        }
        if UserDefaults.CalendarRead {
            menu.append(MenuModal(title: "Calendar Management", img: .menuTos))
        }
        if UserDefaults.InterViewRead {
            menu.append(MenuModal(title: "Interview List", img: .menuTos))
        }
        if UserDefaults.DocRead {
            menu.append(MenuModal(title: "Verification", img: .menuTos))
        }

        menu += [
            MenuModal(title: "My Profile", img: .organisation),
            MenuModal(title: "About Us", img: .organisation),
            MenuModal(title: "News", img: .menuNews),
            MenuModal(title: "Contact Us", img: .menuContactUs),
            MenuModal(title: "Terms of Service", img: .menuTos),
            MenuModal(title: "Privacy Policy", img: .menuTos),
            MenuModal(title: "Logout", img: .menuLogout)
        ]
        
        return menu
    }()



    
    @State var employerMenuOptionResume: [MenuModal] = [
        MenuModal(title: "Home", img: .menuHome),
        MenuModal(title: "My Interests", img: .menuTos),
        MenuModal(title: "Decline Candidates", img: .menuTos),
        MenuModal(title: "My Company", img: .menuProfile),
        MenuModal(title: "Calendar Management", img: .menuTos),
        MenuModal(title: "Interview List", img: .menuTos),
        MenuModal(title: "About Us", img: .organisation),
        MenuModal(title: "News", img: .menuNews),
        MenuModal(title: "Contact Us", img: .menuContactUs),
        MenuModal(title: "Terms of Service", img: .menuTos),
        MenuModal(title: "Privacy Policy", img: .menuTos),
        MenuModal(title: "Delete Account", img: .trash),
        MenuModal(title: "Logout", img: .menuLogout)
    ]
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .error(title: "", message: "", leftBtnText: "", rightBtnText: "")
    @State var userRole: String = ""
    @State var comeFromResume: Bool = false
    @State var jobDetail: JobDetailResponse = JobDetailResponse()

        //MARK: - Navigation Variables
    @State var navigateToProfile: Bool = false
    @State var navigateToSecondLook: Bool = false
    @State var navigateToAboutUs: Bool = false
    @State var navigateToNews: Bool = false
    @State var navigateToContactUs: Bool = false
    @State var navigateToDocument: Bool = false
    @State var navigateToTOS: Bool = false
    @State var navigateToPrivPoli: Bool = false
    @State var userLogOut: Bool = false
    @State var navigateToCompany: Bool = false
    @State var navigateToCompanyUserProfile: Bool = false
    @State var navigateToSubCompany: Bool = false
    @State var navigateToGoogleCalender: Bool = false
    @State var navigateTointerviewList: Bool = false
    @State var navigateTodeleteAccount: Bool = false
    @State var navigateToSubscription: Bool = false
    @State var navigateToDecline: Bool = false
    @State var navigateToInterest : Bool = false
    
    @State var viewModel = MenuOptionsViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                PrimaryHeader(title: "Menu", trailingImgArr: [.cancel], onClickTrailing:  { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                ScrollView(showsIndicators: false, content: {
                    VStack(spacing: 16) {
                        if comeFromResume{
                            ForEach(userRole == "employee" ? userMenuOption : employerMenuOptionResume)
                            {
                                menu in
                                MenuListCard(menu: menu, onMenuClick: {
                                    option in
                                    handleMenuClick(option: option)
                                })
                            }
                        }else{
                        

                            
                            ForEach(userRole == "employee" ? userMenuOption :
                                        userRole == "employer" ? employerMenuOption :
                                        companyUserMenuOption)
                            {
                                menu in
                                MenuListCard(menu: menu, onMenuClick: {
                                    option in
                                    handleMenuClick(option: option)
                                })
                            }
                        }
                    }.padding([.horizontal, .vertical])
                }).padding(.top, -topPadding)
            }
            .onAppear(perform: {
               
                if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
                    userRole = role
                }
            })
            .bottomSheet(isPresented: $userLogOut, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { userLogOut = true }, content: {
                LogOutSheet(onLogoutClick: {
                    withAnimation(.snappy) { userLogOut = false }
                    Task{
                        await viewModel.logOut()
                        if viewModel.errorMessage == nil {
                            handleSuccess()
                        } else {
                           
                        }
                        
                    }
                }, onCancelClick: {
                    withAnimation(.snappy) { userLogOut = false }
                })
            })
            
            if isLoading {
                LoadingIndicator()
            }
            
            if showAlert {
                AlertPopUp(
                    presentAlert: $showAlert,
                    alertType: alertType,
                    leftButtonAction: {
                        showAlert = false
                    }, rightButtonAction: {
                        showAlert = false
                    })
            }
            
//            CusNavLink(doNavigate: $navigateToAboutUs, destination: AboutUsScreen())
//            CusNavLink(doNavigate: $navigateToNews, destination: NewsScreen())
//            CusNavLink(doNavigate: $navigateToContactUs, destination: ContactUsScreen())
//            CusNavLink(doNavigate: $navigateToDocument, destination: DocumentUploadScreen())
//            CusNavLink(doNavigate: $navigateToSubCompany, destination: SubCompanyScreen())
//            CusNavLink(doNavigate: $navigateToTOS, destination: TermsOfServicesScreen())
//            CusNavLink(doNavigate: $navigateToPrivPoli, destination: PrivacyPolicyScreen())
//            CusNavLink(doNavigate: $navigateToProfile, destination: UserProfileScreen())
//            CusNavLink(doNavigate: $navigateToSecondLook, destination: SecondLookScreen())
//            CusNavLink(doNavigate: $navigateToCompanyUserProfile, destination: CompanyUserProfileScreen())
//            CusNavLink(doNavigate: $navigateToCompany, destination: EmployerCompanyScreen())
//            CusNavLink(doNavigate: $navigateTointerviewList, destination: InterviewlistScreen())
//            CusNavLink(doNavigate: $navigateToGoogleCalender, destination: GoogleCalenderScreen())
//            CusNavLink(doNavigate: $navigateTodeleteAccount, destination: DeleteAccountScreen())
//            CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen())
//            CusNavLink(doNavigate: $navigateToDecline, destination: DeclineCandidatesScreen( jobDetail: $jobDetail))
//            CusNavLink(doNavigate: $navigateToInterest, destination: InterestedCandidateScreen( jobDetail: $jobDetail))

        }
    }
    
    func handleUserLogout() {
        DispatchQueue.main.async {
            UserDefaultsManager.shared.clearAllValues()
            DispatchQueue.main.async {
                appRootManager.currentRoot = .authentication
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    func handleMenuClick(option: String) {
        withAnimation(.snappy) {
            switch option {
                case "Home":
                    self.presentationMode.wrappedValue.dismiss()
                case "Profile":
                    navigateToProfile = true
                case "My Interests":
                    navigateToInterest = true
                    return
               case "Decline Candidates":
                navigateToDecline = true
                    return
                case "Second Look":
                    navigateToSecondLook = true
                    return
                case "About Us":
                    navigateToAboutUs = true
                    return
                case "News":
                    navigateToNews = true
                    return
                case "Verification":
                navigateToDocument = true
                return
            case "User List":
                navigateToSubCompany = true
            case "My Profile":
                navigateToCompanyUserProfile = true
            return
                case "Contact Us":
                    navigateToContactUs = true
                    return
                case "Terms of Service":
                    navigateToTOS = true
                    return
                case "Privacy Policy":
                    navigateToPrivPoli = true
                    return
                case "Logout":
                    userLogOut = true
                    return
                case "My Company":
                    navigateToCompany = true
                    return
                case "Interview List":
                    navigateTointerviewList = true
                    return
                case "Calendar Management":
                    navigateToGoogleCalender = true
                    return
                case "Delete Account":
                    navigateTodeleteAccount = true
                    return
                case "My Subscription":
                    navigateToSubscription = true
                    return
                default:
                    return
            }
        }
    }
    
   
    func handleSuccess() {
        if viewModel.logOutResponse != nil {
            handleUserLogout()
        }
    }
}

#Preview {
    MenuScreen()
}
