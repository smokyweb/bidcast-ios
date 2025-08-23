//
//  BlockedUserSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 22/07/25.
//

import SwiftUI

struct UnblockedUserSheet: View {
    
    //MARK: - CallBack Functions
    var onLogoutClick: (() -> Void)?
    var onCancelClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 14) {
            Image(.alert)
                .renderingMode(.template)
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.all, 10)
                .background(.defaultTheme)
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text("Unblock")
                .font(.custom(poppinsBold, fixedSize: 24))
            
            Text("Do you want to unblock this user?")
                .font(.custom(poppinsRegular, fixedSize: 16))
            
            PrimaryButton(title: "Unblock", isOutLine: false, onButtonClick: {
                self.onLogoutClick?()
            }, width: screenWidth/1.5, height: 45, btnTextColor: .white, btnColor: .defaultTheme)
            
            PrimaryButton(title: "Cancel", isOutLine: true, onButtonClick: {
                self.onCancelClick?()
            }, width: screenWidth/1.5, height: 45, btnTextColor: .white, btnColor: .defaultTheme)
        }
    }
}

#Preview {
    UnblockedUserSheet()
}
