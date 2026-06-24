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
    @State var description: String = ""
    @State var hint: String = ""
    
    @Binding var selected: String
    @State private var showOption: Bool = false
    
    var anchor: Anchor = .bottom
    var maxWidth: CGFloat = .infinity//UIScreen.main.bounds.width - 30
    var cornerRadius: CGFloat = 24
    
    @State var custFontName: String = poppinsBold
    @State var custFontSize: Double = 13.0
    @State var descFontName: String = poppinsRegular
    @State var descFontSize: Double = 13.0
    @State var custCategory: String = poppinsMedium
    @State var custCategorySize: Double = 13.0
    
    var onOptionSelected: ((String) -> Void)?
    
    @Environment(\.colorScheme) private var scheme
    
    @SceneStorage("drop_down_zindex") private var index = 1001.0
    @State private var zIndex = 1000.0
    
    // Animate height
    @State private var dropdownHeight: CGFloat = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(custFontName, fixedSize: custFontSize))
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
            }
            
            if description != "" {
                Text(description)
                    .font(.custom(descFontName, fixedSize: descFontSize))
                    .foregroundStyle(.text)
                    .multilineTextAlignment(.leading)
            }
            
            ZStack(alignment: anchor == .top ? .bottom : .top) {
                
                // Main Button
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
                        .rotationEffect(.degrees(showOption ? -180 : 0))
                }
                .padding(.horizontal, 16)
                .frame(height: 50)
                .background(scheme == .dark ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .shadow(color: .gray.opacity(0.7), radius: 1, x: 0, y: 0)
                .onTapGesture {
                    hideKeyboardPopup()
                    index += 1
                    zIndex = index
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        showOption.toggle()
                        dropdownHeight = showOption ? calculateHeight() : 0
                    }
                }
                
                // Dropdown Options with expanding height
                if showOption || dropdownHeight > 0 {
                    optionView()
                        .frame(height: dropdownHeight)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                        .shadow(radius: 1)
                        .padding(.top, anchor == .bottom ? 50 : 0)
                        .padding(.bottom, anchor == .top ? 50 : 0)
                        .zIndex(zIndex + 1)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: dropdownHeight)
                        .transition(.scale(scale: 0.9, anchor: anchor == .top ? .bottom : .top).combined(with: .opacity))
                }
            }
            .frame(width: maxWidth)
            .zIndex(zIndex)
        }
    }
    
    // Option View
    @ViewBuilder
    func optionView() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 2) {
                ForEach(options, id: \.self) { ind in
                    HStack {
                        Text(ind)
                            .lineLimit(1)
                            .font(.custom(poppinsSemiBold, fixedSize: 13))
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(selected == ind ? 1 : 0)
                    }
                    .frame(height: 30)
                    .foregroundStyle(selected == ind ? Color.defaultTheme : .gray)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .background(Color.white)
                    .onTapGesture {
                        selected = ind
                        self.onOptionSelected?(selected)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showOption = false
                            dropdownHeight = 0
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Helper for height calculation
    func calculateHeight() -> CGFloat {
        return options.count > 5 ? 200 : CGFloat(options.count) * 35
    }
    
    enum Anchor {
        case top
        case bottom
    }
}
