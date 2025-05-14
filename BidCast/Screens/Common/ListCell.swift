//
//  ListCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 14/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

struct ListCell: View {
    
    var image : ImageResource
    var title = "Gaming"
    var vectorImg : ImageResource
    var subLabel = "Live"
    var body: some View {
        HStack(alignment: .center,spacing: 10){
            HStack{
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40,height: 40)
                    .padding(.leading ,10)
                VStack(alignment: .leading,spacing: 6) {
                    Text(title)
                        .font(.custom(nunitoBlack, fixedSize: 15.0))
                        .bold()
                        .foregroundStyle(.black)
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                    Text(subLabel)
                        .font(.custom(nunitoBlack, fixedSize: 13.0))
                        .bold()
                        .foregroundStyle(.black.opacity(0.6))
                        .foregroundColor(.black)
                        .padding(.leading, 10)
                }
                Spacer()
                Image(vectorImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 24,height: 24)
                    .padding(.trailing ,8)
            }
            .frame(maxWidth: .infinity )
        }
        .frame(height: 60)
        .background(.white)
        .cornerRadius(8.0)
        .padding([.leading,.trailing],16)
        .edgesIgnoringSafeArea(.all)
        .shadow(color: .squirrelGrey.opacity(0.5), radius: 2, x: 0, y: 0)
    }
}

//#Preview {
//    ListCell(image: .user1, vectorImg: .arrowForward)
//}
