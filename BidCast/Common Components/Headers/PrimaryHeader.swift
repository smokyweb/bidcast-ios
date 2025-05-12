//
//  PrimaryHeader.swift
//  imperium
//
//  Created by JAM-E-282 on 19/01/24.
//

import SwiftUI

struct PrimaryHeader: View {
    
    var title: String = "Header Title"
    
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    
    var onClickLeading: ((Int) -> Void)?
    var onClickTrailing: ((Int) -> Void)?
    
    var showAppIcon: Bool = false
    
    @Binding var count: Int
    
    var body: some View {
        VStack{
//            Image(.header)
//                .resizable()
//                .frame(height: topPadding + 50)
//            Divider()
//                .frame(width: screenWidth, height: 4)
//                .background(.red)
        
//        .frame(height: topPadding + 50)
//        .overlay(alignment: .bottom) {
            HStack {
                if leadingImgArr.count > 0 {
                    ForEach(leadingImgArr.indices, id: \.self) {
                        ind in
                        Button(action: { withAnimation { onClickLeading?(ind) } }, label: {
                            Image(leadingImgArr[ind])
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .tint(.white)
                                .padding(.all, 16)
                        })
                    }
                }
                
                Spacer()
                
//                if showAppIcon {
//                    Image(.appName)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 25)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
//                } else {
//                    Text(title)
//                        .font(.custom(nunitoBlack, size: 18))
//                        .foregroundStyle(.white)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
//                }
                
                Spacer()
                
                if trailingImgArr.count > 0 {
                    ForEach(trailingImgArr.indices, id: \.self) {
                        ind in
                        if ind == 0 {
                            Button(action: { withAnimation { onClickTrailing?(ind) } }, label: {
                                if count != 0 {
                                    Image(trailingImgArr[ind])
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .tint(.white)
                                        .padding(.all, 8)
                                        .overlay(NotificationCountView(value: .constant(count)))
                                }else{
                                    Image(trailingImgArr[ind])
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .tint(.white)
                                        .padding(.all, 8)
                                }
                            })
                        }else{
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
            }
            .frame(height: 40)
            .padding(.top, 10)
            .overlay(alignment: .center, content: {
                if showAppIcon {
                    Image(.appName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 25)
                        .padding(.top)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                } else {
                    Text(title)
                        .font(.custom(nunitoBlack, fixedSize: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding(.top)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                }
            })
        }
        .frame(height: topPadding + 40)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    PrimaryHeader(count: .constant(0))
}
