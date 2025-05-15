//
//  AccountScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import SwiftUI

struct AccountScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var segment : AccountSegment = .sellerHub
    @State var selectedSegmentSourceType = 0
    @State var isTappedSwitch : Bool = false
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
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
            .background(.white)
            
            ScrollView{
                VStack(alignment: .leading,spacing: 4){
                    ListCell(image: .defaultUser, title: "John Smith",subLabel : "Seller since 2003",isVectorImgHidden: true)
                        .padding(.all,1)
                        .padding([.leading,.trailing],-18)
                        .frame(height: 80)
                    
                    CustomSegmentedControl(preselectedIndex: $segment ,
                                           options: AccountSegment.allCases)
                    .background(.white)
                    if segment == .sellerHub{
                        //Seller hub
                        TwoVerticalLabelCell(dataModel: Credit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description.localized})
                        
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0 ..< TabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(topLabel: TabSection.allCases[index].img , bottomLabel:TabSection.allCases[index].description.localized )
                                
                            }
                        }
                        .padding([.leading,.trailing],8)
                        MenuCell(title: "Vacation Mode", textColor: .black, fontValue: 18.0, menuImg:"vacation", vectorImg: .vacation,isSelectable: true,isTappedSwitch: $isTappedSwitch,
                                 onToggle: { newValue in
                            print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                        })
                        .padding([.leading,.trailing],8)
                        
                    }else{
                        //My Account section
                        TwoVerticalLabelCell(dataModel: AccountCredit.allCases,topLabel: {$0.labelOlt },bottomLabel: { $0.description})
                        
                        LazyVGrid(columns: columns, spacing: 2) {
                            ForEach(0 ..< AccountTabSection.allCases.count, id: \.self) { index in
                                VerticalLabelImageCell(topLabel: TabSection.allCases[index].img , bottomLabel:TabSection.allCases[index].description )
                                
                            }
                        }
                        .padding([.leading,.trailing],8)
                        
                        ForEach(0 ..< AccountMenuSection.allCases.count,id :\.self) { index in
                            
                            MenuCell(title: AccountMenuSection.allCases[index].description, textColor: .black, fontValue: 18.0, menuImg:"vacation", vectorImg: .icArrowUp ,isSelectable: false,isTappedSwitch: $isTappedSwitch,
                                     onToggle: { newValue in
                                
                                print("Vacation Mode state is now \(newValue ? "ON" : "OFF")")
                                
                            },onTapMenuCell: {
                                print(AccountMenuSection.allCases[index].description)
                            })
                            
                            .frame(height:75)
                            .padding([.leading,.trailing],8)
                        }
                    }
                }
                
            }
            .padding(.bottom,24)
            .padding(.top,-24)
            .background(.bg.opacity(0.5))
            
        }
        .edgesIgnoringSafeArea(.all)
        .background(.bg.opacity(0.5))
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
    
    
    var description: String {
            return NSLocalizedString(rawValue, comment: "")
        }
}
