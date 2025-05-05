//
//  NoInternetScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 09/02/24.
//

import SwiftUI

struct NoInternetScreen: View {
    var tryAgain: (() -> Void)?
    var Homescreen: Bool?
    var btnString : String?
    var contentString : String?
    @State var navigateToDoc: Bool = false

    
    var body: some View {
        VStack(alignment: .center) {
            if Homescreen ?? false{
                Image(.review)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: screenHeight / 6)
            }else{
                Image(.noInternetIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: screenHeight / 6)
            }
            Text(Homescreen ?? false ? "Oops" : "Lost Connection")
                .font(.custom(nunitoBold, fixedSize: 20))
                .padding(.top, 20)
            if Homescreen ?? false{
                Text(contentString ?? "")
                .font(.custom(nunitoMedium, fixedSize: 14))
                .multilineTextAlignment(.center)
                .padding(.top, 15)
            }else{
                Text("Whoops, no internet connection found.\nPlease check your connection.")
                    .font(.custom(nunitoMedium, fixedSize: 14))
                    .multilineTextAlignment(.center)
                    .padding(.top, 15)
            }
            if Homescreen ?? false{
                PrimaryButton(
                    title: btnString ?? "",
                    onButtonClick: {
                        navigateToDoc = true
                    }).padding(.top, 20)
            }else{
                PrimaryButton(
                    title: "Try Again",
                    onButtonClick: {
                        tryAgain?()
                    }).padding(.top, 20)
            }
        }.padding(.all)
        
        CusNavLink(doNavigate: $navigateToDoc, destination: DocumentUploadScreen())

    }
}

//#Preview {
//    NoInternetScreen()
//}
