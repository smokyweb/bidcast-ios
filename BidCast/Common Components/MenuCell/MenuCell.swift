//
//  MenuCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 13/05/25.
//

import SwiftUI

struct MenuCell: View {
    var title : String = "About Us"
    var textColor : Color?
    var fontName = poppinsSemiBold
    var fontValue : CGFloat = 16.0
    var menuImg : String = "defaultUser"
    var vectorImg : ImageResource = .vacation
    var isSelectable : Bool = false
    
    @Binding var isTappedSwitch : Bool
    var onToggle: ((Bool) -> Void)? = nil
    var onTapMenuCell: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if !menuImg.isEmpty {
                Image(menuImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25, height: 25)
                    .padding(.leading ,10)
            }
            
            Text(title)
                .font(.custom(fontName, fixedSize: fontValue))
                .foregroundColor(textColor ?? .text)
                .padding(.leading, 10)
            
            Spacer()
            
            if !isSelectable {
                Image(vectorImg)
                    .resizable()
                    .scaledToFill()
                    .rotationEffect(Angle(degrees: 90))
                    .frame(width: 24, height: 24)
                    .padding(.trailing ,10)
            } else {
                Toggle("", isOn: $isTappedSwitch)
                    .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))
                    .labelsHidden()
                    .onChange(of: isTappedSwitch) { newValue in
                        onToggle?(newValue)
                    }
                    .padding(.trailing, 12)
            }
        }
        .frame(height: 55)
        .background(.white)
        .cornerRadius(8.0)
        .padding([.leading,.trailing], 8)
        .shadow(color: .squirrelGrey.opacity(0.5), radius: 2, x: 0, y: 0)
        .onTapGesture {
            if !isSelectable {
                onTapMenuCell?()
            }
        }
    }
}

