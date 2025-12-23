    //
    //  SwiftUIView.swift
    // BidSwipe
    //
    //  Created by Ankit - JAM - E - 294 on 23/01/24.
    //

import SwiftUI

struct HeaderWithSearch: View {
    var title: String = ""
    var option: [String] = []
    var leadingImgArr: [ImageResource] = []
    var trailingImgArr: [ImageResource] = []
    
    var onClickLeading: ((Int) -> Void)?
    var onClickTrailing: ((Int) -> Void)?
    var onSubmitClick: ((String) -> Void)?
    var onFilterClick: (() -> Void)?
    
    @State var searchText: String = ""
    
    var body: some View {
        VStack(spacing: 0, content: {
            Image(.largeHeader)
                .resizable()
                .frame(height: topPadding + 100)
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
                
                HStack(spacing: 0) {
                    Image(.search)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.black.opacity(0.5))
                        .padding(.all, 10)
                        .background(.gray.opacity(0.15))
                        .clipShape(Circle())
                    
                    Spacer()
                    
                    TextField("Search for...", text: $searchText)
                        .font(.custom(nunitoMedium, fixedSize: 14))
                        .keyboardType(.default)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .foregroundStyle(.text)
                        .accentColor(.text)
                        .submitLabel(.search)
                        .onSubmit {
                            self.onSubmitClick?(searchText)
                        }
                    
                    Spacer()
                    
                    Button(action: { onFilterClick?() }, label: {
                        Image(.filterEdit)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.black.opacity(0.5))
                            .padding(.all, 10)
                    })
                }
                .frame(width: screenWidth - 30)
                .padding(.all, 4)
                .background(.white)
                .cornerRadius(25)
                .shadow(color: .gray, radius: 1)
                .padding(.bottom)
            }
        }
        .edgesIgnoringSafeArea(.top)
    }
}

#Preview {
    HeaderWithSearch()
}

