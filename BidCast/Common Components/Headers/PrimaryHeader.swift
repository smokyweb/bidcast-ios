//
//  PrimaryHeader.swift
// BidSwipe
//
//  Created by JAM-E-282 on 19/01/24.
//

import SwiftUI

struct PrimaryHeader: View {
    
    var title: String = "Header Title"
    var isForLogo : Bool = false
    
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    var showShadow : Bool = true
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
                                .frame(width: isForLogo ? 90 : 30, height: isForLogo ? 50 : 30)
                                .tint(.white)
                                .padding(.all,0)
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
                                        .renderingMode(.original)
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
                                    .renderingMode(.original)
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
            .frame(height: 50)
            .padding(.top, 10)
            .padding(.leading , Leading/2)
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
                        .font(.custom(poppinsBold, fixedSize: 18))
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                        .padding(.top)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                }
            })
        }
        .frame(height: topPadding + 50)
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    PrimaryHeader(count: .constant(0))
}


//import SwiftUI
//
//struct PrimaryHeader: View {
//    var title: String = "Header Title"
//    var isForLogo: Bool = false
//
//    var leadingImgArr: [ImageResource] = []
//    var trailingImgArr: [ImageResource] = []
//    var showShadow: Bool = true
//    var onClickLeading: ((Int) -> Void)?
//    var onClickTrailing: ((Int) -> Void)?
//
//    var showAppIcon: Bool = false
//
//    @Binding var count: Int
//
//    var body: some View {
//        VStack {
//            HStack {
//                // Leading Icons
//                ForEach(leadingImgArr.indices, id: \.self) { ind in
//                    Button(action: {
//                        withAnimation { onClickLeading?(ind) }
//                    }) {
//                        Image(leadingImgArr[ind])
//                            .renderingMode(.original)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: isForLogo ? 90 : 30, height: 30)
//                            .padding(16)
//                    }
//                }
//
//                Spacer()
//
//                // Title or Logo
//                if showAppIcon {
//                    Image(.appName)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(height: 25)
//                } else {
//                    Text(title)
//                        .font(.custom("Poppins-Bold", size: 18))
//                        .fontWeight(.bold)
//                        .foregroundColor(.black)
//                }
//
//                Spacer()
//
//                // Trailing Icons
//                ForEach(trailingImgArr.indices, id: \.self) { ind in
//                    Button(action: {
//                        withAnimation { onClickTrailing?(ind) }
//                    }) {
//                        Image(trailingImgArr[ind])
//                            .renderingMode(.original)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 30, height: 30)
//                            .padding(8)
//                            .overlay(
//                                ind == 0 && count != 0 ?
//                                NotificationCountView(value: .constant(count)) : nil
//                            )
//                    }
//                }
//            }
//            .frame(height: 50)
//            .padding(.horizontal)
////            .background(Color.white)
//            .shadow(color: showShadow ? Color.black.opacity(0.1) : .clear, radius: 4, y: 2)
//        }
////        .background(Color.white)
//    }
//}
