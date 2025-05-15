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
    var fontValue : CGFloat = 23
    var menuImg : String = "defaultUser"
    var vectorImg : ImageResource = .vacation
    var isSelectable : Bool = false
    @Binding var isTappedSwitch : Bool
    var onToggle: ((Bool) -> Void)? = nil
    var onTapMenuCell: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center,spacing: 10){
            HStack{
                Image(menuImg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 25,height: 25)
                    .padding(.leading ,10)
                Text(title)
                    .font(.custom(nunitoBlack, fixedSize: fontValue))
                    .bold()
                    .foregroundStyle(.text)
                    .foregroundColor(textColor)
                    .padding(.leading, 10)
                Spacer()
                if !isSelectable{
                    Image(vectorImg)
                        .resizable()
                        .scaledToFill()
                        .rotationEffect(Angle(degrees: 90))
                        .frame(width: 24,height: 24)
                        .padding(.trailing ,10)
                }else{
                    
                    Rectangle()
                        .fill(isTappedSwitch ? .tabBar : .bg)
                        .frame(width: 44,height: 28)
                        .cornerRadius(14)
                        .padding(8)
                        .opacity(1)
                        .onTapGesture {
                            isTappedSwitch.toggle()
                            onToggle?(isTappedSwitch)
                        }
                    
                }
            }
            .frame(maxWidth: .infinity )
        }
        .frame(height: 70)
        .background(.white)
        .cornerRadius(8.0)
        .padding([.leading,.trailing],8)
        .edgesIgnoringSafeArea(.all)
        .shadow(color: .squirrelGrey.opacity(0.5), radius: 2, x: 0, y: 0)
        .onTapGesture {
            onTapMenuCell?()
        }
    }
}

//#Preview {
//    MenuCell( isTappedSwitch: isTappedSwitch)
//}
