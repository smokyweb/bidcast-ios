//
//  ToggleCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI
struct ToggleCell: View {
    var title : String = "About Us"
    var textColor : Color?
    var fontValue : CGFloat = 15
    @Binding var isTappedSwitch : Bool
    var onToggle: ((Bool) -> Void)? = nil
   
    
    var body: some View {
        
        HStack {
                   Text(title)
                       .font(.custom(poppinsSemiBold, fixedSize: fontValue))
                       .bold()
                       .foregroundColor(textColor)
//                       .padding(.leading, 4)
                   
                   Spacer()
                   
                   Toggle("", isOn: $isTappedSwitch)
                       .labelsHidden()
                       .toggleStyle(SwitchToggleStyle(tint: .defaultTheme))
                       .onChange(of: isTappedSwitch) { newValue in
                           onToggle?(newValue)
                       }
               }
               .frame(height: 30)
               .background(.white)
           
       
    }
}
