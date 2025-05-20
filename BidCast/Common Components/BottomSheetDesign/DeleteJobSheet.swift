//
//  DeleteJobSheet.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 01/03/24.
//

import SwiftUI

struct DeleteJobSheet: View {

        //MARK: - CallBack Functions
    var onDeleteClick: (() -> Void)?
    var onCancelClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "xmark.bin.fill")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 35, height: 35)
                .padding(.all, 10)
                .background(.pinkBtn)
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text("Delete Job")
                .font(.custom(nunitoBlack, fixedSize: 24))
            
            Text("Are you sure you want to delete this job?")
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
    DeleteJobSheet()
}
