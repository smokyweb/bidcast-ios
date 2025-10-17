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
    @State private var showOption: Bool = false
    
    var anchor: Anchor = .bottom
    var maxWidth: CGFloat = UIScreen.main.bounds.width - 30
    var cornerRadius: CGFloat = 9
    
    @State var custFontName: String = poppinsBold
    @State var custFontSize: Double = 13.0
    @State var custCategory: String = poppinsMedium
    @State var custCategorySize: Double = 13.0
    
    var onOptionSelected: ((String) -> Void)?
    
    @Environment(\.colorScheme) private var scheme
    
    @SceneStorage("drop_down_zindex") private var index = 1001.0
    @State private var zIndex = 1000.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(custFontName, fixedSize: custFontSize))
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
            }
            
            ZStack(alignment: anchor == .top ? .bottom : .top) {
                
                // Main button
                HStack {
                    Text(selected == "" ? hint : selected)
                        .font(.custom(custCategory, fixedSize: custCategorySize))
                        .foregroundStyle(selected == "" ? .gray : .text)
                    Spacer()
                    Image(.arrowForward)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 16, height: 16)
                        .foregroundStyle(.text)
                        .rotationEffect(.degrees(showOption ? 0 : -90))
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(scheme == .dark ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
                .onTapGesture {
                    index += 1
                    zIndex = index
                    withAnimation(.easeInOut(duration: 0.15)) {
                        showOption.toggle()
                    }
                    
                }
                
                // Dropdown Options (overlayed, never clipped)
                if showOption {
                    optionView()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .shadow(radius: 1)
                        .padding(.top, anchor == .bottom ? 50 : 0)
                        .padding(.bottom, anchor == .top ? 50 : 0)
                        .zIndex(zIndex + 1)
                        .transition(.move(edge: anchor == .top ? .bottom : .top))
                }
            }
            .frame(width: maxWidth)
            .zIndex(zIndex)
        }
    }
    
    @ViewBuilder
    func optionView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 2) {
                ForEach(options, id: \.self) { ind in
                    HStack {
                        Text(ind)
                            .lineLimit(1)
                            .font(.custom(poppinsRegular, fixedSize: 11))
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(selected == ind ? 1 : 0)
                    }
                    .frame(height: 30)
                    .foregroundStyle(selected == ind ? Color.defaultTheme : .gray)
                    .onTapGesture {
                        selected = ind
                        self.onOptionSelected?(selected)
                        withAnimation(.easeOut(duration: 0.2)) {
                            showOption = false
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: options.count > 3 ? 200 : CGFloat(options.count) * 42)
    }
    
    enum Anchor {
        case top
        case bottom
    }
}


//#Preview {
//    DropDownSelection(options: .constant([]))
//}
