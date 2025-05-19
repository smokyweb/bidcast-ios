//
//  HeaderWithImageTitle.swift
//  imperium
//
//  Created by Ankit-JAM-E-294 on 25/01/24.
//

import SwiftUI
import Kingfisher

struct HeaderWithImageTitle: View {
    var title: String = ""
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    var onSelectImage: (() -> Void)?
    var onClickLeading: ((Int) -> Void)?
    var onClickTrailing: ((Int) -> Void)?
    
    @Binding var userName: String
    @Binding var userImg: String
    @State var isEditable : Bool = false
    @State var showDetails: Bool = false
    
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
            
            if showDetails {
                
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
                            if isEditable{
                                Button(action: { self.onSelectImage?() }, label: {
                                    Image(systemName: "pencil.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 35, height: 35)
                                        .foregroundStyle(.text)
                                })
                            }
                        })
                    
                        .contextMenu {
                            Text(userName)
                        } preview: {
                            KFImage.url(getMediaURL(url: userImg))
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
                                .frame(width: screenWidth, height: screenHeight*0.8)
                        }
                    
                    
                    Text(userName)
                        .font(.custom(nunitoBlack, fixedSize: 22))
                        .padding(.top, 8)
                        .frame(height: 20)
                })
                .padding(.bottom, 18)
            }
        })
        .frame(height: topPadding + 225)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75, execute: {
                withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                    showDetails = true
                }
            })
        }
    }
}

#Preview {
    HeaderWithImageTitle(userName: .constant(""), userImg: .constant(""))
}

func getMediaURL(url: String) -> URL {
    let baseURL: String = "https://backend.imperiumjob.com/"
    if let url = URL(string: baseURL + url) {
        return url
    }
    
    return URL(string: baseURL)!
}
