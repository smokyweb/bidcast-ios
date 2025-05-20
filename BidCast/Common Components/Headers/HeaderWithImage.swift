//
//  HeaderWithImage.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 05/03/24.
//

import SwiftUI
import Kingfisher

struct HeaderWithImage: View {
    var title: String = ""
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    
    var onClickLeading: ((Int) -> Void)?
    var onClickTrailing: ((Int) -> Void)?
    var onSelectImage: (() -> Void)?
    
    var showEdit: Bool = true
    
    @Binding var userImg: String
    
    var body: some View {
        ZStack(alignment: .bottom, content: {
            VStack(spacing: 0, content: {
                Image(.header)
                    .resizable()
                    .frame(height: topPadding + 50)
                    .overlay(alignment: .bottom) {
                        HStack {
                            if leadingImgArr.count > 0 {
                                ForEach(leadingImgArr.indices, id: \.self) {
                                    ind in
                                    Button(action: { withAnimation { onClickLeading?(ind) } }, label: {
                                        Image(leadingImgArr[ind])
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .tint(.white)
                                            .padding(.all, 8)
                                    })
                                }
                            }
                            
                            Spacer()
                            
                            Text(title)
                                .font(.custom(nunitoBlack, fixedSize: 18))
                                .foregroundStyle(.white)
                                .padding(.leading, CGFloat(trailingImgArr.count) * 38)
                                .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                            
                            Spacer()
                            
                            if trailingImgArr.count > 0 {
                                ForEach(trailingImgArr.indices, id: \.self) {
                                    ind in
                                    Button(action: { withAnimation { onClickTrailing?(ind) } }, label: {
                                        Image(trailingImgArr[ind])
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .tint(.white)
                                            .padding(.all, 8)
                                    })
                                }
                            }
                        }
                        .frame(height: 40)
                        .padding(.bottom, 10)
                    }
                Image(.header)
                    .resizable()
                    .frame(height: 50)
                Divider()
                    .frame(width: screenWidth, height: 4)
                    .background(.red)
                Spacer()
            })
            
            VStack(spacing: 8, content: {
                
                KFImage.url(userImg.contains("media") ? getMediaURL(url: userImg) : URL(string: userImg))
                    .placeholder({
                        Image(.menuProfile)
                            .renderingMode(.template)
                            .resizable()
                            .blur(radius: 1.5)
                            .padding(.all)
                            .foregroundStyle(.text.opacity(0.5))
                    })
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screenWidth/3.15, height: screenWidth/3.15)
                    .clipShape(Circle())
                    .padding(.all, 4)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .overlay(alignment: .bottomTrailing, content: {
                        Button(action: { self.onSelectImage?() }, label: {
                            Image(systemName: "pencil.circle.fill")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 35, height: 35)
                                .foregroundStyle(.text)
                        })
                    })
            }).padding(.bottom, 20)
        })
        .frame(height: topPadding + 200)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    HeaderWithImage(userImg: .constant(""))
}
