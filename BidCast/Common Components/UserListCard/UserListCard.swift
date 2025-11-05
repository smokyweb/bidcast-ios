//
//  UserListCard.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 03/02/24.
//

import SwiftUI
//import Kingfisher

//struct UserListCard: View {
//    
//    var employeeDetail: UserDetailModal = UserDetailModal()
//    
//    var onClick: ((Int) -> Void)?
//    
//    var body: some View {
//        Button(action: { self.onClick?(employeeDetail.id ?? 0) }, label: {
//            HStack(alignment: .top, spacing: 10) {
//                
//                KFImage.url(getMediaURL(url: employeeDetail.profile_image ?? ""))
//                    .placeholder({
//                        Image(.imgPlaceholder)
//                            .resizable()
//                            .blur(radius: 1.5)
//                    })
//                    .retry(maxCount: 3, interval: .seconds(5))
//                    .cacheOriginalImage()
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 50, height: 50)
//                    .clipShape(Circle())
//                    .shadow(radius: 2)
//                
//                HStack(alignment: .center, spacing: 0) {
//                    VStack(alignment: .leading, spacing: 0, content: {
//                        Text(employeeDetail.name ?? "")
//                            .font(.custom(nunitoBold, fixedSize: 18))
//                            .bold()
//                            .foregroundStyle(.black)
//                            .lineLimit(1)
//                        Text(employeeDetail.location ?? "")
//                            .font(.custom(nunitoLight, fixedSize: 14))
//                            .multilineTextAlignment(.leading)
//                            .foregroundStyle(.text)
//                            .lineLimit(2)
//                    })
//                    Spacer()
//                    Image(.sideArrow)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 20, height: 20)
//                        .clipShape(Circle())
//                        .rotationEffect(Angle(degrees: 180))
//                }
//            }
//            .padding(.all)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.white)
//                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
//            )
//        })
//    }
//}
//
//#Preview {
//    UserListCard()
//}
