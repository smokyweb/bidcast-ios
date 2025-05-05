//
//  DeleteAccountSheet.swift
//  imperium
//
//  Created by JAM-E-221 on 26/08/24.
//

import SwiftUI

struct DeleteAccountSheet: View {
        
            //MARK: - CallBack Functions
     var onDeleteClick: (() -> Void)?
     var onCancelClick: (() -> Void)?
        
            //MARK: - Delete Account Sheet View
        var body: some View {
            VStack(spacing: 14) {
                Image(.trash)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.all, 10)
                    .background(.pinkBtn)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                
                Text("Delete Account")
                    .font(.custom(nunitoBlack, fixedSize: 24))
                
                Text("Are you sure, You want to delete your account?")
                    .font(.custom(nunitoRegular, fixedSize: 16))
                
                PrimaryButton(title: "Delete", isOutLine: false, onButtonClick: {
                    self.onDeleteClick?()
                }, width: screenWidth/1.5, height: 45, btnColor: .pinkBtn)
                
                PrimaryButton(title: "Cancel", isOutLine: true, onButtonClick: {
                    self.onCancelClick?()
                }, width: screenWidth/1.5, height: 45, btnColor: .pinkBtn)
            }
        }
    }

#Preview {
    DeleteAccountSheet()
}
