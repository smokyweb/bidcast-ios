//
//  InterviewScheduledSheet.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import SwiftUI

struct InterviewScheduledSheet: View {
    
    @Binding var isSuccess: Bool
    @Binding var date: Date
    
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
            
            Text(isSuccess ? "Interview Scheduled" : "Failed to Schedule Interview")
                .font(.custom(nunitoBold, fixedSize: 20))
            
            Text(isSuccess ? date.forInterview() : "Your Interview has not been scheduled. Please retry again")
                .font(.custom(nunitoRegular, fixedSize: 14))
                .foregroundStyle(.black.opacity(0.75))
            
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
    InterviewScheduledSheet(isSuccess: .constant(false), date: .constant(Date()))
}
