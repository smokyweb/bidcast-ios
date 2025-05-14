//
//  ProfileDetailCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/05/25.
//

import SwiftUI

struct ProfileDetailCell: View {
    
    var profileImg : String = "defaultUser"
    var userName : String = "James Bond"
    var userDetail : String = "Selling Since 2019"
    
    var body: some View {
        VStack{
            HStack(alignment: .center, spacing: 10) {
                Image(.IMG_1340)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 64,height: 64)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    .padding(.leading, 0)
                    .padding([.top,.bottom],16)
                
                VStack(alignment: .leading, spacing: 0) {
                    TitleWithLine(title: userName, lineLength: 0, textColor: .black, fontValue: 12, divderHeight: 0)
                    TitleWithLine(title: userDetail, lineLength: 0, textColor: .lightGray, fontValue: 12, divderHeight: 0)
                }
            }
            .frame(height: 90)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 0)
        .ignoresSafeArea(.all)
        .background(.white)
    }
}

#Preview {
    ProfileDetailCell()
}
