//
//  NotificationListingCard.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/02/24.
//

import SwiftUI
import Kingfisher

struct NotificationListingCard: View {
    
    //MARK: - Initiated Variables
    @Binding var notificationData: NotificationListModel
    
    var onSelected: ((NotificationListModel) -> Void)?
    
    //MARK: - Primary View
    var body: some View {
            HStack(alignment: .top, spacing: 10) {
                KFImage.url(getMediaURL(url:  notificationData.sender?.profile_image ?? ""))
                    .placeholder({
                        Image(.imgPlaceholder)
                            .resizable()
                            .blur(radius: 1.5)
                            .scaledToFill()
                    })
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0, content: {
                    
                    HStack(spacing: 0) {
                        
                        Text(notificationData.sender?.name ?? "Company Name")
                            .font(.custom( notificationData.isSeen ?? "" == "0" ? nunitoBold : nunitoMedium, fixedSize: notificationData.isSeen ?? "" == "0" ? 18 : 16))
                            .foregroundStyle(.black)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.forward")
                            .resizable()
                            .scaledToFit()
                            .tint(.text)
                            .frame(width: 10, height: 20)
                            .clipShape(Circle())
                    }
                    
                    Text(notificationData.message ?? "Knoxville, TN, USA")
                        .font(.custom(nunitoLight, fixedSize: 14))
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(notificationData.isSeen ?? "" == "0" ? .text : .gray)
                    
                    Text(notificationData.created_at?.stringISOToDate().offsetFrom() ?? "date")
                        .font(.custom(nunitoLight, fixedSize: 11))
                        .foregroundStyle(.gray)
                })
            }
            .onTapGesture {
                self.onSelected?(notificationData)
            }
            .padding(.all)
            .onTapGesture {
                self.onSelected?(notificationData)
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
            )
            .onTapGesture {
                self.onSelected?(notificationData)
            }
    }
}

#Preview {
    NotificationListingCard(notificationData: .constant(NotificationListModel()))
}
