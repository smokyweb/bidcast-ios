//
//  LinkedInBottomSheet.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 28/03/24.
//

import SwiftUI

struct LinkedInBottomSheet: View {
    
    @State var linkedIn: String = ""
    
        //MARK: - CallBack Functions
    var onBtnClick: ((String) -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Spacer()
                Image(.linkedIn)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 35, height: 35)
                    .padding(.all, 10)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
                Spacer()
            }.padding(.vertical)
            
            Text("Connect with LinkedIn")
                .font(.custom(nunitoBlack, fixedSize: 22))
            
            Text("Kindly enter public URL of your LinkedIn profile to\nconnect with your Imperium Account")
                .font(.custom(nunitoRegular, fixedSize: 16))
            
            AuthTextField(
                floatingLabel: "",
                placeholder: "LinkedIn URL",
                icon: .linkedIn,
                text: $linkedIn)
            .padding(.bottom, 30)
            
            PrimaryButton(title: "Continue", isOutLine: false, onButtonClick: {
                self.onBtnClick?(linkedIn)
            }, height: 45, btnColor: .text)
            
            Spacer()
        }.padding(.horizontal)
    }
}

#Preview {
    LinkedInBottomSheet()
}
