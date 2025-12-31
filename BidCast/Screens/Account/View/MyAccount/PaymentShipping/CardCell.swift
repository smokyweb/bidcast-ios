//
//  CardCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//
import SwiftUI

struct CardCell: View {
    var image = ""
    var cardNo = ""
    var expires = ""
    var onTapDefault : () -> () = { }
    var onTapEdit : () -> () = { }
    var onTapDelete : () -> () = { }
    var onTapCard : () -> () = { }
    @State var forSelect : Bool = false
    var isSelected: Bool = false
    @State var isDefault : Bool = false
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 40, height: 25)
                .foregroundColor(Color.defaultTheme)
            VStack(alignment: .leading) {
                Text("•••• •••• •••• \(cardNo)")
                    .font(.custom(poppinsSemiBold, size: 12.0))
                Text("Expires \(expires)")
                    .font(.custom(poppinsRegular, size: 12.0))
                    .foregroundColor(.gray)
            }
            if isDefault{
                Text("Default")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .background(.defaultThemeLight)
                    .foregroundColor(.defaultTheme)
                    .cornerRadius(12)
            }
            Spacer()
            if !forSelect{
                Menu {
                    Button(action: {
                        
                        onTapDefault()
                    }){
                        Text("Set as default")
                            .font(.custom(poppinsSemiBold, size: 11))
                    }
                    
                    Button(action: {
                        onTapEdit()
                    }){
                        Text("Edit Card")
                            .font(.custom(poppinsSemiBold, size: 11))
                    }
                    
                    Button(role: .destructive, action: {
                        
                        onTapDelete()
                    }){
                        Text("Delete")
                            .font(.custom(poppinsSemiBold, size: 11))
                    }
                    
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }else{
                if isSelected{
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.system(size: 22))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                        .font(.system(size: 22))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.gray.opacity(0.3), radius: 4, x: 0, y: 2)
        .onTapGesture {
            self.onTapCard()
        }
    }
}
