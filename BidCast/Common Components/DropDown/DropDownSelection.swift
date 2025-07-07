//
//  DropDownSelection.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 05/02/24.
//

import Foundation
import SwiftUI

struct DropDownSelection: View {
    
    @Binding var options: [String]
    @State var floatingLabel: String = ""
    @State var hint: String = ""
    
    
    @Binding var selected: String
    @State var showOption: Bool = false
    var anchor: Anchor = .bottom
    var maxWidth: CGFloat = screenWidth - 30
    var cornerRadius: CGFloat = 9
    @State var custFontName: String = poppinsBold
    @State var custFontSize: Double = 13.0
    @State var custCategory : String = poppinsMedium
    @State var custCategorySize : Double = 13.0
    
    var onOptionSelected: ((String) -> Void)?
    
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1001.0
    @State var zIndex = 1000.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(custFontName, fixedSize: custFontSize))
//                    .bold()
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
            }
            GeometryReader {
                let size = $0.size
                VStack(spacing: 0, content: {
                    
                    if showOption && anchor == .top {
                        optionView().background(.white)
                    }
                    
                    HStack(spacing: 0, content: {
                        Text(selected == "" ? hint : selected )
                            .font(.custom(custCategory, fixedSize: custCategorySize))
                            .foregroundStyle(selected == "" ? .gray : .text)
                        Spacer()
                        Image(.arrowForward)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.text)
                            .rotationEffect(.init(degrees: showOption ? 0 : -90))
                        
                    })
                    .padding(.horizontal, 16)
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
            .zIndex(zIndex + 1)
        }
    }
    
    @ViewBuilder
    func optionView() -> some View {
        VStack(spacing: 2) {
            ForEach(options, id: \.self) {
                ind in
                HStack(spacing: 0, content: {
                    Text(ind)
                        .lineLimit(1)
                        .font(.custom(poppinsMedium, fixedSize: 13))
                    Spacer()
//                    Image(systemName: "checkmark")
//                        .opacity(selected == ind ? 1 : 0)
                })
                .frame(height: 32)
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
        .frame(maxHeight: 200)          
        .padding(.horizontal)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
        .background(.white)
    }
    
    enum Anchor {
        case top
        case bottom
    }
}

//#Preview {
//    DropDownSelection(options: .constant([]))
//}
