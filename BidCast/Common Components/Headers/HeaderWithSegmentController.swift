//
//  HeaderWithSegmentController.swift
// BidSwipe
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI

struct HeaderWithSegmentController: View {
    var title: String = ""
    var option: [String] = []
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    @Binding var count: Int
    
    var onClickLeading: ((Int) -> Void)?
    var onClickTrailing: ((Int) -> Void)?
    var onSegmentOptionClick: ((String) -> Void)?
    
    @State var selectedOption: String = ""
    
    var showAppIcon: Bool = false
    
    var body: some View {
        VStack(spacing: 0, content: {
            Image(.largeHeader)
                .resizable()
                .frame(height: topPadding + (option.count > 0 ? 110 : 50))
            Divider()
                .frame(width: screenWidth, height: 4)
                .background(.red)
        })
        .overlay(alignment: .bottom) {
            VStack {
                HStack {
                    if leadingImgArr.count > 0 {
                        ForEach(leadingImgArr.indices, id: \.self) {
                            ind in
                            Button(action: { withAnimation { onClickLeading?(ind) } }, label: {
                                Image(leadingImgArr[ind])
                                    .font(.custom(poppinsBold, size: 16))
                                    .foregroundColor(.primary)
                                    .frame(width: 36, height: 36)
                            })
                        }
                    }
                    
                    Spacer()
                    
//                    if showAppIcon {
//                        Image(.appName)
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(height: 25)
//                            .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                            .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
//                    } else {
//                        Text(title)
//                            .font(.custom(nunitoBlack, size: 18))
//                            .foregroundStyle(.white)
//                            .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                            .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
//                    }
                    
//                    Text(title)
//                        .font(.custom(nunitoBlack, size: 18))
//                        .foregroundStyle(.white)
//                        .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                        .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                    
                    Spacer()
                    
                    if trailingImgArr.count > 0 {
                        ForEach(trailingImgArr.indices, id: \.self) {
                            ind in
                            if ind == 0 {
                                Button(action: { withAnimation { onClickTrailing?(ind) } }, label: {
                                    
                                    
                                    if count != 0 {
                                        Image(trailingImgArr[ind])
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                            .tint(.white)
                                            .padding(.all, 8)
                                            .overlay(NotificationCountView(value: $count))
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
                .frame(height: 50)
                .overlay(alignment: .center, content: {
                    if showAppIcon {
                        Image(.appName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 25)
//                            .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                            .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                    } else {
                        Text(title)
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .foregroundStyle(.white)
//                            .padding(.leading, CGFloat(trailingImgArr.count) * 38)
//                            .padding(.trailing, CGFloat(leadingImgArr.count) * 38)
                    }
                })
                
                HStack(spacing: 0) {
                    ForEach(option.indices, id: \.self) {
                        ind in
                        Button(action: {
                            withAnimation(.interpolatingSpring) {
                                selectedOption = option[ind]
                                onSegmentOptionClick?(option[ind])
                            }
                        }, label: {
                            Text(option[ind])
                                .font(.custom(nunitoBold, fixedSize: 13))
                                .lineLimit(1)
                                .foregroundColor(selectedOption == option[ind] ? .text : .white)
                                .frame(width: (screenWidth-54)/3, height: 40)
                                .background(selectedOption == option[ind] ? .white : .clear)
                                .cornerRadius(20)
                                .padding(.all, 4)
                        })
                    }
                }
                .frame(width: screenWidth - 30)
                .background(.gray.opacity(0.1))
                .cornerRadius(25)
                .shadow(color: .gray, radius: 1)
                .padding(.bottom)
                .onAppear(perform: {
                    if selectedOption == "" {
                        selectedOption = option.first ?? ""
                    }
                })
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    HeaderWithSegmentController(count: .constant(0))
}
