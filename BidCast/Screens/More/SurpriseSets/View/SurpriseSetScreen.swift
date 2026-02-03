//
//  SurpriseSetScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/02/26.
//

import SwiftUI

struct SurpriseSetScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var navigateToCreate = false
    var body: some View {
        VStack{
            VStack{
                
                PrimaryHeader(
                    title: "Surprise Sets".localized,
                    isForLogo : false, leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            .frame(height:  50)
            .background(Color.white)
            
            ScrollView(showsIndicators:false){
                
            }
            .background(.backGround)
            .zIndex(1000)
            VStack{
                PrimaryButton(title:"Create New Surprise",onButtonClick: {
                    navigateToCreate = true
                })
            }
            .padding(.bottom,12)
            
            CusNavLink(doNavigate: $navigateToCreate, destination: CreateSurpriseScreen())
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .onTapGesture {
            hideKeyboard()
        }
    }
}

//#Preview {
//    SurpriseSetScreen()
//}
