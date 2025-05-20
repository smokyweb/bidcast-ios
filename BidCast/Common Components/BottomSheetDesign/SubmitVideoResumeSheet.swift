//
//  SubmitVideoResumeSheet.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 31/01/24.
//

import SwiftUI

struct SubmitVideoResumeSheet: View {
    
    @Binding var isSuccess: Bool
    
        //MARK: - CallBack Functions
    var onContinueClick: (() -> Void)?
    var onCancelClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .renderingMode(.template)
                .resizable()
                .frame(width: 50, height: 50)
                .background(.white)
                .foregroundStyle(isSuccess ? .green : .pinkBtn)
                .clipShape(Circle())
            
            Text(isSuccess ? "Resume Submitted" : "Failed to Submit Resume")
                .font(.custom(nunitoBold, fixedSize: 24))
            
            Text(isSuccess ? "Your Resume has been submitted." : "Your Resume has been submitted. Please retry")
                .font(.custom(nunitoRegular, fixedSize: 16))
            
            if isSuccess {
                PrimaryButton(title: "Continue", isOutLine: false, onButtonClick: {
                    self.onContinueClick?()
                }, width: screenWidth/1.5, height: 45, btnColor: .green)
            } else {
                PrimaryButton(title: "Try Again", isOutLine: true, onButtonClick: {
                    self.onCancelClick?()
                }, width: screenWidth/1.5, height: 45, btnColor: .pinkBtn)
            }
        }
    }
}

#Preview {
    SubmitVideoResumeSheet(isSuccess: .constant(false))
}
