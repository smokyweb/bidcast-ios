//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct AccountScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager
    @State var userLogOut: Bool = false
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .error(title: "", message: "", leftBtnText: "", rightBtnText: "")
    @State var segment : AccountSegment = .sellerHub
    @State var selectedSegmentSourceType = 0
    @State var isTappedSwitch : Bool = false
    @State var navigateToAboutUs : Bool = false
    @State var navigateToFAQ : Bool = false
    @State var navigateToContactus : Bool = false
    @State var navigateToSales : Bool = false
    @State var navigateToPrivacy : Bool = false
    @State var navigateToTerms : Bool = false
    @State var navigateToInventry : Bool = false
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
    @State var navigateToPayment : Bool = false
    @State var navigateToTrustedBuyer : Bool = false
    @State var navigateToPremierShop : Bool = false
    @State var navigateToAffilateProgram : Bool = false
    @State var navigateToAnalytics : Bool = false
    
    var viewModal = MenuOptionsViewModal()
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack{
            VStack{
                PrimaryHeader(
                    title: "Account".localized,
                    isForLogo : true, leadingImgArr: [.appName],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .padding(.horizontal,12)
                .background(.white)
                
            }.padding(.horizontal,12)
                .background(.white)
            
            ScrollView(showsIndicators: false){
                VStack(alignment: .leading,spacing: 4){
                    ListCell(image: "defaultUser", title: "John Smith",subLabel : "Seller since 2003",isVectorImgHidden: true)
                        .padding(.all,1)
//                        .padding([.leading,.trailing],18)
                        .frame(height: 80)
                    
                        CustomSegmentedControl(preselectedIndex: $segment ,
                                               options: AccountSegment.allCases)
                       
                    
                   
                    
                    if segment == .sellerHub{
                        //Seller hub
                        TwoVerticalLabelCell(dataModel: Credit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                        
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0 ..< TabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(topLabel: TabSection.allCases[index].img , bottomLabel:TabSection.allCases[index].description.localized
                                ){
                                    if index == 0 {
                                        withAnimation {
                                            navigateToInventry = true
                                        }
                                    }else if index == 1 {
                                        withAnimation {
                                            navigateToShows = true
                                        }
                                    }else if index == 2 {
                                        withAnimation {
                                            navigateToMyOrder = true
                                        }
                                    }else if index == 3 {
                                        withAnimation {
                                            navigateToWallet = true
                                        }
                                    }else if index == 4 {
                                        withAnimation {
                                            navigateToOffers = true
                                        }
                                    }else if index == 5 {
                                        withAnimation {
                                            navigateTips = true
                                        }
                                    }else if index == 6{
                                        withAnimation {
                                            navigateToShipping = true
                                        }
                                    }else if index == 7{
                                        withAnimation {
                                            navigateToAffilateProgram = true
                                        }
                                    }else if index == 8{
                                        withAnimation {
                                            navigateToSellerTraining = true
                                        }
                                    }else if index == 9{
                                        withAnimation {
                                            navigateToPremierShop = true
                                        }
                                    }else if index == 10{
                                        withAnimation {
                                            navigateToSellerStatus = true
                                        }
                                    }else if index == 11{
                                        withAnimation {
                                            navigateToAnalytics = true
                                        }
                                    }
                                }
                            }
                        }
//                        .padding([.leading,.trailing],8)
                        MenuCell(title: "Vacation Mode", textColor: .black, fontValue: 18.0, menuImg:"vacation", vectorImg: .vacation,isSelectable: true,isTappedSwitch: $isTappedSwitch,
                                 onToggle: { newValue in
                            print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                        })
//                        .padding([.leading,.trailing],8)
                        
                    }else{
                        //My Account section
                        TwoVerticalLabelCell(dataModel: AccountCredit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description})
                        
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0 ..< AccountTabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(topLabel: AccountTabSection.allCases[index].img , bottomLabel:AccountTabSection.allCases[index].description ){
                                    if index == 0{
                                        withAnimation {
                                            navigateToPayment = true
                                        }
                                    }else if index == 1 {
                                        withAnimation {
                                            navigateToAddress = true
                                        }
                                    }else if index == 2  {
                                        withAnimation {
                                            navigateToTrustedBuyer = true
                                        }
                                    }else if index == 4 {
                                        withAnimation {
                                            navigateToPreference = true
                                        }
                                    }
                                }
                                
                            }
                        }
//                        .padding([.leading,.trailing],8)
                        
                        ForEach(0 ..< AccountMenuSection.allCases.count,id :\.self) { index in
                            
                            MenuCell(title: AccountMenuSection.allCases[index].description, textColor: .black, fontValue: 18.0, menuImg:"vacation", vectorImg: .icArrowUp ,isSelectable: false,isTappedSwitch: $isTappedSwitch,
                                     onToggle: { newValue in
                                
                                print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                                
                            },onTapMenuCell: {
                                if index == 0 {
                                    withAnimation {
                                        navigateToAboutUs = true
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
                                        navigateToTerms = true
                                    }
                                }else
                                if index == 4{
                                    withAnimation {
                                        navigateToPrivacy = true
                                    }
                                }
                                else if index == 5 {
                                    withAnimation {
                                        navigateToFAQ = true
                                    }
                                }
                                else if index == 6 {
                                    withAnimation {
                                        userLogOut = true
                                    }
                                }
                                print(AccountMenuSection.allCases[index].description)
                            })
                            
                            .frame(height:70)
//                            .padding([.leading,.trailing],8)
                        }
                    }
                   
                }
            }
            .padding(.horizontal,8)
          
            .background(.bg.opacity(0.5))
            .padding(.bottom,-200)
            
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
            CusNavLink(doNavigate: $navigateToPreference, destination: SettingsView())
            CusNavLink(doNavigate: $navigateToPayment, destination: PaymentAndShipping_Screen())
            CusNavLink(doNavigate: $navigateToTrustedBuyer, destination: VerifyIdentityScreen())
            
            
            //MARK: Seller hub navigation
            CusNavLink(doNavigate: $navigateToShows, destination: ShowsScreen())
            CusNavLink(doNavigate: $navigateToInventry, destination: InventoryScreen())
            CusNavLink(doNavigate: $navigateToOffers, destination: OffersScreen())
            CusNavLink(doNavigate: $navigateToSellerTraining, destination: PromoteToolsView())
            CusNavLink(doNavigate: $navigateTips, destination: TipsScreen())
            CusNavLink(doNavigate: $navigateToWallet, destination: WalletScreen(data:  WalletData(
                summary: WalletSummary(
                    availableBalance: 5280.50,
                    availableForPayout: 3450.00,
                    processing: 1830.50,
                    earlyPayoutMessage: "You're eligible for early payout"
                ),
                payoutHistory: [
                    Payout(amount: 1250, date: .init(timeIntervalSince1970: 1741977600), status: "Completed"),
                    Payout(amount: 980.25, date: .init(timeIntervalSince1970: 1740796800), status: "Completed"),
                    Payout(amount: 2150.75, date: .init(timeIntervalSince1970: 1739568000), status: "Completed")
                ],
                transactions: [
                    Transaction(title: "Purchase from John", date: .init(timeIntervalSince1970: 1742841600), amount: 1250.00, isOutgoing: true)
                ]
            )))
            CusNavLink(doNavigate: $navigateToSellerStatus, destination:   SellerStatusScreen(sections: [
                SellerStatusSection(
                    title: "Marketplace Vendor Status",
                    subtitle: "Vendor since Jan 2025\nSeller Rating: 4.8/5",
                    icon: Image(systemName: "cart.fill"),
                    statusText: "Active",
                    statusColor: .green
                ),
                SellerStatusSection(
                    title: "Live Sell Vendor Status",
                    subtitle: "Application in Review\nSubmitted: Jan 15, 2025",
                    icon: Image(systemName: "video.fill"),
                    statusText: "Pending",
                    statusColor: .orange
                )
            ]))
            CusNavLink(doNavigate: $navigateToMyOrder, destination: MyOrdersScreen())
            CusNavLink(doNavigate: $navigateToAffilateProgram, destination: AffiliateProgramScreen(
                referralCode: "SELLER2025",
                stats: ReferralStats(totalReferrals: 0, earnings: 0.0),
                onShare: {
                    print("Share link tapped")
                }
            ))
            CusNavLink(doNavigate: $navigateToAnalytics, destination: AnalyticsScreen())
            
        }
        .edgesIgnoringSafeArea([.top,.bottom])
        .background(.bg.opacity(0.5))
        .bottomSheet(isPresented: $userLogOut, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { userLogOut = true }, content: {
            LogOutSheet(onLogoutClick: {
                withAnimation(.snappy) { userLogOut = false }
                viewModal.logOut()
                observe()
            }, onCancelClick: {
                withAnimation(.snappy) { userLogOut = false }
            })
        })
    }
    func observe() {
        viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .error(title: "Error", message: error?.localizedDescription ?? "", leftBtnText: "Ok", rightBtnText: "")
                    showAlert = true
                    print("Error >> \(error as Any)")
            }
        }
    }
    
    func handleSuccess() {
        if viewModal.logOutResponse != nil {
            handleUserLogout()
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
}

#Preview {
    AccountScreen()
}


enum AccountSegment : String, CaseIterable, CustomStringConvertible{
    case sellerHub = "Seller Hub"
    case Account = "My Account"
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
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
    case logout = "Logout"
    
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
}
