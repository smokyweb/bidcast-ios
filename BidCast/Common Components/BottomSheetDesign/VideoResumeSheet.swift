//
//  VideoResumeSheet.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 24/01/24.
//

import SwiftUI

struct VideoResumeSheet: View {
    
    var showTutorialButton: Bool = true
    
    var message: String = "Would you like to set up your Virtual Resume now?"
    
        //MARK: - CallBack Functions
    var onStartResumeClick: (() -> Void)?
    var onWatchTutorialClick: (() -> Void)?
    var onSkipClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 16) {
            Image(.video)
                .renderingMode(.template)
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.all, 10)
                .background(.text)
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text("Virtual Resume")
                .font(.custom(nunitoBlack, fixedSize: 24))
            
            Text(message)
                .font(.custom(nunitoRegular, fixedSize: 16))
                .multilineTextAlignment(.center)
                .frame(width: screenWidth/1.5)
            
            PrimaryButton(title: "Start Virtual Resume", isOutLine: false, onButtonClick: {
                self.onStartResumeClick?()
            }, width: screenWidth/1.5, height: 43, btnColor: .text)
            
            if showTutorialButton {
                PrimaryButton(title: "Watch Virtual Resume Tutorial", isOutLine: false, onButtonClick: {
                    self.onWatchTutorialClick?()
                }, width: screenWidth/1.5, height: 43, btnColor: .text)
            }
            
            PrimaryButton(title: "Skip for Now", isOutLine: true, onButtonClick: {
                self.onSkipClick?()
            }, width: screenWidth/1.5, height: 43, btnColor: .text)
        }
    }
}

#Preview {
    VideoResumeSheet()
}
