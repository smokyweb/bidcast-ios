//
//  LogOutSheet.swift
// BidSwipe
//
//  Created by JAM-E-329 on 23/01/24.
//

import SwiftUI

struct LogOutSheet: View {
    
    //MARK: - CallBack Functions
    var onLogoutClick: (() -> Void)?
    var onCancelClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 14) {
            Image(.menuLogout)
                .renderingMode(.template)
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.all, 10)
                .background(.defaultTheme)
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text("Logout")
                .font(.custom(poppinsBold, fixedSize: 24))
            
            Text("Are you sure you want to logout?")
                .font(.custom(poppinsRegular, fixedSize: 16))
            
            PrimaryButton(title: "Logout", isOutLine: false, onButtonClick: {
                self.onLogoutClick?()
            }, width: screenWidth/1.5, height: 45, btnTextColor: .white, btnColor: .defaultTheme)
            
            PrimaryButton(title: "Cancel", isOutLine: true, onButtonClick: {
                self.onCancelClick?()
            }, width: screenWidth/1.5, height: 45, btnTextColor: .white, btnColor: .defaultTheme)
        }
    }
}

#Preview {
    LogOutSheet()
}
