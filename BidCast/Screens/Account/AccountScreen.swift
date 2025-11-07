//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI
import SVProgressHUD

struct AccountScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appRootManager: AppRootManager
    @State var userLogOut: Bool = false
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .error(title: "", message: "", leftBtnText: "", rightBtnText: "")
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var segment : AccountSegment = .sellerHub
    @State var selectedSegmentSourceType = 0
    @State var isTappedSwitch : Bool = false
    @State var navigateToAboutUs : Bool = false
    @State var navigateToFAQ : Bool = false
    @State var navigateToContactus : Bool = false
    @State var navigateToSales : Bool = false
    @State var navigateToBlockedList : Bool = false
    @State var navigateToPrivacy : Bool = false
    @State var navigateToTerms : Bool = false
    @State var navigateToInventry : Bool = false
    @State var navigateToPromoteTool : Bool = false
    @State var navigateToAddress : Bool = false
    @State var navigateToShows : Bool = false
    @State var navigateToWallet : Bool = false
    @State var navigateTips : Bool = false
    @State var navigateToOffers : Bool = false
    @State var navigateToShipping : Bool = false
    @State var navigateToSellerStatus : Bool = false
    @State var navigateToMyOrder : Bool = false
    @State var navigateToSellerTraining : Bool = false
    @State var navigateToPreference : Bool = false
    @State var navigateToCategory : Bool = false
    @State var navigateToPayment : Bool = false
    @State var navigateToTrustedBuyer : Bool = false
    @State var navigateToPremierShop : Bool = false
    @State var navigateToAffilateProgram : Bool = false
    @State var navigateToAnalytics : Bool = false
    @State var isNavFrom : Bool = false
    @State var navigateToSellerVerification = false
    @State var navigateToProfile : Bool = false
    @State var comeFromSeller = false
    @State var newTab = Int()
    @State var viewModal = MenuOptionsViewModel()
    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 2)
    var body: some View {
        VStack{
            VStack{
                PrimaryHeader(
                    title: AppString.Account.localized,
                    isForLogo: comeFromSeller ? false : true,
                    leadingImgArr: comeFromSeller ? [.icBack] : [.appName], // logo on left
                    trailingImgArr: [],
                    onClickLeading: { index in
                        self.presentationMode.wrappedValue.dismiss()
                        // maybe open menu or do nothing
                    },
                    onClickTrailing: nil,
                    count: .constant(0)
                )
            }
            
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading,spacing: 4){
                    ListCell(image: UserDefaults.profileURL.isEmpty ? "user_dummy" : UserDefaults.profileURL,
                             title: UserDefaults.fullName.capitalizingFirstLetter() ,
                             vectorImg : .circleEditPencil,angle:0.0,
                             subLabel : UserDefaults.userName.capitalizingFirstLetter(),
                             titleFontName: poppinsSemiBold,
                             titleFontSize: 16.0,
                             subLabelFontName: poppinsRegular,
                             subLabelFontSize: 12.0,
                             isVectorImgHidden: false,
                             onTapMenuCell: {
                        
                        self.navigateToProfile = true
                        
                    })
                    .padding(.all,1)
                    .frame(height: 80)
                    
                    CustomSegmentedControl(preselectedIndex: $segment ,
                                           options: AccountSegment.allCases)
                    
                    
                   
                    
                    if segment == .sellerHub{
                        //Seller hub
                        TwoVerticalLabelCell(dataModel: Credit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                        
                        LazyVGrid(columns: columns, spacing: 6) { // ✅ uniform vertical spacing
                            ForEach(0 ..< TabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(
                                    topLabel: TabSection.allCases[index].img,
                                    bottomLabel: TabSection.allCases[index].description.localized
                                ) {
                                    withAnimation {
                                        switch index {
                                        case 0: navigateToInventry = true
                                        case 1: navigateToShows = true
                                        case 2: navigateToMyOrder = true
                                        case 3: navigateToWallet = true
                                        case 4: navigateToOffers = true
                                        case 5: navigateTips = true
                                        case 6: navigateToShipping = true
                                        case 7: navigateToAffilateProgram = true
                                        case 8: navigateToSellerTraining = true
                                        case 9: navigateToPremierShop = true
                                        case 10: navigateToSellerStatus = true
                                        case 11: navigateToAnalytics = true
                                        case 12: navigateToPromoteTool = true
                                        case 13: navigateToSellerVerification = true
                                        default: break
                                        }
                                    }
                                }
                                .aspectRatio(1, contentMode: .fill)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)

                        MenuCell(title: "Vacation Mode", textColor: .black, fontValue: 14.0, menuImg:"vacation", vectorImg: .vacation,isSelectable: true,isTappedSwitch: $isTappedSwitch,
                                 onToggle: { newValue in
                            print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                        })
                        
                    }else{
                        TwoVerticalLabelCell(dataModel: AccountCredit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description},columnsPerRow: 2)
                        
                        LazyVGrid(columns: columns, spacing: 6) {
                            ForEach(0 ..< AccountTabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(
                                    topLabel: AccountTabSection.allCases[index].img,
                                    bottomLabel: AccountTabSection.allCases[index].description
                                ) {
                                    withAnimation {
                                        switch index {
                                        case 0: navigateToPayment = true
                                        case 1: navigateToAddress = true
                                        case 2: navigateToTrustedBuyer = true
                                        case 4: navigateToPreference = true
                                         case 5: navigateToCategory = true
                                        default: break
                                        }
                                    }
                                }
                                .aspectRatio(1, contentMode: .fill)
                            }
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 6)
                        
                        ForEach(0 ..< AccountMenuSection.allCases.count,id :\.self) { index in
                            
                            MenuCell(title: AccountMenuSection.allCases[index].description, textColor: .black, fontValue: 14.0, menuImg:"vacation", vectorImg: .icArrowUp ,isSelectable: false,isTappedSwitch: $isTappedSwitch,
                                     onToggle: { newValue in
                                
                                print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                                
                            },onTapMenuCell: {
                                if index == 0 {
                                    withAnimation {
//                                        navigateToAboutUs = true
                                        if let url = URL(string: "https://backend.bidcast.betaplanets.com/about-us") {
                                               UIApplication.shared.open(url)
                                           }
                                    }
                                }else
                                if index == 1{
                                    withAnimation {
                                        navigateToContactus = true
                                    }
                                }else
                                if index == 2{
                                    withAnimation {
                                        navigateToSales = true
                                    }
                                }else
                                if index == 3{
                                    withAnimation {
//                                        navigateToTerms = true
                                        if let url = URL(string: "https://backend.bidcast.betaplanets.com/terms-condition") {
                                               UIApplication.shared.open(url)
                                           }
                                    }
                                }else
                                if index == 4{
                                    withAnimation {
//                                        navigateToPrivacy = true
                                        if let url = URL(string: "https://backend.bidcast.betaplanets.com/privacy-policy") {
                                               UIApplication.shared.open(url)
                                           }
                                    }
                                }
                                else if index == 5 {
                                    withAnimation {
//                                        navigateToFAQ = true
                                        if let url = URL(string: "https://backend.bidcast.betaplanets.com/faq") {
                                               UIApplication.shared.open(url)
                                           }
                                    }
                                }
                                else if index == 6 {
                                    navigateToBlockedList = true
                                }
                                else if index == 7 {
                                    withAnimation {
                                        userLogOut = true
                                    }
                                }
                                print(AccountMenuSection.allCases[index].description)
                            })
                            
                            .frame(height:70)
                        }
                    }
                   
                }
            }
            .padding(.horizontal,8)
            .background(.clear)
            .edgesIgnoringSafeArea(.bottom)
//            .frame(maxHeight: .infinity)
            .padding(.bottom,isNavFrom ? -300 : UIDevice.current.hasNotch ? -260 : -110)
            
            CusNavLink(doNavigate: $navigateToProfile, destination: CompleteProfileScreen())
            //MARK: My Account navigation
            CusNavLink(doNavigate: $navigateToAboutUs, destination: AboutUsScreen())
            CusNavLink(doNavigate: $navigateToPremierShop, destination: PremierShopScreen())
            CusNavLink(doNavigate: $navigateToSales, destination: SalesTaxScreen())
            CusNavLink(doNavigate: $navigateToFAQ, destination: FAQScreen())
            CusNavLink(doNavigate: $navigateToTerms, destination: TermsOfServicesScreen())
            CusNavLink(doNavigate: $navigateToPrivacy, destination: PrivacyPolicyScreen())
            CusNavLink(doNavigate: $navigateToContactus, destination: ContactUs())
            CusNavLink(doNavigate: $navigateToAddress, destination: AddressesScreen())
            CusNavLink(doNavigate: $navigateToShipping, destination: ShippingsScreen())
            CusNavLink(doNavigate: $navigateToPreference, destination: PreferncesScreen())
            CusNavLink(doNavigate: $navigateToCategory, destination: MultiSelectionCategoryScreen(isNavFrom : "Account"))
            CusNavLink(doNavigate: $navigateToPayment, destination: PaymentAndShipping_Screen())
            CusNavLink(doNavigate: $navigateToTrustedBuyer, destination: TrustedBuyerScreen(comeFromHome: .constant(false)))
            CusNavLink(doNavigate: $navigateToSellerVerification, destination: SellerVerificationScreen())
            
            
            //MARK: Seller hub navigation
            CusNavLink(doNavigate: $navigateToShows, destination: ShowsScreen())
            CusNavLink(doNavigate: $navigateToInventry, destination: InventoryScreen(productData: InventoryDataModel(), selectedProductIDs: .constant([]), selectedProductData: .constant([])))
            CusNavLink(doNavigate: $navigateToOffers, destination: OffersScreen())
            CusNavLink(doNavigate: $navigateToSellerTraining, destination: SellingTips(isNavFrom : "Account", backToTabBar: .constant(true)))
            CusNavLink(doNavigate: $navigateToPromoteTool, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigateTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigateToWallet, destination: WalletScreen())
            CusNavLink(doNavigate: $navigateToSellerStatus, destination:   SellerStatusScreen())
            CusNavLink(doNavigate: $navigateToMyOrder, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToBlockedList, destination: BlockedUserScreen())
            CusNavLink(doNavigate: $navigateToAffilateProgram, destination: AffiliateProgramScreen(
                referralCode: "SELLER2025",
                stats: ReferralStats(totalReferrals: 0, earnings: 0.0),
                onShare: {
                    print("Share link tapped")
                }
            ))
            CusNavLink(doNavigate: $navigateToAnalytics, destination: AnalyticsScreen())
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
//        .toolbar(isNavFrom ? .hidden : .visible, for: .tabBar)
        .bottomSheet(isPresented: $userLogOut, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {  }, content: {
            LogOutSheet(onLogoutClick: {
                withAnimation(.snappy) { userLogOut = false }
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    await viewModal.logOut()
                    SVProgressHUD.show()
                    handleSuccess()
                }
               
            }, onCancelClick: {
                withAnimation(.snappy) { userLogOut = false }
            })
        })
    }
    
    
    func handleSuccess() {
        SVProgressHUD.dismiss()
        if viewModal.logOutResponse != nil {
            handleUserLogout()
        }
    }
    func handleUserLogout() {
        DispatchQueue.main.async {
            UserDefaults.accessToken.removeAll()
            UserDefaults.sellerVerafied.removeAll()
            UserDefaults.buyerVerafied.removeAll()
            let rememberMe = UserDefaults.rememberMe
            if !rememberMe {
                let _ = KeychainManager.shared.delete(email: UserDefaults.userEmail)
                UserDefaults.userEmail = ""
                UserDefaults.rememberMe = false
            }
            UserDefaults.userId = -1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    appRootManager.currentRoot = .authentication
                }
            }
        }
    }
}

//#Preview {
//    AccountScreen()
//}


enum AccountSegment : String, CaseIterable, CustomStringConvertible{
    case sellerHub = "Seller Hub"
    case Account = "My Account"
    
    var description: String {
        return NSLocalizedString(rawValue, comment: "").localized
    }
}



enum Credit : String, CaseIterable, CustomStringConvertible{
    
    case items = "Items"
    case Revenue = "Revenue"
    case sorting = "Sorting"
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var labelOlt : String{
        switch self {
            
        case .items:
            return "284"
        case .Revenue:
            return "$5.2K"
        case .sorting:
            return "4.8"
        }
    }
}

enum TabSection : String, CaseIterable, CustomStringConvertible{
    
    case Inventory = "Inventory"
    case Shows = "Shows"
    case orders = "My Orders"
    case wallet = "Wallet"
    case offer = "Offers"
    case tips = "Tips"
    case shipping = "Shipping"
    case affilaite = "Affiliate Program"
    case training = "Seller Training"
    case premier = "Premier Shop"
    case sellerStatus = "Seller Status"
    case sellerAna = "Seller Analytics"
    case promoteTool = "Promote Tools"
    case sellerVerificatiob = "Seller Verification"
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var img : ImageResource{
        switch self {
            
            
        case .Inventory:
            return .inventory
        case .Shows:
            return .mic
        case .orders:
            return .orders
        case .wallet:
            return .wallet
        case .offer:
            return .tag
        case .tips:
            return .tag
        case .shipping:
            return .shipping
        case .affilaite:
            return .people
        case .training:
            return .gradCap
        case .premier:
            return .shop
        case .sellerStatus:
            return .analysis
        case .sellerAna:
            return .analysis
        case .promoteTool:
            return .promoteTool
        case .sellerVerificatiob:
            return .seller
        }
    }
}

enum AccountCredit : String, CaseIterable, CustomStringConvertible{
    
    case credit = "Credits"
    case coupon = "Coupons"
    
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var labelOlt : String{
        switch self {
            
        case .credit:
            return "284"
        case .coupon:
            return "$5.2K"
        }
    }
}

enum AccountTabSection : String, CaseIterable, CustomStringConvertible{
    
    case paymentShipping = "Payment & Shipping"
    case address = "Addresses"
    case buyer = "Trusted Buyer"
    case notifications = "Notifications"
    case preference = "Preference"
    case favCategory = "Favourite"
    
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
    
    var img : ImageResource{
        switch self {
            
        case .paymentShipping:
            return .inventory
        case .address:
            return .mic
        case .buyer:
            return .orders
        case .notifications:
            return .wallet
        case .preference:
            return .tag
        case .favCategory:
            return .categories
            
        }
    }
}
enum AccountMenuSection : String, CaseIterable, CustomStringConvertible{
    
    case about = "About Us"
    case comntact = "Contact Us"
    case salesTax = "Sales tax Exemption"
    case TermsandCond = "Terms & Conditions"
    case privacy = "Privacy & Policy"
    case faq = "F.A.Q"
    case blockList = "Blocked Users"
    case logout = "Logout"
    
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
}

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}
 
