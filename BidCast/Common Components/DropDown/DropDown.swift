//
//  DropDown.swift
// BidSwipe
//
//  Created by JAM-E-282 on 22/01/24.
//

import SwiftUI

struct DropDown: View {
    
    var hint: String = ""
    var options: [String] = []
    var anchor: Anchor = .bottom
    var floatingLabel: String = ""
    var maxWidth: CGFloat = screenWidth - 30
    var cornerRadius: CGFloat = 10
    
    @State var selected: String = ""
    @State var showOption: Bool = false
    @State var showLeadingIcon: Bool = false
    @State var leadingIcon: ImageResource = .userDummy
    @State var isRequired: Bool = false
    @State var isMandatory: Bool = false
    
    var onOptionSelected: ((String) -> Void)?
    var isRequiredValue: ((Int) -> Void)?
    
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zIndex = 1000.0
    
    var body: some View {
        if showLeadingIcon{
            VStack(alignment: .leading, spacing: 5){
                Text(floatingLabel)
                    .font(.custom(nunitoBold, fixedSize: 15))
                    .bold()
                    .foregroundStyle(.text)
                
                GeometryReader {
                    let size = $0.size
                    
                    VStack(spacing: 0, content: {
                        
                        if showOption && anchor == .top {
                            optionView().background(.white)
                        }
                        
                        HStack(spacing: 0, content: {
                            Image(leadingIcon)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.text.opacity(0.45))
                                .padding(.all, 10)
                                .background(.text.opacity(0.1))
                                .clipShape(Circle())
                                .padding(.trailing, 10)
                            
                            
                            Text(selected == "" ? hint : selected )
                                .font(.custom(nunitoMedium, fixedSize: 16))
                                .foregroundStyle(selected == "" ? .gray : .text)
                            
                            Spacer()
                            
                            Image(.arrowForward)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .rotationEffect(.degrees(showOption ? 90 : 0)) // Rotate icon when open
                                .foregroundStyle(.text)
                            
                        })
                        .padding(.horizontal, 8)
                        .frame(width: size.width, height: size.height)
                        .background(scheme == .dark ? .black : .white)
                        .contentShape(.rect)
                        .onTapGesture {
                            index += 1
                            zIndex = index
                            withAnimation(.snappy) {
                                showOption.toggle()
                            }
                        }
                        .zIndex(10)
                        
                        if showOption && anchor == .bottom {
                            optionView().background(.white)
                        }
                    })
                    .clipped()
                    .background((scheme == .dark ? Color.black : Color.white))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
                    .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
                }
                .frame(width: maxWidth, height: 50)
                .zIndex(zIndex)
                if isMandatory{
                    HStack{
                        
                        Button(action: {
                            isRequired.toggle()
                            if isRequired{
                                self.isRequiredValue?(1)
                            }else{
                                self.isRequiredValue?(0)
                            }
                        }, label: {
                            Image(systemName: isRequired ? "checkmark.square.fill":"square")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.text)
                            
                            Text("It's required")
                                .font(.custom(nunitoRegular, fixedSize: 15))
                                .foregroundStyle(.text)
                        })
                        
                        Spacer()
                        
                    }
                    .padding(.top,1.5)
                    .padding(.leading,-0.5)
                }
            }
        }else{
            GeometryReader {
                let size = $0.size
                
                VStack(spacing: 0, content: {
                    
                    if showOption && anchor == .top {
                        optionView().background(.white)
                    }
                    
                    HStack(spacing: 0, content: {
                        Text(selected == "" ? hint : selected )
                            .font(.custom(nunitoMedium, fixedSize: 16))
                            .foregroundStyle(selected == "" ? .gray : .text)
                        
                        Spacer()
                        
                        Image(.arrowForward)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.text)
                            .rotationEffect(.init(degrees: showOption ? 90 : 0))
                        
                    })
                    .padding(.horizontal, 15)
                    .frame(width: size.width, height: size.height)
                    .background(scheme == .dark ? .black : .white)
                    .contentShape(.rect)
                    .onTapGesture {
                        index += 1
                        zIndex = index
                        withAnimation(.snappy) {
                            showOption.toggle()
                        }
                    }
                    .zIndex(10)
                    
                    if showOption && anchor == .bottom {
                        optionView().background(.white)
                    }
                })
                .clipped()
                .background((scheme == .dark ? Color.black : Color.white))
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
                .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
            }
            .frame(width: maxWidth, height: 50)
            .zIndex(zIndex)
        }
    }
    
    @ViewBuilder
    func optionView() -> some View {
        VStack(spacing: 4) {
            ScrollView(showsIndicators: false) {
                ForEach(options, id: \.self) {
                    ind in
                    HStack(spacing: 0, content: {
                        Text(ind)
                            .lineLimit(1)
                            .font(.custom(nunitoMedium, fixedSize: 16))
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(selected == ind ? 1 : 0)
                    })
                    .frame(height: 40)
                    .foregroundStyle(selected == ind ? Color.primary : Color.gray)
                    .animation(.none, value: selected)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selected = ind
                            showOption = false
                            self.onOptionSelected?(selected)
                        }
                    }
                }
            }
        }
        .frame(height: options.count > 3 ? 180 : CGFloat(options.count) * 42)
        .padding(.horizontal)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
        .background(.white)
    }
    
    enum Anchor {
        case top
        case bottom
    }
}

#Preview {
    DropDown()
}
