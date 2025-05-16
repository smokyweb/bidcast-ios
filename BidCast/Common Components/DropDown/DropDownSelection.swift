//
//  DropDownSelection.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 05/02/24.
//

import Foundation
import SwiftUI

struct DropDownSelection: View {
    
    @Binding var options: [String]
    @State var floatingLabel: String = ""
    @State var hint: String = ""
    
    
    @State var selected: String = ""
    @State var showOption: Bool = false
    var anchor: Anchor = .bottom
    var maxWidth: CGFloat = screenWidth - 30
    var cornerRadius: CGFloat = 9
    
    var onOptionSelected: ((String) -> Void)?
    
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1001.0
    @State var zIndex = 1001.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(nunitoBold, fixedSize: 15))
                    .bold()
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
                            .font(.custom(nunitoMedium, fixedSize: 16))
                            .foregroundStyle(selected == "" ? .gray : .text)
                        Spacer()
                        Image(.arrowForward)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(.text)
                            .rotationEffect(.init(degrees: showOption ? -90 : 0))
                        
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
        VStack(spacing: 2) {
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
                .frame(height: 25)
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
    DropDownSelection(options: .constant([]))
}
