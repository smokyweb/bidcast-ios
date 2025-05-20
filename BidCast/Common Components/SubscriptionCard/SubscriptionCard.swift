//
//  SubscriptionCard.swift
// BidSwipe
//
//  Created by JAM-E-221 on 25/06/24.
//

import Foundation
import SwiftUI

struct SubscriptionCard: View {
    var comeFromCalendar: Bool = false
    var issubscrition: Bool = true
    var menu: MenuModal = MenuModal(title: "", img: .menuHome)
    var onMenuClick: ((String) -> Void)?
    @State var navigateToSubscription: Bool = false
    
    @State var userDetail: UserDetailModal = UserDetailModal()
    @State var syncDetails: Bool = false
    
    
    @StateObject var viewModel = GoogleAuthViewModel()
    
    var body: some View {
        Button(action: {
            onMenuClick?(menu.title)
        }, label: {
            VStack {
                HStack{
                    if comeFromCalendar{
                        Image(.google)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .padding(.all, 8)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        if syncDetails == true{
                            Text("Google Calendar * LINKED")
                                .font(.custom(nunitoSemiBold, fixedSize: 18))
                                .foregroundStyle(.black)
                        }else{
                            Text("Google Calendar")
                                .font(.custom(nunitoSemiBold, fixedSize: 18))
                                .foregroundStyle(.black)
                        }
                    }else{
                        Image(.imgPlaceholder)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .padding(.all, 8)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        if userDetail.subscription?.is_expired == "no"{
                            Text(userDetail.subscription?.product_id ?? "")
                                .font(.custom(nunitoSemiBold, fixedSize: 14))
                                .foregroundStyle(.black)
                        }else{
                            Text("No Active subscription")
                                .font(.custom(nunitoSemiBold, fixedSize: 14))
                                .foregroundStyle(.black)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom,10)
                Spacer()
                
                if comeFromCalendar{
                    if syncDetails == true{
                        PrimaryButton(
                            title: "Link New Account", isOutLine: false, onButtonClick: {
                                viewModel.googleAuthorization()
                            })
                    }else{
                        PrimaryButton(
                            title: "Link", isOutLine: false, onButtonClick: {
                                viewModel.googleAuthorization()
                            })
                    }
                }else{
                    
                    if userDetail.subscription?.is_expired == "no"{
                        PrimaryButton(
                            title: "Change Subscription", isOutLine: false, onButtonClick: {
                                navigateToSubscription = true
                            })
                    }else{
                        PrimaryButton(
                            title: "Purchase Subscription", isOutLine: false, onButtonClick: {
                                navigateToSubscription = true
                            })
                    }
                }
                
                
                
//                CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen( isSubscription: self.userDetail.subscription ?? SubscriptionStatus()))
                
            }
            .padding(.all, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 3, x: 0, y: 0)
            )
        })
        
    }
    
}
class GoogleAuthViewModel: ObservableObject {
    
    @Published var showWebView: Bool = false
    @Published var authURL: URL?
    
    
    func googleAuthorization() {
        let authorizationEndpoint = "https://accounts.google.com/o/oauth2/auth"
        let clientID = "927220817126-mqsh4igeg484cu1aj6s2grseaasdpvms.apps.googleusercontent.com"
        let redirectURI = "https://backend.imperiumjob.com/google-calendar/callback-process"
        
        let scope = "https://www.googleapis.com/auth/calendar"
        let responseType = "code"
        let state = "random_state_string"
        let type = "offline"
        let prompt = "consent"
        
        let authURLString = "\(authorizationEndpoint)?client_id=\(clientID)&redirect_uri=\(redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&response_type=\(responseType)&scope=\(scope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&state=\(state.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)&access_type=\(type)&prompt=\(prompt)&service=lso&o2v=2&theme=mn&ddm=0&flowName=GeneralOAuthFlow&additional_key=item1"
        
        if let authURL = URL(string: authURLString) {
            let urlString = authURL.absoluteString
            UIApplication.shared.open(URL(string: urlString)!)
            
        }
    }
}
