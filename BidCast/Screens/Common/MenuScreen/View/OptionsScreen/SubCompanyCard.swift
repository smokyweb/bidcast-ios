//
//  SubCompanyCard.swift
// BidSwipe
//
//  Created by JAM-E-221 on 27/01/25.
//

import SwiftUI
import Kingfisher

struct SubCompanyCard: View {
    @Binding var subCompanyDetail: SubCompanyModal


    
    var onSelected: ((Int) -> Void)?
    
    var body: some View {
        Button(action: {
            if let id = subCompanyDetail.id {
                self.onSelected?(id)
            } }, label: {
            HStack(alignment: .top, spacing: 10) {
                
                KFImage.url(getMediaURL(url: subCompanyDetail.profile_image?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))
                    .placeholder({
                        Image(.imgPlaceholder)
                            .resizable()
                            .blur(radius: 1.5)
                    })
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0, content: {
                    
                    HStack(spacing: 0) {
                        Text(subCompanyDetail.first_name ?? "")
                            .font(.custom(nunitoBold, fixedSize: 18))
                            .bold()
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(.sideArrow)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .clipShape(Circle())
                            .rotationEffect(Angle(degrees: 180))
                    }
                    
                    
                    Text(subCompanyDetail.email ?? "")
                        .font(.custom(nunitoLight, fixedSize: 14))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.text)
                    
                    Text(subCompanyDetail.user_name ?? "User Title")
                        .font(.custom(nunitoLight, fixedSize: 12))
                        .foregroundStyle(.gray)
                    
                    HStack(spacing: 0) {
                        Text("Status - ")
                            .font(.custom(nunitoLight, fixedSize: 12))
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.text)
                                                
                        Text(subCompanyDetail.status ?? "")
                            .font(.custom(nunitoLight, fixedSize: 12))
                            .foregroundStyle(.gray)
                    }
                })
            }
            .padding(.all)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            )
        })
    }
}

//#Preview {
////    SubCompanyCard()
//}
